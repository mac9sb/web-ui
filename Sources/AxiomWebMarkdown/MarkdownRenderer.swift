import Foundation
import AxiomWebUI
import AxiomWebI18n

public struct MarkdownStyleClasses: Sendable {
    public var container: String
    public var paragraph: String
    public var headingPrefix: String
    public var list: String
    public var listItem: String
    public var blockquote: String
    public var codeBlock: String
    public var inlineCode: String
    public var admonition: String
    public var admonitionTitle: String

    public init(
        container: String = "markdown-content",
        paragraph: String = "markdown-paragraph",
        headingPrefix: String = "markdown-heading-",
        list: String = "markdown-list",
        listItem: String = "markdown-list-item",
        blockquote: String = "markdown-blockquote",
        codeBlock: String = "markdown-code",
        inlineCode: String = "markdown-inline-code",
        admonition: String = "admonition",
        admonitionTitle: String = "admonition-title"
    ) {
        self.container = container
        self.paragraph = paragraph
        self.headingPrefix = headingPrefix
        self.list = list
        self.listItem = listItem
        self.blockquote = blockquote
        self.codeBlock = codeBlock
        self.inlineCode = inlineCode
        self.admonition = admonition
        self.admonitionTitle = admonitionTitle
    }
}

public struct MarkdownRenderingOptions: Sendable {
    public var syntaxHighlighting: Bool
    public var admonitions: Bool
    public var classes: MarkdownStyleClasses

    public init(
        syntaxHighlighting: Bool = true,
        admonitions: Bool = true,
        classes: MarkdownStyleClasses = .init()
    ) {
        self.syntaxHighlighting = syntaxHighlighting
        self.admonitions = admonitions
        self.classes = classes
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
        let lines = markdown.replacingOccurrences(of: "\r\n", with: "\n").components(separatedBy: "\n")
        var index = 0
        var children: [HTMLNode] = []

        while index < lines.count {
            let line = lines[index]
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                index += 1
                continue
            }

            if line.hasPrefix("```") {
                children.append(renderCodeBlock(lines: lines, index: &index, options: options))
                continue
            }

            if options.admonitions,
               let admonition = parseAdmonition(lines: lines, index: &index, options: options) {
                children.append(admonition)
                continue
            }

            if let heading = parseHeading(line: line, options: options) {
                children.append(heading)
                index += 1
                continue
            }

            if isUnorderedListLine(trimmed) {
                children.append(renderUnorderedList(lines: lines, index: &index, options: options))
                continue
            }

            if orderedListItemText(from: trimmed) != nil {
                children.append(renderOrderedList(lines: lines, index: &index, options: options))
                continue
            }

            if trimmed.hasPrefix(">") {
                children.append(renderBlockquote(lines: lines, index: &index, options: options))
                continue
            }

            children.append(renderParagraph(lines: lines, index: &index, options: options))
        }

        return RenderedMarkdown(nodes: [
            .element(
                HTMLElementNode(
                    tag: "div",
                    attributes: classAttributes(options.classes.container),
                    children: children
                )
            )
        ])
    }
}

private func renderCodeBlock(lines: [String], index: inout Int, options: MarkdownRenderingOptions) -> HTMLNode {
    let fence = lines[index]
    let info = String(fence.dropFirst(3)).trimmingCharacters(in: .whitespacesAndNewlines)
    let language = info.split(separator: " ").first.map(String.init) ?? ""
    index += 1

    var codeLines: [String] = []
    while index < lines.count, !lines[index].hasPrefix("```") {
        codeLines.append(lines[index])
        index += 1
    }
    if index < lines.count {
        index += 1
    }

    var codeClass = options.classes.codeBlock
    if options.syntaxHighlighting, !language.isEmpty {
        codeClass += " language-\(language)"
    }

    return .element(
        HTMLElementNode(
            tag: "pre",
            attributes: classAttributes(codeClass),
            children: [
                .element(
                    HTMLElementNode(
                        tag: "code",
                        attributes: language.isEmpty ? [] : [HTMLAttribute("data-language", language)],
                        children: [.text(codeLines.joined(separator: "\n"))]
                    )
                )
            ]
        )
    )
}

private func parseAdmonition(
    lines: [String],
    index: inout Int,
    options: MarkdownRenderingOptions
) -> HTMLNode? {
    let line = lines[index]
    guard line.hasPrefix("> [!"), let end = line.firstIndex(of: "]") else {
        return nil
    }

    let markerStart = line.index(line.startIndex, offsetBy: 4)
    let marker = String(line[markerStart..<end]).lowercased()
    let titleRemainder = line[line.index(after: end)...].trimmingCharacters(in: .whitespaces)
    let title = titleRemainder.isEmpty ? marker.capitalized : titleRemainder

    index += 1
    var bodyLines: [String] = []
    while index < lines.count {
        let raw = lines[index]
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        if !trimmed.hasPrefix(">") || trimmed.hasPrefix("> [!") {
            break
        }
        bodyLines.append(trimmed.dropFirst().trimmingCharacters(in: .whitespaces))
        index += 1
    }

    return .element(
        HTMLElementNode(
            tag: "aside",
            attributes: classAttributes("\(options.classes.admonition) \(options.classes.admonition)-\(marker)"),
            children: [
                .element(
                    HTMLElementNode(
                        tag: "p",
                        attributes: classAttributes(options.classes.admonitionTitle),
                        children: [.text(title)]
                    )
                ),
                .element(
                    HTMLElementNode(
                        tag: "p",
                        attributes: classAttributes(options.classes.paragraph),
                        children: inlineNodes(from: bodyLines.joined(separator: " "), options: options)
                    )
                ),
            ]
        )
    )
}

private func parseHeading(line: String, options: MarkdownRenderingOptions) -> HTMLNode? {
    let trimmed = line.trimmingCharacters(in: .whitespaces)
    let level = headingLevel(trimmed)
    guard level > 0 else {
        return nil
    }

    let prefixLength = min(trimmed.count, level + 1)
    let value = String(trimmed.dropFirst(prefixLength)).trimmingCharacters(in: .whitespaces)
    return .element(
        HTMLElementNode(
            tag: "h\(level)",
            attributes: classAttributes("\(options.classes.headingPrefix)\(level)"),
            children: inlineNodes(from: value, options: options)
        )
    )
}

private func renderUnorderedList(lines: [String], index: inout Int, options: MarkdownRenderingOptions) -> HTMLNode {
    var items: [HTMLNode] = []
    while index < lines.count {
        let trimmed = lines[index].trimmingCharacters(in: .whitespaces)
        guard isUnorderedListLine(trimmed) else { break }
        let value = String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces)
        items.append(
            .element(
                HTMLElementNode(
                    tag: "li",
                    attributes: classAttributes(options.classes.listItem),
                    children: inlineNodes(from: value, options: options)
                )
            )
        )
        index += 1
    }

    return .element(
        HTMLElementNode(
            tag: "ul",
            attributes: classAttributes(options.classes.list),
            children: items
        )
    )
}

private func renderOrderedList(lines: [String], index: inout Int, options: MarkdownRenderingOptions) -> HTMLNode {
    var items: [HTMLNode] = []
    while index < lines.count {
        let trimmed = lines[index].trimmingCharacters(in: .whitespaces)
        guard let value = orderedListItemText(from: trimmed) else { break }
        items.append(
            .element(
                HTMLElementNode(
                    tag: "li",
                    attributes: classAttributes(options.classes.listItem),
                    children: inlineNodes(from: value, options: options)
                )
            )
        )
        index += 1
    }

    return .element(
        HTMLElementNode(
            tag: "ol",
            attributes: classAttributes(options.classes.list),
            children: items
        )
    )
}

private func renderBlockquote(lines: [String], index: inout Int, options: MarkdownRenderingOptions) -> HTMLNode {
    var content: [String] = []
    while index < lines.count {
        let trimmed = lines[index].trimmingCharacters(in: .whitespaces)
        guard trimmed.hasPrefix(">"), !trimmed.hasPrefix("> [!") else { break }
        content.append(trimmed.dropFirst().trimmingCharacters(in: .whitespaces))
        index += 1
    }

    return .element(
        HTMLElementNode(
            tag: "blockquote",
            attributes: classAttributes(options.classes.blockquote),
            children: [
                .element(
                    HTMLElementNode(
                        tag: "p",
                        attributes: classAttributes(options.classes.paragraph),
                        children: inlineNodes(from: content.joined(separator: " "), options: options)
                    )
                )
            ]
        )
    )
}

private func renderParagraph(lines: [String], index: inout Int, options: MarkdownRenderingOptions) -> HTMLNode {
    var content: [String] = []
    while index < lines.count {
        let line = lines[index]
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty || isBlockBoundary(line: line, trimmed: trimmed, options: options) {
            break
        }
        content.append(trimmed)
        index += 1
    }

    return .element(
        HTMLElementNode(
            tag: "p",
            attributes: classAttributes(options.classes.paragraph),
            children: inlineNodes(from: content.joined(separator: " "), options: options)
        )
    )
}

private func inlineNodes(from text: String, options: MarkdownRenderingOptions) -> [HTMLNode] {
    guard text.contains("`") else {
        return [.text(text)]
    }

    var nodes: [HTMLNode] = []
    var cursor = text.startIndex

    while cursor < text.endIndex {
        guard let startTick = text[cursor...].firstIndex(of: "`") else {
            let remaining = String(text[cursor...])
            if !remaining.isEmpty {
                nodes.append(.text(remaining))
            }
            break
        }

        let before = String(text[cursor..<startTick])
        if !before.isEmpty {
            nodes.append(.text(before))
        }

        let searchStart = text.index(after: startTick)
        guard let endTick = text[searchStart...].firstIndex(of: "`") else {
            nodes.append(.text(String(text[startTick...])))
            break
        }

        let value = String(text[searchStart..<endTick])
        nodes.append(
            .element(
                HTMLElementNode(
                    tag: "code",
                    attributes: classAttributes(options.classes.inlineCode),
                    children: [.text(value)]
                )
            )
        )
        cursor = text.index(after: endTick)
    }

    return nodes
}

private func classAttributes(_ className: String) -> [HTMLAttribute] {
    let trimmed = className.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
        return []
    }
    return [HTMLAttribute("class", trimmed)]
}

private func headingLevel(_ line: String) -> Int {
    let hashes = line.prefix(while: { $0 == "#" }).count
    guard (1...6).contains(hashes), line.dropFirst(hashes).hasPrefix(" ") else {
        return 0
    }
    return hashes
}

private func isUnorderedListLine(_ line: String) -> Bool {
    line.hasPrefix("- ") || line.hasPrefix("* ") || line.hasPrefix("+ ")
}

private func orderedListItemText(from line: String) -> String? {
    var digits = ""
    var index = line.startIndex
    while index < line.endIndex, line[index].isNumber {
        digits.append(line[index])
        index = line.index(after: index)
    }
    guard !digits.isEmpty, index < line.endIndex, line[index] == "." else {
        return nil
    }
    index = line.index(after: index)
    guard index < line.endIndex, line[index] == " " else {
        return nil
    }
    let value = String(line[line.index(after: index)...]).trimmingCharacters(in: .whitespaces)
    return value.isEmpty ? nil : value
}

private func isBlockBoundary(line: String, trimmed: String, options: MarkdownRenderingOptions) -> Bool {
    if line.hasPrefix("```") {
        return true
    }
    if options.admonitions, trimmed.hasPrefix("> [!") {
        return true
    }
    if headingLevel(trimmed) > 0 {
        return true
    }
    if isUnorderedListLine(trimmed) || orderedListItemText(from: trimmed) != nil {
        return true
    }
    if trimmed.hasPrefix(">") {
        return true
    }
    return false
}
