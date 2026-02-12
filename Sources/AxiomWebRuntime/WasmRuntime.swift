import Foundation

public enum WasmValue: Sendable, Equatable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([WasmValue])
    case object([String: WasmValue])
    case null

    public static func dictionary(_ values: [String: WasmValue]) -> WasmValue {
        .object(values)
    }

    public static func list(_ values: [WasmValue]) -> WasmValue {
        .array(values)
    }
}

public extension WasmValue {
    func jsonString() -> String {
        switch self {
        case .string(let value):
            return "\"\(escapeJSONString(value))\""
        case .int(let value):
            return "\(value)"
        case .double(let value):
            return formatDouble(value)
        case .bool(let value):
            return value ? "true" : "false"
        case .array(let values):
            return "[\(values.map { $0.jsonString() }.joined(separator: ","))]"
        case .object(let values):
            let keys = values.keys.sorted()
            let body = keys.compactMap { key -> String? in
                guard let value = values[key] else { return nil }
                return "\"\(escapeJSONString(key))\":\(value.jsonString())"
            }.joined(separator: ",")
            return "{\(body)}"
        case .null:
            return "null"
        }
    }

    func base64EncodedJSON() -> String {
        Data(jsonString().utf8).base64EncodedString()
    }
}

public enum WasmDOMCodec {
    public static let moduleAttribute = "data-ax-wasm-module"
    public static let mountAttribute = "data-ax-wasm-mount"
    public static let initialPayloadAttribute = "data-ax-wasm-initial"
    public static let autoStartAttribute = "data-ax-wasm-autostart"
    public static let fallbackAttribute = "data-ax-wasm-fallback-for"
}

public enum WasmJavaScriptGenerator {
    public static func generateDOMBindings() -> String {
        """
(function(){if(window.__ax_wasm_booted){return;}window.__ax_wasm_booted=true;const __axModules=new Map();const __axCanvasModules=new Map();const __axDecodePayload=function(raw){if(!raw){return null;}try{return JSON.parse(atob(raw));}catch(_){return null;}};const __axFallbackFor=function(id){if(!id){return null;}return document.querySelector('[data-ax-wasm-fallback-for=\"'+id+'\"]');};const __axShowFallback=function(id,message){const fallback=__axFallbackFor(id);if(!fallback){return;}fallback.hidden=false;if(message){fallback.textContent=message;}};const __axHideFallback=function(id){const fallback=__axFallbackFor(id);if(!fallback){return;}fallback.hidden=true;};const __axLoadModule=async function(path){if(__axModules.has(path)){return __axModules.get(path);}const loaded=await import(path);__axModules.set(path,loaded);return loaded;};const __axMountCanvas=async function(canvas){const modulePath=canvas.getAttribute('data-ax-wasm-module');if(!modulePath){return;}if(canvas.getAttribute('data-ax-wasm-autostart')==='false'){return;}try{const module=await __axLoadModule(modulePath);const mountName=canvas.getAttribute('data-ax-wasm-mount')||'mount';const mount=module[mountName];if(typeof mount==='function'){const initialPayload=__axDecodePayload(canvas.getAttribute('data-ax-wasm-initial'));await mount(canvas,initialPayload);}__axCanvasModules.set(canvas.id,modulePath);__axHideFallback(canvas.id);canvas.dispatchEvent(new CustomEvent('axwasm:ready',{detail:{module:modulePath}}));}catch(error){const message='WebAssembly module failed to load.';__axShowFallback(canvas.id,message);canvas.dispatchEvent(new CustomEvent('axwasm:error',{detail:{module:modulePath,error:String(error)}}));}};window.AxiomWasm=window.AxiomWasm||{};window.AxiomWasm.invoke=async function(canvasID,exportName,payload){const canvas=document.getElementById(canvasID);if(!canvas){throw new Error('Missing canvas: '+canvasID);}const modulePath=__axCanvasModules.get(canvasID)||canvas.getAttribute('data-ax-wasm-module');if(!modulePath){throw new Error('Missing wasm module for canvas: '+canvasID);}const module=await __axLoadModule(modulePath);const fn=module[exportName];if(typeof fn!=='function'){throw new Error('Missing wasm export: '+exportName);}const result=await fn(payload,canvas);canvas.dispatchEvent(new CustomEvent('axwasm:invoke',{detail:{export:exportName,result:result}}));return result;};window.AxiomWasm.mount=function(canvasID){const canvas=document.getElementById(canvasID);if(!canvas){return Promise.resolve();}return __axMountCanvas(canvas);};document.querySelectorAll('canvas[data-ax-wasm-module]').forEach(function(canvas){__axMountCanvas(canvas);});})();
"""
    }
}

private func formatDouble(_ value: Double) -> String {
    if value.rounded() == value {
        return String(format: "%.0f", value)
    }
    return String(format: "%.12f", value)
        .replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
        .replacingOccurrences(of: #"\.$"#, with: "", options: .regularExpression)
}

private func escapeJSONString(_ value: String) -> String {
    value
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\"", with: "\\\"")
        .replacingOccurrences(of: "\n", with: "\\n")
        .replacingOccurrences(of: "\r", with: "\\r")
        .replacingOccurrences(of: "\t", with: "\\t")
}
