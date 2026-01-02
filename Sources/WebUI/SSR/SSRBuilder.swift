import Foundation

/// Server-side rendering CSS builder for generating global and page-specific CSS files.
///
/// SSRBuilder analyzes multiple Document instances at build time to:
/// - Identify CSS classes shared across multiple pages (global CSS)
/// - Generate page-specific CSS for unique classes
/// - Write CSS files to the configured output directory
///
/// ## Architecture
///
/// The builder operates in three phases:
/// 1. **Collection**: Render each page to collect its CSS classes
/// 2. **Analysis**: Identify shared vs. page-specific classes
/// 3. **Generation**: Write global.css and page-{slug}.css files
///
/// ## Usage
///
/// ```swift
/// let pages: [(Document, String)] = [
///     (LandingPage(), "index"),
///     (PricingPage(), "pricing")
/// ]
///
/// let builder = SSRBuilder(config: .ssrDefault)
/// try builder.generateCSS(for: pages)
/// ```
///
/// This generates:
/// - `Public/styles/global.css` - Classes used on 2+ pages
/// - `Public/styles/page-index.css` - Classes only on landing page
/// - `Public/styles/page-pricing.css` - Classes only on pricing page
///
/// - SeeAlso: ``CSSOutputConfig``, ``CSSWriter``, ``ClassCollector``
public struct SSRBuilder {
    /// Output configuration
    public let config: CSSOutputConfig

    /// Minimum number of pages a class must appear on to be considered "global"
    /// Default: 2 (appears on at least 2 pages)
    public let globalThreshold: Int

    /// Creates a new SSR builder.
    ///
    /// - Parameters:
    ///   - config: Output configuration (default: .ssrDefault)
    ///   - globalThreshold: Minimum pages for global CSS (default: 2)
    public init(config: CSSOutputConfig = .ssrDefault, globalThreshold: Int = 2) {
        self.config = config
        self.globalThreshold = globalThreshold
    }

    /// Generates CSS files for all provided pages.
    ///
    /// - Parameter pages: Array of (any Document, slug) tuples
    /// - Throws: File I/O errors
    public func generateCSS(for pages: [(any Document, String)]) throws {
        // Phase 1: Collection - Render each page and collect its classes
        var pageClasses: [String: Set<String>] = [:]

        for (page, slug) in pages {
            ClassCollector.shared.clear()

            // Render the page body to collect classes (don't need full HTML)
            _ = page.body.render()

            // Store the collected classes for this page
            pageClasses[slug] = Set(ClassCollector.shared.getClasses())
        }

        // Phase 2: Analysis - Identify shared vs. page-specific classes
        let analysis = analyzeClasses(pageClasses)

        // Phase 3: Generation - Write CSS files
        let writer = CSSWriter(config: config)

        // Generate and write global CSS (if any shared classes exist)
        if !analysis.globalClasses.isEmpty {
            let globalCSS = CSSGenerator.generateCSS(for: Array(analysis.globalClasses).sorted())
            try writer.writeGlobalCSS(globalCSS)
        }

        // Generate and write page-specific CSS
        for (slug, classes) in analysis.pageSpecificClasses {
            if !classes.isEmpty {
                let pageCSS = CSSGenerator.generateCSS(for: Array(classes).sorted())
                try writer.writePageCSS(pageCSS, slug: slug)
            }
        }
    }

    /// Analyzes collected classes to identify global vs. page-specific CSS.
    ///
    /// - Parameter pageClasses: Dictionary mapping slug -> Set of classes
    /// - Returns: Analysis result with global and page-specific classes
    private func analyzeClasses(_ pageClasses: [String: Set<String>]) -> ClassAnalysis {
        var classUsageCount: [String: Int] = [:]
        var classToPages: [String: Set<String>] = [:]

        // Count how many pages use each class
        for (slug, classes) in pageClasses {
            for className in classes {
                classUsageCount[className, default: 0] += 1
                classToPages[className, default: []].insert(slug)
            }
        }

        // Identify global classes (used on globalThreshold+ pages)
        let globalClasses = Set(
            classUsageCount
                .filter { $0.value >= globalThreshold }
                .map { $0.key }
        )

        // Build page-specific class sets (excluding global classes)
        var pageSpecificClasses: [String: Set<String>] = [:]
        for (slug, classes) in pageClasses {
            pageSpecificClasses[slug] = classes.subtracting(globalClasses)
        }

        return ClassAnalysis(
            globalClasses: globalClasses,
            pageSpecificClasses: pageSpecificClasses,
            classUsageCount: classUsageCount
        )
    }
}

/// Result of CSS class analysis for SSR generation.
struct ClassAnalysis {
    /// Classes used on multiple pages (global CSS)
    let globalClasses: Set<String>

    /// Classes specific to each page
    let pageSpecificClasses: [String: Set<String>]

    /// Usage count for each class (for debugging)
    let classUsageCount: [String: Int]
}
