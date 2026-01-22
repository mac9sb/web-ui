import Foundation
import WebUI

public struct TypstCodeBlock: Element {
    private let code: String
    private let language: String?
    private let fileName: String?
    private let showLineNumbers: Bool
    private let showCopyButton: Bool
    private let classPrefix: String

    public init(
        _ code: String,
        classPrefix: String = "typst-",
        language: String? = nil,
        fileName: String? = nil,
        showLineNumbers: Bool = false,
        showCopyButton: Bool = true
    ) {
        self.code = code
        self.classPrefix = classPrefix
        self.language = language
        self.fileName = fileName
        self.showLineNumbers = showLineNumbers
        self.showCopyButton = showCopyButton
    }

    public var body: some Markup {
        MarkupString(
            content: Self.generateHTML(
                code: code,
                language: language,
                fileName: fileName,
                showLineNumbers: showLineNumbers,
                showCopyButton: showCopyButton,
                classPrefix: classPrefix
            ))
    }

    /// Generates the HTML string for the code block.
    public static func generateHTML(
        code: String,
        language: String?,
        fileName: String?,
        showLineNumbers: Bool,
        showCopyButton: Bool,
        classPrefix: String
    ) -> String {
        let lines = code.components(separatedBy: "\n")
        let lineCount = lines.count
        let langDisplay = language?.uppercased() ?? "TEXT"

        var html = "<div class=\"\(classPrefix)code-wrapper\">"

        // Header with copy button
        html += "<div class=\"\(classPrefix)code-header\">"
        html += "<span class=\"\(classPrefix)code-lang\">\(langDisplay)</span>"
        if showCopyButton {
            html += buildCopyButton(classPrefix: classPrefix)
        }
        html += "</div>"

        // Main Block
        html += "<div class=\"\(classPrefix)code-block-container\">"

        // Only escape HTML/XML/markup languages if no syntax highlighting has been applied
        let markupLanguages = ["html", "xml", "svg", "markdown", "json"]
        let hasSyntaxHighlighting = code.contains("<span class=")
        let shouldEscape = markupLanguages.contains(language?.lowercased() ?? "") && !hasSyntaxHighlighting

        // Code Area with optional line numbers
        if showLineNumbers && lineCount > 1 {
            html += "<div class=\"\(classPrefix)code-wrapper-grid\">"

            // Interleave line numbers and code lines in grid
            for (index, line) in lines.enumerated() {
                let lineNum = index + 1
                html += "<div class=\"\(classPrefix)code-number\">\(lineNum)</div>"
                let processedLine = shouldEscape ? escapeHTML(line) : line
                html += "<div class=\"\(classPrefix)code-line\"><code class=\"\(classPrefix)code\">\(processedLine)</code></div>"
            }

            html += "</div>"
        } else {
            let processedCode = shouldEscape ? escapeHTML(code) : code
            html += "<pre class=\"\(classPrefix)code-block\"><code class=\"\(classPrefix)code\">"
            html += processedCode
            html += "</code></pre>"
        }

        // Footer
        html += "<div class=\"\(classPrefix)code-footer\">"
        html += "<span class=\"\(classPrefix)code-footer-left\">UTF-8 // \(langDisplay)</span>"
        html += "<span class=\"\(classPrefix)code-footer-right\">LN \(lineCount)</span>"
        html += "</div>"

        html += "</div>"  // End block-container

        // Decorative corner accent
        html += "<div class=\"\(classPrefix)code-corner-accent\"></div>"

        html += "</div>"  // End wrapper

        return html
    }

    private static func escapeHTML(_ string: String) -> String {
        var escaped = ""
        for char in string {
            switch char {
            case "<":
                escaped += "&lt;"
            case ">":
                escaped += "&gt;"
            case "&":
                escaped += "&amp;"
            case "\"":
                escaped += "&quot;"
            case "'":
                escaped += "&#39;"
            default:
                escaped.append(char)
            }
        }
        return escaped
    }

    private static func buildCopyButton(classPrefix: String) -> String {
        """
        <button class="\(classPrefix)copy-btn" type="button" aria-label="Copy code">
            \(copyButtonIcon)
        </button>
        """
    }

    private static var copyButtonIcon: String {
        "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><rect x=\"9\" y=\"9\" width=\"13\" height=\"13\" rx=\"2\" ry=\"2\"></rect><path d=\"M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1\"></path></svg>"
    }
}

// Fluent Interface
extension TypstCodeBlock {
    public func language(_ value: String) -> TypstCodeBlock {
        TypstCodeBlock(code, classPrefix: classPrefix, language: value, fileName: fileName, showLineNumbers: showLineNumbers, showCopyButton: showCopyButton)
    }
    public func fileName(_ value: String) -> TypstCodeBlock {
        TypstCodeBlock(code, classPrefix: classPrefix, language: language, fileName: value, showLineNumbers: showLineNumbers, showCopyButton: showCopyButton)
    }
    public func showLineNumbers(_ value: Bool) -> TypstCodeBlock {
        TypstCodeBlock(code, classPrefix: classPrefix, language: language, fileName: fileName, showLineNumbers: value, showCopyButton: showCopyButton)
    }
    public func showCopyButton(_ value: Bool) -> TypstCodeBlock {
        TypstCodeBlock(code, classPrefix: classPrefix, language: language, fileName: fileName, showLineNumbers: showLineNumbers, showCopyButton: value)
    }
}

public struct TypstCodeBlockStyles: Sendable {
    private let classPrefix: String

    public init(classPrefix: String = "typst-") {
        self.classPrefix = classPrefix
    }

    public func generateCSS() -> String {
        """
        /* Retro-Futurist Terminal Theme */

        .\(classPrefix)code-wrapper {
            margin: 2.5rem 0;
            font-family: monospace;
            position: relative;
            z-index: 0;
        }

        /* Header */
        .\(classPrefix)code-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background-color: #000000;
            padding: 0.4rem 0.75rem;
            border: 1px solid #111817;
            border-bottom: none;
            border-top-left-radius: 2px;
            border-top-right-radius: 2px;
        }

        .\(classPrefix)code-lang {
            color: #14b8aa;
            font-size: 0.625rem;
            font-weight: 700;
            letter-spacing: 0.15em;
            text-transform: uppercase;
        }

        .\(classPrefix)copy-btn {
            background: none;
            border: none;
            cursor: pointer;
            width: 18px;
            height: 18px;
            padding: 0;
            margin: 0;
            color: #6b7280;
            transition: color 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .\(classPrefix)copy-btn:hover {
            color: #14b8aa;
        }

        .\(classPrefix)copy-btn svg {
            width: 100%;
            height: 100%;
            stroke: currentColor;
        }

        /* Main Block */
        .\(classPrefix)code-block-container {
            background-color: #000000;
            border: 1px solid #111817;
            border-top: none;
            border-bottom-left-radius: 2px;
            border-bottom-right-radius: 2px;
            overflow: hidden;
            position: relative;
            z-index: 10;
        }

        .\(classPrefix)code-wrapper-grid {
            display: grid;
            grid-template-columns: auto 1fr;
            padding: 0.5rem 1.25rem;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            gap: 0;
            align-items: stretch;
        }

        .\(classPrefix)code-number {
            color: #6b7280;
            font-size: 12px;
            user-select: none;
            font-family: monospace;
            padding-right: 0.75rem;
            margin-right: 0.75rem;
            border-right: 1px solid rgba(255, 255, 255, 0.1);
            min-width: 1.5rem;
            display: flex;
            align-items: center;
            justify-content: flex-end;
        }

        .\(classPrefix)code-line {
            display: flex;
            align-items: center;
            line-height: 1.4;
            overflow-x: auto;
            white-space: pre;
        }

        .\(classPrefix)code-line code {
            display: block;
            font-size: 12px;
            color: #ffffff;
            background: none !important;
            border: none;
            padding: 0;
            margin: 0;
            white-space: pre;
            font-family: monospace;
            letter-spacing: 0;
            flex: 1;
        }

        .\(classPrefix)code-wrapper-with-numbers {
            display: flex;
            align-items: flex-start;
            padding: 0.5rem 1.25rem 1.25rem 1.25rem;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            gap: 0;
        }

        .\(classPrefix)code-numbers-column {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            border-right: 1px solid rgba(255, 255, 255, 0.1);
            padding-right: 0.75rem;
            margin-right: 0.75rem;
            flex-shrink: 0;
        }

        .\(classPrefix)code-number-row {
            color: #6b7280;
            font-size: 12px;
            text-align: right;
            user-select: none;
            font-family: monospace;
            line-height: 1.4;
            height: 1.4em;
            display: flex;
            align-items: center;
            justify-content: flex-end;
            min-width: 1.5rem;
        }

        .\(classPrefix)code-lines-column {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            flex: 1;
            overflow-x: auto;
        }

        .\(classPrefix)code-line-row {
            line-height: 1.4;
            height: 1.4em;
            display: flex;
            align-items: center;
            white-space: pre;
            overflow-x: auto;
        }

        .\(classPrefix)code-line-row code {
            display: inline;
            font-size: 12px;
            color: #ffffff;
            background: none !important;
            border: none;
            padding: 0;
            margin: 0;
            white-space: pre;
            font-family: monospace;
            letter-spacing: 0;
            flex-shrink: 0;
        }

        .\(classPrefix)code-wrapper-inner {
            display: flex;
            align-items: stretch;
            gap: 0;
            padding: 1.25rem 1.25rem 0.5rem 1.25rem;
        }

        .\(classPrefix)code-block {
            flex: 1;
            margin: 0;
            padding: 0;
            overflow-x: auto;
            background: transparent;
            line-height: 1.4;
        }

        .\(classPrefix)code-block code {
            display: block;
            font-size: 12px;
            line-height: 1.4;
            color: #ffffff;
            background: none;
            border: none;
            padding: 0;
            margin: 0;
            white-space: pre;
            font-family: monospace;
            letter-spacing: 0;
        }

        /* Line Numbers */
        .\(classPrefix)code-line-numbers {
            display: flex;
            flex-direction: column;
            color: #6b7280;
            font-size: 12px;
            text-align: right;
            line-height: 1.4;
            user-select: none;
            border-right: 1px solid rgba(255, 255, 255, 0.1);
            padding-right: 1rem;
            margin-right: 1rem;
            flex-shrink: 0;
            font-family: monospace;
            padding-left: 0;
        }

        .\(classPrefix)code-line-numbers span {
            height: 1.4em;
            display: flex;
            align-items: center;
            justify-content: flex-end;
            line-height: 1.4;
        }
        /* Syntax highlighting classes */
        .\(classPrefix)code .kw { color: #14b8aa !important; }
        .\(classPrefix)code .typ { color: #f472b6 !important; }
        .\(classPrefix)code .str { color: #fca5a5 !important; }
        .\(classPrefix)code .num { color: #60a5fa !important; }
        .\(classPrefix)code .com { color: #6b7280 !important; font-style: italic; }

        /* Footer */
        .\(classPrefix)code-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            padding: 0.5rem 1.25rem;
            font-size: 0.7rem;
            color: #6b7280;
            font-family: monospace;
            letter-spacing: 0.05em;
        }

        .\(classPrefix)code-footer-left {
            color: #6b7280;
        }

        .\(classPrefix)code-footer-right {
            color: #6b7280;
        }

        /* Dark Mode Adjustments */
        @media (prefers-color-scheme: dark) {
            .\(classPrefix)code-header {
                border-color: #333;
            }
            .\(classPrefix)code-block-container {
                border-color: #333;
            }
        }

        """
    }

    public func generateCopyScript() -> String {
        """
        <script>
        (function() {
            const copyButtonClass = '\(classPrefix)copy-btn';
            const copiedClass = 'copied';
            const svgCopy = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>';
            const svgCheck = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>';

            document.querySelectorAll('.' + copyButtonClass).forEach(function(btn) {
                btn.addEventListener('click', function(e) {
                    e.preventDefault();
                    const wrapper = this.closest('.\(classPrefix)code-wrapper');
                    const codeElement = wrapper.querySelector('code');
                    const text = codeElement.textContent || codeElement.innerText;

                    navigator.clipboard.writeText(text).then(function() {
                        btn.innerHTML = svgCheck;
                        btn.classList.add(copiedClass);
                        setTimeout(function() {
                            btn.innerHTML = svgCopy;
                            btn.classList.remove(copiedClass);
                        }, 2000);
                    }).catch(function(err) {
                        console.error('Copy failed:', err);
                    });
                });
            });
        })();
        </script>
        """
    }
}
