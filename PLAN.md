# AxiomWeb Implementation Plan

## Status
- Owner: Codex implementation stream
- Plan version: v4 (includes structured data first-class metadata)
- Scope source: "AxiomWeb Rebuild Plan (Finalized Spec v3)" + "AxiomWeb Rebuild Plan v4 (Structured Data Included)"
- Branching policy: existing code in `legacy` branch, fresh implementation on `main`
- Execution progress (as of 2026-02-12):
  - `Phase 0` Foundation: complete
  - `Phase 1` UI + Style + Render Core: complete
  - `Phase 2` Runtime Interactivity: complete (state/events/timers + declarative motion + wasm runtime hooks)
  - `Phase 3` Server + Routing + Data: complete
  - `Phase 4` Components + Markdown: in progress
  - `Phase 5` Testing + Accessibility + Performance: in progress (WKWebView + snapshots baseline present; audit expansion pending)
  - `Phase 6` Localization + Docs Completion: in progress (routing/hreflang/sitemap implemented; docs completion pending)
  - `Phase 7` Declarative Motion System: in progress (animation + `@starting-style` complete; view-transition API pending)
- Latest completed slice:
  - Expanded native-first component primitives (`Card`, `ActionButton`, `Alert`, `Badge`, `Accordion`, `Popover`, `ModalDialog`, `DropdownMenu`, form-field components).
  - Added `WasmCanvas` with typed payload attributes and runtime wasm bootstrap/invocation plumbing.
  - Upgraded markdown renderer with stylable classes, admonitions, fenced code blocks, lists, blockquotes, and inline code support.
- Latest in-progress slice (Phase 5):
  - Expanded `AxiomWebTesting` browser flow API surface (`attribute`, `submit`, `waitForText`, normalized snapshots).
  - Added richer accessibility auditing with structured findings/severity, role/focus/contrast checks, and CI-friendly markdown/JSON reporting.
- Product note:
  - Add a WebUI playground example powered by WASM and publish it via GitHub Pages as a canonical ecosystem demo.

## Non-Negotiable Constraints
1. Preserve only the general declarative DSL feel from old WebUI (`Element`, `Document`, chained `.modifier` APIs, `.on {}` pattern).
2. Do not require users to author raw HTML/CSS/JS strings or interpolate file contents for app behavior/styling.
3. Structured data is first-class metadata and emitted as validated JSON-LD from typed APIs.
4. Routing is convention-based from filesystem plus optional code overrides.
5. UI components are native-first: prefer HTML/CSS/native platform features (`popover`, `details`, semantic form controls). JS only when absolutely required.
6. CSS output strategy is hybrid layers: utility-like atomic output + cascading component/base layers.
7. WKWebView-first testing with pluggable engine architecture.
8. Swift API Design Guidelines and readable declarative APIs are required.
9. Motion/animation authoring must be declarative through style modifiers and variant scopes, not raw CSS/JS strings.

## Ecosystem Modules
1. `AxiomWebUI`
2. `AxiomWebStyle`
3. `AxiomWebRuntime`
4. `AxiomWebRender`
5. `AxiomWebMarkdown`
6. `AxiomWebUIComponents`
7. `AxiomWebTesting`
8. `AxiomWebServer`
9. `AxiomWebCodegen`
10. `AxiomWebCLI`
11. `AxiomWebI18n`
12. Umbrella export module `AxiomWeb`

## Dependency Policy (Mandatory)
Before implementing any infrastructure from scratch, evaluate and prefer packages from these sources first:
1. Apple Collection: https://swiftpackageindex.com/apple/collection.json
2. Swift.org Collection: https://swiftpackageindex.com/swiftlang/collection.json
3. SSWG Collection: https://swiftpackageindex.com/sswg/collection.json
4. Swift Server Community Collection: https://swiftpackageindex.com/swift-server-community/collection.json

### Required baseline dependencies in this repository
- `apple/swift-nio` for event loops and server networking primitives.
- `apple/swift-http-types` for typed HTTP request/response models.
- `apple/swift-log` for logging API.
- `apple/swift-metrics` for metrics API.
- `apple/swift-distributed-tracing` for tracing primitives.
- `apple/swift-markdown` for markdown parsing.
- `apple/swift-argument-parser` for CLI.
- `swiftlang/swift-testing` for tests.

### Dependency compatibility note
- `swift-service-lifecycle` and `async-http-client` are temporarily deferred in the active package graph due Swift 6.3 snapshot transitive incompatibility (`swift-async-algorithms` compile failure in this environment).
- They remain planned integrations and are to be reintroduced once compatible versions are available.

### Anti-Reimplementation Guard
- For each new subsystem, record dependency review notes in `Documentation.docc/ADRs/`.
- If a dependency can satisfy the requirement with acceptable constraints, use it.
- Custom implementation is allowed only when:
  - there is no suitable maintained dependency in the approved collections, or
  - dependency behavior is materially incompatible with AxiomWeb constraints.
- Every custom replacement decision must include a short ADR entry with rationale.

## Routing Specification
- Page routes root: `Routes/pages/**`
- API routes root: `Routes/api/**`
- Path mapping:
  - `Routes/pages/index.swift` -> `/`
  - `Routes/pages/contact.swift` -> `/contact`
  - `Routes/pages/path/goodbye.swift` -> `/path/goodbye`
  - `Routes/api/hello.swift` -> `/api/hello`
  - `Routes/api/path/goodbye.swift` -> `/api/path/goodbye`
- Page document path behavior:
  - default route path is inferred from the route file location/name.
  - `var path: String` on a page document is an explicit override and takes precedence over inferred path.
- Dynamic routes:
  - `[slug].swift` -> `:slug`
  - `[...path].swift` -> catch-all
- HTTP methods are defined in route code/contracts, not filename conventions.
- A single API route file/path may register one or multiple methods (`GET`, `POST`, `PUT`, `PATCH`, etc.) for the same route path.

## Full-Breadth Coverage Requirements

### HTML Coverage
- Implement typed coverage for full modern HTML element set (matching MDN/WHATWG references for document, metadata, sectioning, text, inline semantics, forms, interactive, media, table, scripting, web components-related primitives).
- Coverage mechanism: explicit category-based DSL APIs in source (`Elements/*`) with spec snapshot parity tests from `AxiomWebCodegen`.
- Add per-element compile tests and rendering snapshots.

### CSS Coverage
- Implement typed support for full CSS property/value space (backed by generated registries from standards/MDN data).
- Implement typed support for full CSS property/value space via explicit category-based modifier APIs in source (`Modifiers/*`) with spec snapshot parity tests.
- Public authoring remains `.modifier` and `.on {}`; output is hybrid-layer CSS.
- Support tokens (colors, spacing, typography, radius, motion, breakpoints), variants (`sm`, `md`, `lg`, `dark`, interactive states), and arbitrary generated values where standards allow.
- Add declarative motion APIs for transitions and keyframes (duration, easing, delay, iteration, fill mode, direction, play state, reduced-motion variants) using the same modifier/variant authoring model.
- Add property/value conformance tests and output snapshots.

### Declarative JavaScript Coverage
- Provide typed declarative runtime APIs for:
  - local/page/app state
  - event listeners and action dispatch
  - timers and intervals
  - navigation actions
  - form interactions
  - fetch/data actions with cache/revalidation integration
- No user-authored JS strings required for supported behavior patterns.
- Runtime generation must be deterministic and minifiable.
- Include typed bridge primitives for WebAssembly module calls (request/response payload contracts, async invocation lifecycle, and error propagation).

## Metadata and Structured Data (v4)

### Metadata Model
- `Metadata.structuredData: [StructuredDataNode]`
- Site defaults + page metadata merge supported.
- Merge strategy supports append/replace where needed.

### Structured Data Types
- `StructuredDataNode` must support:
  - `.organization`
  - `.person`
  - `.article`
  - `.product`
  - `.faqPage`
  - `.breadcrumbList`
  - `.website`
  - `.webPage`
  - `.event`
  - `.custom(schemaType:..., properties:...)`
- `StructuredDataGraph` supports linked graphs and `@id` references.
- Deduplicate by identity at render time.
- Validate required fields by node type.
- Strict mode build failure on invalid graphs.
- JSON-LD output with stable ordering and safe embedding.

## Required Feature Set
1. Typed data-fetching and cache/revalidation primitives (SSR/SSG/ISR aware).
2. Form schema and typed validation pipeline across server/client.
3. Accessibility audit runner integrated into `AxiomWebTesting` and CI.
4. Asset pipeline defaults:
   - Input: `Assets/`
   - Output: `public/`
   - Hashing, image optimization, font subsetting, cache headers.
5. Observability defaults on (logs/metrics/traces), configurable off.
6. First-class localization:
   - typed localized keys
   - locale-aware route/path generation
   - static generation for multiple locales
   - `hreflang`
   - localized sitemap
   - fallback resolution
7. Compiler-plugin/analysis gate:
   - enforce route contract integrity
   - enforce no raw injection API surfaces
   - enforce typed registration/indexing checks
8. ADRs in `Documentation.docc/ADRs/`.
9. Full `Documentation.docc` completion after feature completion.
10. View Transitions support (document-level and application-level) for page and stateful route transitions.
11. Motion API support for CSS `@starting-style` patterns (typed authoring integrated with existing modifier/variant model).
12. WebAssembly interop:
   - `WasmCanvas` component for WASM-driven rendering surfaces
   - typed APIs to call into WASM and return data/results to DSL/runtime code
   - fallback behavior when WASM is unavailable

## Out of Scope (Explicitly Deferred)
- Plugin extension system for render/server/components/tooling.

## Implementation Phases

### Phase 0: Foundation
- Status: complete
- Build clean package graph.
- Scaffold module APIs and shared core types.
- Add routing conventions and project structure contracts.

### Phase 1: UI + Style + Render Core
- Status: complete
- Implement base DSL node system and result builders.
- Implement style token system and hybrid CSS generator.
- Implement deterministic HTML/CSS output pipeline.

### Phase 2: Runtime Interactivity
- Status: complete
- Implement typed runtime IR and JS generation for state/events/timers.
- Integrate runtime emission into renderer.
- Add typed WASM call bridge primitives (module loading, function invocation, typed payload encode/decode, error paths).

### Phase 3: Server + Routing + Data
- Status: complete
- Implement route discovery from `Routes/pages` and `Routes/api`.
- Add code-route overrides.
- Add typed fetch/cache/revalidation and form validation infrastructure.

### Phase 4: Components + Markdown
- Status: in progress
- Build native-first UI component library.
- Build stylable markdown renderer with admonitions and code blocks.
- Add `WasmCanvas` component and first-class component-level WASM integration patterns.

### Phase 5: Testing + Accessibility + Performance
- Status: in progress
- Implement WKWebView-first test APIs.
- Add snapshot testing, E2E flow testing, component-level testing.
- Add accessibility auditing in CI.

### Phase 6: Localization + Docs Completion
- Status: in progress
- Finalize locale-aware build outputs and SEO metadata (`hreflang`, sitemap variants).
- Complete `Documentation.docc` tutorials, references, explanations, and ADRs.

### Phase 7: Declarative Motion System
- Status: in progress
- Add typed animation/keyframe DSL in `AxiomWebStyle` authored via `.modifier` and `.on {}` patterns.
- Support scoped variants (`hover`, `focus`, breakpoints, `dark`, `prefers-reduced-motion`) for motion behavior.
- Generate deterministic CSS for transitions/animations with no raw CSS strings required.
- Add motion snapshots and accessibility checks for reduced-motion compliance.
- Add typed document/application view-transition APIs and generated transition CSS/JS wiring.
- Add typed `startingStyle` motion primitives that emit valid `@starting-style` rules with variant support.

## Acceptance Criteria
1. Full HTML element API breadth is explicitly implemented and tested against spec parity snapshots.
2. Full CSS property/value coverage strategy implemented and tested.
3. Structured data metadata is typed, validated, deduped, and deterministic.
4. Route discovery exactly follows filesystem conventions above.
5. Components favor native features with JS fallback only where necessary.
6. No required raw HTML/CSS/JS strings for standard framework use-cases.
7. Tests pass across rendering, routing, metadata, structured data, localization, and accessibility checks.
8. Documentation is complete and aligned with implemented behavior.
9. Declarative animation APIs exist and generate deterministic transition/keyframe CSS with reduced-motion coverage.
10. View transitions are declarative, testable, and work for both page-level and app-level transitions.
11. WASM interop is first-class via typed APIs and `WasmCanvas`, with deterministic fallback behavior.

## Implementation Guardrails
- Prefer upstream libraries/collections before writing custom infra where equivalent exists.
- Keep APIs declarative and readable.
- Add tests with each major subsystem increment.
- Do not silently alter DSL shape without explicit approval for rare breaking changes.

## Tracking
- This file is the authoritative implementation checklist and scope guard for current execution.
