import Foundation

/// Server-side rendering CSS builder for generating global, shared, and page-specific CSS files.
///
/// SSRBuilder analyzes multiple Document instances at build time to:
/// - Identify CSS classes shared across multiple pages (global + shared bundles)
/// - Generate page-specific CSS for unique classes
/// - Write CSS files to the configured output directory
/// - Emit a manifest describing which CSS files each page should include
///
/// ## Architecture
///
/// The builder operates in three phases:
/// 1. **Collection**: Render each page to collect its CSS classes
/// 2. **Analysis**: Group classes by the set of pages they appear on
/// 3. **Generation**: Write global/shared/page CSS files + manifest
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
/// let manifest = try builder.generateCSS(for: pages)
/// ```
public struct SSRBuilder {
    /// Output configuration
    public let config: CSSOutputConfig

    /// Minimum number of pages a class must appear on to be considered for shared/global bundles
    /// Default: 2 (appears on at least 2 pages)
    public let globalThreshold: Int

    /// Creates a new SSR builder.
    ///
    /// - Parameters:
    ///   - config: Output configuration (default: .ssrDefault)
    ///   - globalThreshold: Minimum pages for shared/global CSS (default: 2)
    public init(config: CSSOutputConfig = .ssrDefault, globalThreshold: Int = 2) {
        self.config = config
        self.globalThreshold = globalThreshold
    }

    /// Generates CSS files for all provided pages, writes a manifest, and returns it.
    ///
    /// - Parameter pages: Array of (any Document, slug) tuples
    /// - Returns: CSS bundle manifest describing which CSS files each page should include.
    /// - Throws: File I/O errors
    @discardableResult
    public func generateCSS(for pages: [(any Document, String)]) throws -> CSSBundleManifest {
        // Phase 1: Collection - Render each page and collect its classes
        var pageClasses: [String: Set<String>] = [:]
        let slugs = pages.map { $0.1 }
        let effectiveThreshold = min(globalThreshold, slugs.count)

        for (page, slug) in pages {
            ClassCollector.shared.clear()

            // Add safelist classes if provided
            if let safelist = page.cssSafelist {
                ClassCollector.shared.addSafelistClasses(safelist)
            }

            // Render the page body to collect classes (don't need full HTML)
            _ = page.body.render()

            // Store the collected classes for this page
            pageClasses[slug] = Set(ClassCollector.shared.getClasses())
        }

        // Phase 2: Analysis - Identify shared/global/page-specific classes
        let analysis = analyzeClasses(pageClasses)

        // Phase 3: Generation - Write CSS files and manifest
        let writer = CSSWriter(config: config)

        // Global bundle: classes used by all pages
        let globalCSS = CSSGenerator.generateCSS(
            for: Array(analysis.globalClasses).sorted(),
            includeBaseStyles: true
        )
        try writer.writeGlobalCSS(globalCSS)

        // Shared bundles: classes used by 2+ pages (but not all pages)
        var bundleNameForPageSet: [Set<String>: String] = [:]
        var bundleToPages: [String: [String]] = [:]
        var bundleToClasses: [String: Set<String>] = [:]

        for (pageSet, classes) in analysis.sharedClassesByPageSet {
            guard pageSet.count >= effectiveThreshold else { continue }
            let bundleName = bundleNameForPageSet[pageSet] ?? makeBundleName(from: pageSet)
            bundleNameForPageSet[pageSet] = bundleName
            bundleToPages[bundleName] = pageSet.sorted()
            bundleToClasses[bundleName] = classes
        }

        for (bundleName, classes) in bundleToClasses {
            guard !classes.isEmpty else { continue }
            let css = CSSGenerator.generateCSS(
                for: Array(classes).sorted(),
                includeBaseStyles: false
            )
            try writer.writeSharedCSS(css, name: bundleName)
        }

        // Page-specific CSS (classes used on only one page)
        for (slug, classes) in analysis.pageSpecificClasses {
            if !classes.isEmpty {
                let pageCSS = CSSGenerator.generateCSS(
                    for: Array(classes).sorted(),
                    includeBaseStyles: false
                )
                try writer.writePageCSS(pageCSS, slug: slug)
            }
        }

        // Build manifest describing CSS files per page
        var pageCSSFiles: [String: [String]] = [:]
        for slug in slugs {
            var files: [String] = [writer.globalCSSPath()]

            // Add shared bundles for this slug
            let sortedBundleNames = bundleToPages.keys.sorted()
            for bundleName in sortedBundleNames {
                if let pagesForBundle = bundleToPages[bundleName], pagesForBundle.contains(slug) {
                    files.append(writer.sharedCSSPath(name: bundleName))
                }
            }

            // Add page-specific CSS if present
            if let classes = analysis.pageSpecificClasses[slug], !classes.isEmpty {
                files.append(writer.pageCSSPath(slug: slug))
            }

            pageCSSFiles[slug] = files
        }

        let manifest = CSSBundleManifest(
            bundles: bundleToPages,
            pageCSSFiles: pageCSSFiles
        )

        try writeManifest(manifest, writer: writer)
        return manifest
    }

    /// Analyzes collected classes to identify global, shared, and page-specific CSS.
    private func analyzeClasses(_ pageClasses: [String: Set<String>]) -> ClassAnalysis {
        var classToPages: [String: Set<String>] = [:]

        for (slug, classes) in pageClasses {
            for className in classes {
                classToPages[className, default: []].insert(slug)
            }
        }

        let allPages = Set(pageClasses.keys)
        let effectiveThreshold = min(globalThreshold, allPages.count)

        // Global classes: used by all pages and meet threshold
        let globalClasses = Set(
            classToPages
                .filter { $0.value.count >= effectiveThreshold && $0.value == allPages }
                .map { $0.key }
        )

        // Shared classes grouped by page set (excluding global)
        var sharedClassesByPageSet: [Set<String>: Set<String>] = [:]
        for (className, pages) in classToPages {
            guard pages.count >= effectiveThreshold, pages != allPages else { continue }
            sharedClassesByPageSet[pages, default: []].insert(className)
        }

        // Page-specific classes (appears on exactly one page, excluding global)
        var pageSpecificClasses: [String: Set<String>] = [:]
        for (slug, classes) in pageClasses {
            let specific = classes
                .subtracting(globalClasses)
                .filter { classToPages[$0]?.count == 1 }
            pageSpecificClasses[slug] = Set(specific)
        }

        return ClassAnalysis(
            globalClasses: globalClasses,
            sharedClassesByPageSet: sharedClassesByPageSet,
            pageSpecificClasses: pageSpecificClasses
        )
    }

    private func makeBundleName(from pages: Set<String>) -> String {
        let sorted = pages.sorted()
        let raw = sorted.joined(separator: "-")
        return sanitizeBundleName(raw)
    }

    private func sanitizeBundleName(_ name: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let sanitized = name
            .map { ch -> String in
                let scalar = ch.unicodeScalars.first
                if let scalar, allowed.contains(scalar) {
                    return String(ch)
                }
                return "-"
            }
            .joined()
        return sanitized.replacingOccurrences(of: "--", with: "-")
    }

    private func writeManifest(_ manifest: CSSBundleManifest, writer: CSSWriter) throws {
        let stylesDir = "\(writer.config.outputDirectory)/styles"
        let filePath = "\(stylesDir)/manifest.json"
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: stylesDir) {
            try fileManager.createDirectory(
                atPath: stylesDir,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        guard let json = manifest.toJSONString() else { return }
        try json.write(toFile: filePath, atomically: true, encoding: .utf8)
    }
}

/// Result of CSS class analysis for SSR generation.
struct ClassAnalysis {
    /// Classes used on all pages (global CSS)
    let globalClasses: Set<String>

    /// Classes grouped by the set of pages that use them (shared bundles)
    let sharedClassesByPageSet: [Set<String>: Set<String>]

    /// Classes specific to each page
    let pageSpecificClasses: [String: Set<String>]
}
