import Foundation
import AxiomWebUI
import AxiomWebI18n

public struct MarkdownRenderingOptions: Sendable {
    public var syntaxHighlighting: Bool
    public var admonitions: Bool

    public init(syntaxHighlighting: Bool = true, admonitions: Bool = true) {
        self.syntaxHighlighting = syntaxHighlighting
        self.admonitions = admonitions
    }
}

public struct RenderedMarkdown: Markup {
    private let nodes: [HTMLNode]

    public init(nodes: [HTMLNode]) {
        self.nodes = nodes
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        nodes
    }
}

public enum MarkdownRenderer {
    public static func render(_ markdown: String, options: MarkdownRenderingOptions = .init()) -> RenderedMarkdown {
        var nodes: [HTMLNode] = []
        let lines = markdown.components(separatedBy: .newlines)
        var index = 0

        while index < lines.count {
            let line = lines[index]

            if line.hasPrefix("```") {
                let language = line.dropFirst(3).trimmingCharacters(in: .whitespacesAndNewlines)
                index += 1
                var codeLines: [String] = []
                while index < lines.count, !lines[index].hasPrefix("```") {
                    codeLines.append(lines[index])
                    index += 1
                }
                let codeValue = codeLines.joined(separator: "\n")
                var preClass = "markdown-code"
                if options.syntaxHighlighting, !language.isEmpty {
                    preClass += " language-\(language)"
                }
                nodes.append(
                    .element(
                        HTMLElementNode(
                            tag: "pre",
                            attributes: [HTMLAttribute("class", preClass)],
                            children: [
                                .element(HTMLElementNode(tag: "code", children: [.text(codeValue)]))
                            ]
                        )
                    )
                )
                index += 1
                continue
            }

            if options.admonitions, line.hasPrefix("> [!"), line.contains("]") {
                let marker = String(line.dropFirst(4).prefix { $0 != "]" }).lowercased()
                var contentLines: [String] = []
                index += 1
                while index < lines.count, lines[index].hasPrefix(">") {
                    contentLines.append(lines[index].dropFirst().trimmingCharacters(in: .whitespaces))
                    index += 1
                }
                nodes.append(
                    .element(
                        HTMLElementNode(
                            tag: "aside",
                            attributes: [HTMLAttribute("class", "admonition admonition-\(marker)")],
                            children: [
                                .element(HTMLElementNode(tag: "p", attributes: [HTMLAttribute("class", "admonition-title")], children: [.text(marker.uppercased())])),
                                .element(HTMLElementNode(tag: "p", children: [.text(contentLines.joined(separator: " "))]))
                            ]
                        )
                    )
                )
                continue
            }

            if line.hasPrefix("# ") {
                nodes.append(.element(HTMLElementNode(tag: "h1", children: [.text(String(line.dropFirst(2)))])))
            } else if line.hasPrefix("## ") {
                nodes.append(.element(HTMLElementNode(tag: "h2", children: [.text(String(line.dropFirst(3)))])))
            } else if !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                nodes.append(.element(HTMLElementNode(tag: "p", children: [.text(line)])))
            }

            index += 1
        }

        return RenderedMarkdown(nodes: [.element(HTMLElementNode(tag: "div", attributes: [HTMLAttribute("class", "markdown-content")], children: nodes))])
    }
}
