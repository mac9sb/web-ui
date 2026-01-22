import Foundation

public struct TypstArticleStyles: Sendable {
    public var classPrefix: String

    public init(classPrefix: String = "typst-") {
        self.classPrefix = classPrefix
    }

    public func generateCSS() -> String {
        """
        /* Base Styles for Body and Brutalist Border */
        body {
            background-color: #f6f8f8;
            background-image: radial-gradient(rgba(20, 184, 170, 0.03) 0.5px, transparent 0.5px);
            background-size: 24px 24px;
            font-family: 'Space Grotesk', sans-serif;
            color: #111817;
        }

        /* Article Container - Max Width and Centering */
        .article-container {
            max-width: 680px;
            margin: 0 auto;
            background-color: transparent;
        }

        /* Article Header Section */
        .article-header-section {
            padding: 3rem 1rem 0.5rem;
        }

        .article-header-title {
            color: #111817;
            font-size: 36px;
            font-weight: 700;
            line-height: 1.2;
            text-transform: uppercase;
            letter-spacing: -0.02em;
        }

        .article-header-subtitle {
            color: #14b8aa;
        }

        /* Article Meta Information (Published Date, Version) */
        .article-meta-info {
            padding: 0.5rem 1rem;
            border-top: 1px solid rgba(0, 0, 0, 0.1);
            border-bottom: 1px solid rgba(0, 0, 0, 0.1);
            color: #638885;
            font-size: 10px;
            font-weight: 700;
            line-height: normal;
            letter-spacing: 0.2em;
            text-transform: uppercase;
            margin-bottom: 1.5rem;
        }

        /* Introduction Paragraph */
        .article-intro-paragraph {
            margin-bottom: 2rem;
            color: #111817;
            font-size: 1rem;
            font-weight: 400;
            line-height: 1.625;
            padding: 0 1rem;
        }

        /* Generic Typst Content Styling */
        .typst-content {
            padding: 0 1rem;
            color: #111817;
            line-height: 1.6;
            font-size: 1rem;
        }

        .typst-content h1,
        .typst-content h2,
        .typst-content h3,
        .typst-content h4 {
            color: #111817;
            margin-top: 2.5rem;
            margin-bottom: 1rem;
            font-weight: 600;
        }
        .typst-content h1 { font-size: 2rem; }
        .typst-content h2 {
            font-size: 1.5rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid #111817;
        }
        .typst-content h3 { font-size: 1.25rem; }

        .typst-content p {
            margin-bottom: 1.5rem;
        }

        .typst-content a {
            color: #14b8aa;
            text-decoration: none;
            border-bottom: 1px solid rgba(20, 184, 170, 0.3);
        }
        .typst-content a:hover {
            color: #0d9488;
            border-bottom-color: #0d9488;
        }

        .typst-content strong {
            color: #111817;
            font-weight: 600;
        }
        .typst-content em {
            font-style: italic;
        }

        /* Inline Code */
        .typst-content code {
            background: #e5e7eb;
            color: #14b8aa;
            padding: 0.2em 0.4em;
            font-family: monospace;
            font-size: 0.875em;
            border: 1px solid #d1d5db;
        }

        /* Blockquote */
        .typst-content .typst-blockquote {
            border-left: 3px solid #14b8aa;
            background: #f3f4f6;
            padding: 1rem 1.5rem;
            margin: 1.5rem 0;
            font-style: italic;
            color: #4b5563;
        }

        /* Lists */
        .typst-content ul,
        .typst-content ol {
            margin: 1.5rem 0;
            padding-left: 1.5rem;
        }
        .typst-content li {
            margin-bottom: 0.75rem;
        }
        .typst-content ul li::marker,
        .typst-content ol li::marker {
            color: #14b8aa;
        }

        /* Horizontal Rule */
        .typst-content hr {
            border: none;
            height: 1px;
            background: #111817;
            margin: 2.5rem 0;
        }

        /* Images */
        .typst-content img {
            max-width: 100%;
            border: 1px solid #111817;
            margin: 1rem 0;
        }

        /* Tables */
        .typst-content table {
            width: 100%;
            border-collapse: collapse;
            margin: 1.5rem 0;
            border: 1px solid #111817;
        }
        .typst-content th,
        .typst-content td {
            padding: 0.75rem 1rem;
            border: 1px solid #111817;
            text-align: left;
        }
        .typst-content th {
            background: #111817;
            color: #ffffff;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.05em;
        }
        .typst-content tr:nth-child(even) {
            background: #f3f4f6;
        }

        /* Dark Mode Styles */
        @media (prefers-color-scheme: dark) {
            body {
                background-color: #112120;
                background-image: radial-gradient(rgba(20, 184, 170, 0.08) 0.5px, transparent 0.5px);
            }
            .article-container {
                background-color: transparent;
                color: #e5e7eb;
            }
            .article-header-title {
                color: #ffffff;
            }
            .article-meta-info {
                border-top-color: rgba(255, 255, 255, 0.1);
                border-bottom-color: rgba(255, 255, 255, 0.1);
                color: #14b8aa;
            }
            .article-intro-paragraph {
                color: #e5e7eb;
            }
            .typst-content {
                color: #e5e7eb;
            }
            .typst-content h1,
            .typst-content h2,
            .typst-content h3,
            .typst-content h4 {
                color: #ffffff;
            }
            .typst-content h2 {
                border-bottom-color: #111817;
            }
            .typst-content a {
                color: #14b8aa;
                border-bottom-color: rgba(20, 184, 170, 0.3);
            }
            .typst-content a:hover {
                color: #2dd4bf;
                border-bottom-color: #2dd4bf;
            }
            .typst-content strong {
                color: #ffffff;
            }
            .typst-content code {
                background: #1f2937;
                color: #14b8aa;
                border-color: #374151;
            }
            .typst-content .typst-blockquote {
                background: #1f2937;
                border-left-color: #14b8aa;
                color: #9ca3af;
            }
            .typst-content hr {
                background: #111817;
            }
            .typst-content img {
                border-color: #111817;
            }
            .typst-content table {
                border-color: #111817;
            }
            .typst-content th,
            .typst-content td {
                border-color: #111817;
            }
            .typst-content th {
                background: #111817;
            }
            .typst-content tr:nth-child(even) {
                background: #1f2937;
            }
        }
        """
    }
}
