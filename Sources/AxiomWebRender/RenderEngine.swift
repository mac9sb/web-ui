import Foundation
import AxiomWebI18n
import AxiomWebRuntime
import AxiomWebStyle
import AxiomWebUI

public enum RenderError: Error, Equatable {
    case structuredDataValidationFailed(StructuredDataValidationError)
    case jsonEncodingFailed
}

public struct RenderOptions: Sendable {
    public var includeCSS: Bool
    public var includeJavaScript: Bool
    public var buildOptions: BuildOptions

    public init(includeCSS: Bool = true, includeJavaScript: Bool = true, buildOptions: BuildOptions = .init()) {
        self.includeCSS = includeCSS
        self.includeJavaScript = includeJavaScript
        self.buildOptions = buildOptions
    }
}

public struct RenderedDocument: Sendable, Equatable {
    public let html: String
    public let css: String
    public let javascript: String

    public init(html: String, css: String, javascript: String) {
        self.html = html
        self.css = css
        self.javascript = javascript
    }
}

public enum RenderEngine {
    public static func render(
        document: any Document,
        websiteMetadata: Metadata? = nil,
        metadataOverride: Metadata? = nil,
        locale: LocaleCode,
        runtime: RuntimeProgram = .init(),
        options: RenderOptions = .init()
    ) throws -> RenderedDocument {
        let mergedMetadata = merge(site: websiteMetadata, page: metadataOverride ?? document.metadata, locale: locale)
        let bodyNodes = document.body.makeNodes(locale: locale)
        let generatedCSS = options.includeCSS ? HybridCSSGenerator.generate(classes: HybridCSSGenerator.extractClasses(from: bodyNodes)) : GeneratedCSS(content: "", classes: [])
        let documentRuntime = (document as? any RuntimeProgramProviding)?.runtimeProgram ?? .init()
        let mergedRuntime = documentRuntime.merging(runtime)
        let usesDOMRuntimeBindings = hasDOMRuntimeBindings(in: bodyNodes)
        let usesWasmBindings = hasWasmBindings(in: bodyNodes)
        let javascript: String
        if options.includeJavaScript {
            let runtimeJavaScript = RuntimeJavaScriptGenerator.generate(
                program: mergedRuntime,
                includeDOMBindings: usesDOMRuntimeBindings
            )
            let wasmJavaScript = usesWasmBindings ? WasmJavaScriptGenerator.generateDOMBindings() : ""
            javascript = [runtimeJavaScript, wasmJavaScript]
                .filter { !$0.isEmpty }
                .joined()
        } else {
            javascript = ""
        }

        var headTags = metadataTags(for: mergedMetadata)

        if !mergedMetadata.structuredData.isEmpty {
            var graph = StructuredDataGraph(mergedMetadata.structuredData).deduplicated()
            if options.buildOptions.structuredDataValidationMode == .strict {
                do {
                    graph = try graph.validated()
                } catch let error as StructuredDataValidationError {
                    throw RenderError.structuredDataValidationFailed(error)
                }
            }

            let json = try graph.jsonLD(locale: locale)
            headTags.append("<script type=\"application/ld+json\">\(safeJSONForScript(json))</script>")
        }

        if options.includeCSS && !generatedCSS.content.isEmpty {
            headTags.append("<style>\(generatedCSS.content)</style>")
        }

        if options.includeJavaScript && !javascript.isEmpty {
            headTags.append("<script>\(javascript)</script>")
        }

        let html = "<!DOCTYPE html><html lang=\"\(mergedMetadata.locale.rawValue)\"><head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"><title>\(HTMLEscape.escape(mergedMetadata.pageTitle))</title>\(headTags.joined())</head><body>\(bodyNodes.map { $0.rendered() }.joined())</body></html>"

        return RenderedDocument(
            html: html,
            css: generatedCSS.content,
            javascript: javascript
        )
    }

    private static func merge(site: Metadata?, page: Metadata, locale: LocaleCode) -> Metadata {
        guard let site else {
            var page = page
            page.locale = locale
            return page
        }

        return Metadata(
            site: page.site ?? site.site,
            title: page.title ?? site.title,
            titleSeparator: page.titleSeparator,
            description: page.description ?? site.description,
            date: page.date ?? site.date,
            image: page.image ?? site.image,
            author: page.author ?? site.author,
            keywords: page.keywords.isEmpty ? site.keywords : page.keywords,
            twitter: page.twitter ?? site.twitter,
            locale: locale,
            type: page.type,
            themeColor: page.themeColor ?? site.themeColor,
            favicons: page.favicons.isEmpty ? site.favicons : page.favicons,
            canonicalURL: page.canonicalURL ?? site.canonicalURL,
            alternateURLs: page.alternateURLs.isEmpty ? site.alternateURLs : page.alternateURLs,
            structuredData: site.structuredData + page.structuredData
        )
    }

    private static func metadataTags(for metadata: Metadata) -> [String] {
        var tags: [String] = [
            "<meta property=\"og:title\" content=\"\(HTMLEscape.escapeAttribute(metadata.pageTitle))\">",
            "<meta property=\"og:type\" content=\"\(metadata.type.rawValue)\">",
            "<meta name=\"twitter:card\" content=\"summary_large_image\">",
        ]

        if let description = metadata.description, !description.isEmpty {
            tags.append("<meta name=\"description\" content=\"\(HTMLEscape.escapeAttribute(description))\">")
            tags.append("<meta property=\"og:description\" content=\"\(HTMLEscape.escapeAttribute(description))\">")
        }

        if let image = metadata.image, !image.isEmpty {
            tags.append("<meta property=\"og:image\" content=\"\(HTMLEscape.escapeAttribute(image))\">")
        }

        if let author = metadata.author, !author.isEmpty {
            tags.append("<meta name=\"author\" content=\"\(HTMLEscape.escapeAttribute(author))\">")
        }

        if !metadata.keywords.isEmpty {
            tags.append("<meta name=\"keywords\" content=\"\(HTMLEscape.escapeAttribute(metadata.keywords.joined(separator: ", ")))\">")
        }

        if let twitter = metadata.twitter, !twitter.isEmpty {
            tags.append("<meta name=\"twitter:creator\" content=\"@\(HTMLEscape.escapeAttribute(twitter))\">")
        }

        if let canonical = metadata.canonicalURL, !canonical.isEmpty {
            tags.append("<link rel=\"canonical\" href=\"\(HTMLEscape.escapeAttribute(canonical))\">")
        }
        if !metadata.alternateURLs.isEmpty {
            for locale in metadata.alternateURLs.keys.sorted() {
                guard let href = metadata.alternateURLs[locale] else { continue }
                tags.append("<link rel=\"alternate\" hreflang=\"\(HTMLEscape.escapeAttribute(locale.rawValue))\" href=\"\(HTMLEscape.escapeAttribute(href))\">")
            }
        }

        if let themeColor = metadata.themeColor {
            tags.append("<meta name=\"theme-color\" content=\"\(HTMLEscape.escapeAttribute(themeColor.light))\">")
            if let dark = themeColor.dark {
                tags.append("<meta name=\"theme-color\" content=\"\(HTMLEscape.escapeAttribute(dark))\" media=\"(prefers-color-scheme: dark)\">")
            }
        }

        for favicon in metadata.favicons {
            let sizeAttribute = favicon.size.map { " sizes=\"\(HTMLEscape.escapeAttribute($0))\"" } ?? ""
            tags.append("<link rel=\"icon\" type=\"\(favicon.type.rawValue)\" href=\"\(HTMLEscape.escapeAttribute(favicon.light))\"\(sizeAttribute)>")
            if let dark = favicon.dark {
                tags.append("<link rel=\"icon\" type=\"\(favicon.type.rawValue)\" href=\"\(HTMLEscape.escapeAttribute(dark))\" media=\"(prefers-color-scheme: dark)\"\(sizeAttribute)>")
            }
        }

        return tags
    }

    private static func safeJSONForScript(_ value: String) -> String {
        value.replacingOccurrences(of: "</script", with: "<\\/script")
    }

    private static func hasDOMRuntimeBindings(in nodes: [HTMLNode]) -> Bool {
        func walk(_ node: HTMLNode) -> Bool {
            switch node {
            case .text:
                return false
            case .element(let element):
                if element.attributes.contains(where: { $0.name.hasPrefix("data-ax-on-") || $0.name == RuntimeDOMCodec.statesAttributeName() }) {
                    return true
                }
                return element.children.contains(where: walk)
            }
        }

        return nodes.contains(where: walk)
    }

    private static func hasWasmBindings(in nodes: [HTMLNode]) -> Bool {
        func walk(_ node: HTMLNode) -> Bool {
            switch node {
            case .text:
                return false
            case .element(let element):
                if element.attributes.contains(where: { $0.name == WasmDOMCodec.moduleAttribute }) {
                    return true
                }
                return element.children.contains(where: walk)
            }
        }

        return nodes.contains(where: walk)
    }
}
