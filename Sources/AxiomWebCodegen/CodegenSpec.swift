import Foundation

public enum SpecDomain: String, Sendable {
    case htmlElements
    case cssProperties
    case cssValues
}

public struct GeneratedSpecSnapshot: Sendable, Equatable {
    public let domain: SpecDomain
    public let version: String
    public let entries: [String]

    public init(domain: SpecDomain, version: String, entries: [String]) {
        self.domain = domain
        self.version = version
        self.entries = entries
    }
}

public enum CodegenSpecRegistry {
    // Baseline snapshot used until automated MDN/WHATWG sync lands.
    public static func builtinSnapshot(for domain: SpecDomain) -> GeneratedSpecSnapshot {
        switch domain {
        case .htmlElements:
            return GeneratedSpecSnapshot(domain: .htmlElements, version: "baseline-2026-02-12", entries: [
                "html","head","body","main","section","article","aside","header","footer","nav",
                "h1","h2","h3","h4","h5","h6","p","a","button","form","input","textarea","label",
                "select","option","details","summary","dialog","table","thead","tbody","tr","th","td",
                "img","picture","source","video","audio","canvas","svg","script","style","link","meta"
            ])
        case .cssProperties:
            return GeneratedSpecSnapshot(domain: .cssProperties, version: "baseline-2026-02-12", entries: [
                "display","position","z-index","width","height","min-height","max-width","margin","padding",
                "color","background-color","border-color","border-width","font-size","font-weight","box-shadow",
                "align-items","justify-content","flex-direction","gap","opacity","transform","transition"
            ])
        case .cssValues:
            return GeneratedSpecSnapshot(domain: .cssValues, version: "baseline-2026-02-12", entries: [
                "auto","inherit","initial","unset","none","block","inline","flex","grid","relative",
                "absolute","fixed","sticky","transparent","currentColor"
            ])
        }
    }
}
