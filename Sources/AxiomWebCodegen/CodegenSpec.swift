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
                "a","abbr","address","area","article","aside","audio","b","base","bdi","bdo","blockquote","body","br","button",
                "canvas","caption","cite","code","col","colgroup","data","datalist","dd","del","details","dfn","dialog","div","dl","dt",
                "em","embed","fieldset","figcaption","figure","footer","form","h1","h2","h3","h4","h5","h6","head","header","hgroup","hr","html",
                "i","iframe","img","input","ins","kbd","label","legend","li","link","main","map","mark","math","menu","meta","meter","nav","noscript","object","ol",
                "optgroup","option","output","p","picture","portal","pre","progress","q","rp","rt","ruby","s","samp","script","search","section","select","slot",
                "small","source","span","strong","style","sub","summary","sup","svg","table","tbody","td","template","textarea","tfoot","th","thead","time","title","tr",
                "track","u","ul","var","video","wbr"
            ])
        case .cssProperties:
            return GeneratedSpecSnapshot(domain: .cssProperties, version: "baseline-2026-02-12", entries: [
                "accent-color","align-content","align-items","align-self","animation","animation-delay","animation-direction","animation-duration","animation-fill-mode",
                "animation-iteration-count","animation-name","animation-play-state","animation-timing-function","appearance","aspect-ratio","backdrop-filter","backface-visibility",
                "background","background-attachment","background-blend-mode","background-clip","background-color","background-image","background-origin","background-position",
                "background-repeat","background-size","block-size","border","border-block","border-block-color","border-block-style","border-block-width","border-bottom",
                "border-bottom-color","border-bottom-left-radius","border-bottom-right-radius","border-bottom-style","border-bottom-width","border-collapse","border-color",
                "border-image","border-inline","border-inline-color","border-inline-style","border-inline-width","border-left","border-left-color","border-left-style",
                "border-left-width","border-radius","border-right","border-right-color","border-right-style","border-right-width","border-spacing","border-style","border-top",
                "border-top-color","border-top-left-radius","border-top-right-radius","border-top-style","border-top-width","border-width","bottom","box-shadow","box-sizing",
                "break-after","break-before","break-inside","caption-side","caret-color","clear","clip-path","color","column-count","column-fill","column-gap","column-rule",
                "column-rule-color","column-rule-style","column-rule-width","column-span","column-width","columns","container","container-name","container-type","content",
                "cursor","direction","display","empty-cells","filter","flex","flex-basis","flex-direction","flex-flow","flex-grow","flex-shrink","flex-wrap","float","font",
                "font-family","font-feature-settings","font-kerning","font-optical-sizing","font-size","font-size-adjust","font-stretch","font-style","font-variant","font-weight",
                "gap","grid","grid-auto-columns","grid-auto-flow","grid-auto-rows","grid-column","grid-column-end","grid-column-start","grid-row","grid-row-end","grid-row-start",
                "grid-template","grid-template-areas","grid-template-columns","grid-template-rows","height","hyphens","inset","inset-block","inset-block-end","inset-block-start",
                "inset-inline","inset-inline-end","inset-inline-start","isolation","justify-content","justify-items","justify-self","left","letter-spacing","line-height","list-style",
                "margin","margin-block","margin-block-end","margin-block-start","margin-bottom","margin-inline","margin-inline-end","margin-inline-start","margin-left","margin-right",
                "margin-top","mask","max-height","max-inline-size","max-width","min-height","min-inline-size","min-width","mix-blend-mode","object-fit","object-position","opacity",
                "order","outline","outline-color","outline-offset","outline-style","outline-width","overflow","overflow-anchor","overflow-block","overflow-clip-margin","overflow-inline",
                "overflow-wrap","overflow-x","overflow-y","padding","padding-block","padding-block-end","padding-block-start","padding-bottom","padding-inline","padding-inline-end",
                "padding-inline-start","padding-left","padding-right","padding-top","perspective","perspective-origin","place-content","place-items","place-self","pointer-events",
                "position","resize","right","rotate","row-gap","scale","scroll-behavior","scroll-margin","scroll-margin-block","scroll-margin-inline","scroll-padding","scroll-padding-block",
                "scroll-padding-inline","scroll-snap-align","scroll-snap-stop","scroll-snap-type","scrollbar-color","scrollbar-gutter","scrollbar-width","shape-image-threshold","shape-margin",
                "shape-outside","tab-size","table-layout","text-align","text-decoration","text-decoration-color","text-decoration-line","text-decoration-style","text-emphasis","text-indent",
                "text-overflow","text-rendering","text-shadow","text-transform","top","touch-action","transform","transform-origin","transform-style","transition","transition-delay",
                "transition-duration","transition-property","transition-timing-function","translate","unicode-bidi","user-select","vertical-align","visibility","white-space","width","will-change",
                "word-break","word-spacing","writing-mode","z-index"
            ])
        case .cssValues:
            return GeneratedSpecSnapshot(domain: .cssValues, version: "baseline-2026-02-12", entries: [
                "auto","inherit","initial","unset","none","block","inline","flex","grid","relative",
                "absolute","fixed","sticky","transparent","currentColor"
            ])
        }
    }
}
