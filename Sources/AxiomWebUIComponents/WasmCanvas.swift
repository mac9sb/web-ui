import Foundation
import AxiomWebUI
import AxiomWebStyle
import AxiomWebRuntime
import AxiomWebI18n

public struct WasmCanvas: Markup {
    public let id: String
    public let modulePath: String
    public let mountExport: String
    public let width: Int?
    public let height: Int?
    public let autoStart: Bool
    public let initialPayload: WasmValue?
    public let fallbackMessage: String
    private let theme: ComponentTheme?

    public init(
        id: String,
        modulePath: String,
        mountExport: String = "mount",
        width: Int? = nil,
        height: Int? = nil,
        autoStart: Bool = true,
        initialPayload: WasmValue? = nil,
        fallbackMessage: String = "Interactive WebAssembly content is unavailable in this browser.",
        theme: ComponentTheme? = nil
    ) {
        self.id = id
        self.modulePath = modulePath
        self.mountExport = mountExport
        self.width = width
        self.height = height
        self.autoStart = autoStart
        self.initialPayload = initialPayload
        self.fallbackMessage = fallbackMessage
        self.theme = theme
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current

        var canvasAttributes: [HTMLAttribute] = [
            HTMLAttribute("id", id),
            HTMLAttribute(WasmDOMCodec.moduleAttribute, modulePath),
            HTMLAttribute(WasmDOMCodec.mountAttribute, mountExport),
            HTMLAttribute(WasmDOMCodec.autoStartAttribute, autoStart ? "true" : "false"),
        ]
        if let width {
            canvasAttributes.append(HTMLAttribute("width", "\(max(1, width))"))
        }
        if let height {
            canvasAttributes.append(HTMLAttribute("height", "\(max(1, height))"))
        }
        if let initialPayload {
            canvasAttributes.append(HTMLAttribute(WasmDOMCodec.initialPayloadAttribute, initialPayload.base64EncodedJSON()))
        }

        return Stack {
            Canvas(attributes: canvasAttributes)
                .display(.keyword("block"))
                .width(.keyword("100%"))
                .background(color: activeTheme.surfaceColor)
                .border(of: 1, color: activeTheme.borderColor)
                .borderRadius(activeTheme.cornerRadius)
            Paragraph(
                fallbackMessage,
                attributes: [
                    HTMLAttribute("class", "ax-wasm-fallback"),
                    HTMLAttribute(WasmDOMCodec.fallbackAttribute, id),
                ]
            )
            .font(size: .sm, color: activeTheme.mutedColor)
            .margins(of: .two, at: .top)
            NoScript {
                Paragraph(fallbackMessage)
            }
        }
        .grid(gap: activeTheme.spacing(1))
        .makeNodes(locale: locale)
    }
}
