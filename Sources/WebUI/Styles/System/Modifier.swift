/// Represents CSS modifiers that apply styles under specific conditions, such as hover or focus states.
///
/// This enum maps to Tailwind CSS prefixes like `hover:` and `focus:`, enabling conditional styling
/// when used with `Element` methods like `opacity` or `background()`. It also contains
/// breakpoint modifiers for applying styles to specific screen sizes in responsive designs.
///
/// Modifiers can be combined with any styling method to create responsive or interactive designs
/// without writing custom media queries or JavaScript.
///
/// - Note: You do not need to redefine all styles on each modifier, just the ones that change.
///
/// ## Example
/// ```swift
/// Button() { "Click me" }
///   .background(color: .blue(._500))
///   .background(color: .blue(._600), on: .hover)
///   .font(color: .white)
///   .font(size: .lg, on: .md)  // Larger text on medium screens and up
/// ```
public enum Modifier: String, Sendable {
    /// Extra small breakpoint modifier applying styles at 480px min-width and above.
    ///
    /// Use for small mobile device specific styles.
    case xs

    /// Small breakpoint modifier applying styles at 640px min-width and above.
    ///
    /// Use for larger mobile device specific styles.
    case sm

    /// Medium breakpoint modifier applying styles at 768px min-width and above.
    ///
    /// Use for tablet and small desktop specific styles.
    case md

    /// Large breakpoint modifier applying styles at 1024px min-width and above.
    ///
    /// Use for desktop specific styles.
    case lg

    /// Extra-large breakpoint modifier applying styles at 1280px min-width and above.
    ///
    /// Use for larger desktop specific styles.
    case xl

    /// 2x extra-large breakpoint modifier applying styles at 1536px min-width and above.
    ///
    /// Use for very large desktop and ultrawide monitor specific styles.
    case xl2 = "2xl"

    /// Applies the style when the element is hovered over with a mouse pointer.
    ///
    /// Use to create interactive hover effects and highlight interactive elements.
    case hover

    /// Applies the style when the element has keyboard focus.
    ///
    /// Use for accessibility to highlight the currently focused element.
    case focus

    /// Applies the style when the element is actively being pressed or clicked.
    ///
    /// Use to provide visual feedback during interaction.
    case active

    /// Applies the style to input placeholders within the element.
    ///
    /// Use to style placeholder text in input fields and text areas.
    case placeholder

    /// Applies styles only when dark mode is active.
    ///
    /// Use to create dark theme variants of your UI elements.
    case dark

    /// Applies the style to the first child element.
    ///
    /// Use to style the first item in a list or container.
    case first

    /// Applies the style to the last child element.
    ///
    /// Use to style the last item in a list or container.
    case last

    /// Applies the style when the element is disabled.
    ///
    /// Use to provide visual feedback for disabled form elements and controls.
    case disabled

    /// Applies the style when the user prefers reduced motion.
    ///
    /// Use to create alternative animations or transitions for users who prefer reduced motion.
    case motionReduce = "motion-reduce"

    /// Applies the style when the element has aria-busy="true".
    ///
    /// Use to style elements that are in a busy or loading state.
    case ariaBusy = "aria-busy"

    /// Applies the style when the element has aria-checked="true".
    ///
    /// Use to style elements that represent a checked state, like checkboxes.
    case ariaChecked = "aria-checked"

    /// Applies the style when the element has aria-disabled="true".
    ///
    /// Use to style elements that are disabled via ARIA attributes.
    case ariaDisabled = "aria-disabled"

    /// Applies the style when the element has aria-expanded="true".
    ///
    /// Use to style elements that can be expanded, like accordions or dropdowns.
    case ariaExpanded = "aria-expanded"

    /// Applies the style when the element has aria-hidden="true".
    ///
    /// Use to style elements that are hidden from screen readers.
    case ariaHidden = "aria-hidden"

    /// Applies the style when the element has aria-pressed="true".
    ///
    /// Use to style elements that represent a pressed state, like toggle buttons.
    case ariaPressed = "aria-pressed"

    /// Applies the style when the element has aria-readonly="true".
    ///
    /// Use to style elements that are in a read-only state.
    case ariaReadonly = "aria-readonly"

    /// Applies the style when the element has aria-required="true".
    ///
    /// Use to style elements that are required, like form inputs.
    case ariaRequired = "aria-required"

    /// Applies the style when the element has aria-selected="true".
    ///
    /// Use to style elements that are in a selected state, like tabs or menu items.
    case ariaSelected = "aria-selected"

    // MARK: - Pseudo-elements

    /// Applies styles to the ::before pseudo-element.
    ///
    /// Use to insert decorative content before an element.
    case before

    /// Applies styles to the ::after pseudo-element.
    ///
    /// Use to insert decorative content after an element.
    case after

    /// Applies styles to the ::selection pseudo-element.
    ///
    /// Use to style the portion of text selected by the user.
    case selection

    /// Applies styles to the ::marker pseudo-element.
    ///
    /// Use to style list item markers.
    case marker

    /// Applies styles to the ::file-selector-button pseudo-element.
    ///
    /// Use to style the file input button.
    case file

    /// Applies styles to the ::first-line pseudo-element.
    ///
    /// Use to style the first line of a block element.
    case firstLine = "first-line"

    /// Applies styles to the ::first-letter pseudo-element.
    ///
    /// Use to style the first letter of a block element.
    case firstLetter = "first-letter"

    // MARK: - Additional Pseudo-classes

    /// Applies styles when an element or its descendants have focus.
    ///
    /// Use for styling containers when any child element is focused.
    case focusWithin = "focus-within"

    /// Applies styles when an element has visible keyboard focus.
    ///
    /// Use to style focus states that should only appear for keyboard navigation.
    case focusVisible = "focus-visible"

    /// Applies styles to visited links.
    ///
    /// Use to style links that have been visited.
    case visited

    /// Applies styles when an element is the target of the URL fragment.
    ///
    /// Use to highlight elements targeted by hash links.
    case target

    /// Applies styles when an element has the [open] attribute.
    ///
    /// Use to style elements like <details> when expanded.
    case open

    /// Applies styles when a form element is required.
    ///
    /// Use to style required form inputs.
    case required

    /// Applies styles when a form element fails validation.
    ///
    /// Use to highlight invalid form inputs.
    case invalid

    /// Applies styles when a form element passes validation.
    ///
    /// Use to indicate valid form inputs.
    case valid

    /// Applies styles when a checkbox or radio button is checked.
    ///
    /// Use to style checked form elements.
    case checked

    /// Applies styles when a checkbox is in an indeterminate state.
    ///
    /// Use to style tri-state checkboxes.
    case indeterminate

    /// Applies styles when a form element is read-only.
    ///
    /// Use to style read-only form inputs.
    case readOnly = "read-only"

    /// Applies styles when an element has no children.
    ///
    /// Use to style empty containers.
    case empty

    /// Applies styles when a form element is enabled.
    ///
    /// Use to style enabled form inputs.
    case enabled

    // MARK: - Group Modifiers

    /// Applies styles to children when the parent with class="group" is hovered.
    ///
    /// Use to create coordinated hover effects across parent-child relationships.
    case groupHover = "group-hover"

    /// Applies styles to children when the parent with class="group" has focus.
    ///
    /// Use to highlight child elements when parent container is focused.
    case groupFocus = "group-focus"

    /// Applies styles to children when the parent with class="group" is active.
    ///
    /// Use to create press effects that cascade to children.
    case groupActive = "group-active"

    /// Applies styles to children when the parent with class="group" has focus-within.
    ///
    /// Use to style children when any element within the parent group is focused.
    case groupFocusWithin = "group-focus-within"

    // MARK: - Peer Modifiers

    /// Applies styles when a preceding sibling with class="peer" is hovered.
    ///
    /// Use for sibling-dependent hover effects.
    case peerHover = "peer-hover"

    /// Applies styles when a preceding sibling with class="peer" has focus.
    ///
    /// Use for focus-dependent sibling styling.
    case peerFocus = "peer-focus"

    /// Applies styles when a preceding sibling with class="peer" is checked.
    ///
    /// Use for custom checkbox/radio styling patterns.
    case peerChecked = "peer-checked"

    // MARK: - Child Selectors

    /// Applies styles to all direct children.
    ///
    /// Use to target all immediate child elements.
    case allChildren = "*"

    /// Applies styles when an element is the only child.
    ///
    /// Use to style elements that have no siblings.
    case only

    /// Applies styles to odd-numbered children.
    ///
    /// Use for zebra-striping lists or tables.
    case odd

    /// Applies styles to even-numbered children.
    ///
    /// Use for zebra-striping lists or tables.
    case even

    /// Applies styles to the first child of its type.
    ///
    /// Use to style the first occurrence of a specific element type.
    case firstOfType = "first-of-type"

    /// Applies styles to the last child of its type.
    ///
    /// Use to style the last occurrence of a specific element type.
    case lastOfType = "last-of-type"

    /// Applies styles when an element is the only child of its type.
    ///
    /// Use to style unique element types within a container.
    case onlyOfType = "only-of-type"

    public var rawValue: String {
        switch self {
        case .xs, .sm, .md, .lg, .xl, .hover, .focus, .active, .placeholder,
            .dark, .first, .last, .disabled, .before, .after, .selection,
            .marker, .file, .focusWithin, .visited, .target, .open,
            .required, .invalid, .valid, .checked, .indeterminate, .empty,
            .enabled, .allChildren, .only, .odd, .even:
            return "\(self):"
        case .xl2:
            return "2xl:"
        case .firstLine:
            return "first-line:"
        case .firstLetter:
            return "first-letter:"
        case .focusVisible:
            return "focus-visible:"
        case .readOnly:
            return "read-only:"
        case .firstOfType:
            return "first-of-type:"
        case .lastOfType:
            return "last-of-type:"
        case .onlyOfType:
            return "only-of-type:"
        case .motionReduce:
            return "motion-reduce:"
        case .groupHover:
            return "group-hover:"
        case .groupFocus:
            return "group-focus:"
        case .groupActive:
            return "group-active:"
        case .groupFocusWithin:
            return "group-focus-within:"
        case .peerHover:
            return "peer-hover:"
        case .peerFocus:
            return "peer-focus:"
        case .peerChecked:
            return "peer-checked:"
        case .ariaBusy:
            return "aria-busy:"
        case .ariaChecked:
            return "aria-checked:"
        case .ariaDisabled:
            return "aria-disabled:"
        case .ariaExpanded:
            return "aria-expanded:"
        case .ariaHidden:
            return "aria-hidden:"
        case .ariaPressed:
            return "aria-pressed:"
        case .ariaReadonly:
            return "aria-readonly:"
        case .ariaRequired:
            return "aria-required:"
        case .ariaSelected:
            return "aria-selected:"
        }
    }
}
