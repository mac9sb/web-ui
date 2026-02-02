import Foundation

public enum Role: String, Sendable {
    case button
    case link
    case textbox
    case checkbox
    case radio
    case combobox
    case heading
    case img
    case list
    case listItem = "listitem"
    case main
    case region
    case navigation
    case banner
    case contentInfo = "contentinfo"
    case form
    case table
    case row
    case cell
    case columnHeader = "columnheader"
    case rowHeader = "rowheader"
}

public enum FormFieldKind: String, Sendable {
    case text
    case secure
}

public indirect enum Selector: Sendable, CustomStringConvertible {
    case css(String)
    case xpath(String)
    case text(String)
    case testId(String)
    case role(Role, name: String?)
    case formField(FormFieldKind, name: String?)
    case scoped(root: Selector, child: Selector)

    public var description: String {
        switch self {
        case .css(let value):
            return "css(\(value))"
        case .xpath(let value):
            return "xpath(\(value))"
        case .text(let value):
            return "text(\(value))"
        case .testId(let value):
            return "testId(\(value))"
        case .role(let role, let name):
            if let name {
                return "role(\(role.rawValue), name: \(name))"
            }
            return "role(\(role.rawValue))"
        case .formField(let kind, let name):
            if let name {
                return "formField(\(kind.rawValue), name: \(name))"
            }
            return "formField(\(kind.rawValue))"
        case .scoped(let root, let child):
            return "scoped(\(root.description), \(child.description))"
        }
    }
}

extension Selector {
    func jsElementExpression(index: Int? = nil) throws -> String {
        try jsElementExpression(root: "document", index: index)
    }

    func jsElementsExpression() throws -> String {
        try jsElementsExpression(root: "document")
    }

    private func jsElementExpression(root: String, index: Int? = nil) throws -> String {
        let resolvedIndex = index ?? 0

        switch self {
        case .css(let selector):
            let literal = try JavaScriptString.literal(selector)
            if index != nil {
                return "(() => { const root = \(root); if (!root) { return null; } return root.querySelectorAll(\(literal))[\(resolvedIndex)] || null; })()"
            }
            return "(() => { const root = \(root); if (!root) { return null; } return root.querySelector(\(literal)); })()"
        case .xpath(let xpath):
            let literal = try JavaScriptString.literal(xpath)
            if index != nil {
                return "(() => { const root = \(root); if (!root) { return null; } const doc = root.ownerDocument || document; const result = doc.evaluate(\(literal), root, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null); return result.snapshotItem(\(resolvedIndex)); })()"
            }
            return "(() => { const root = \(root); if (!root) { return null; } const doc = root.ownerDocument || document; const result = doc.evaluate(\(literal), root, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null); return result.singleNodeValue; })()"
        case .text(let text):
            let literal = try JavaScriptString.literal(text)
            return "(() => { const root = \(root); if (!root) { return null; } const text = \(literal); const elements = Array.from(root.querySelectorAll('*')).filter(el => (el.textContent || '').trim() === text); return elements[\(resolvedIndex)] || null; })()"
        case .testId(let value):
            let selectorLiteral = try JavaScriptString.literal("[data-testid='\(value)']")
            if index != nil {
                return "(() => { const root = \(root); if (!root) { return null; } return root.querySelectorAll(\(selectorLiteral))[\(resolvedIndex)] || null; })()"
            }
            return "(() => { const root = \(root); if (!root) { return null; } return root.querySelector(\(selectorLiteral)); })()"
        case .role(let role, let name):
            let selectorLiteral = try JavaScriptString.literal(Selector.roleQuerySelector(role))
            if let name {
                let nameLiteral = try JavaScriptString.literal(name)
                let helper = Selector.accessibleNameHelper(rootVariable: "root")
                return "(() => { const root = \(root); if (!root) { return null; } \(helper) const elements = Array.from(root.querySelectorAll(\(selectorLiteral))); const filtered = elements.filter(el => __webui_accessibleName(el) === \(nameLiteral)); return filtered[\(resolvedIndex)] || null; })()"
            }
            return "(() => { const root = \(root); if (!root) { return null; } const elements = Array.from(root.querySelectorAll(\(selectorLiteral))); return elements[\(resolvedIndex)] || null; })()"
        case .formField(let kind, let name):
            let helper = Selector.accessibleNameHelper(rootVariable: "root")
            let kindFilter: String
            switch kind {
            case .secure:
                kindFilter = "const matches = elements.filter(el => el.tagName.toLowerCase() === 'input' && (el.getAttribute('type') || '').toLowerCase() === 'password');"
            case .text:
                kindFilter = "const matches = elements.filter(el => { const tag = el.tagName.toLowerCase(); if (tag === 'textarea') { return true; } if (tag !== 'input') { return false; } const type = (el.getAttribute('type') || 'text').toLowerCase(); const disallowed = ['password','hidden','checkbox','radio','button','submit','reset','file','image']; return !disallowed.includes(type); });"
            }
            if let name {
                let nameLiteral = try JavaScriptString.literal(name)
                return "(() => { const root = \(root); if (!root) { return null; } \(helper) const elements = Array.from(root.querySelectorAll('input, textarea')); \(kindFilter) const filtered = matches.filter(el => __webui_accessibleName(el) === \(nameLiteral)); return filtered[\(resolvedIndex)] || null; })()"
            }
            return "(() => { const root = \(root); if (!root) { return null; } \(helper) const elements = Array.from(root.querySelectorAll('input, textarea')); \(kindFilter) return matches[\(resolvedIndex)] || null; })()"
        case .scoped(let rootSelector, let childSelector):
            let rootExpression = try rootSelector.jsElementExpression(root: root, index: nil)
            let childExpression = try childSelector.jsElementExpression(root: "rootElement", index: index)
            return "(() => { const rootElement = \(rootExpression); if (!rootElement) { return null; } return \(childExpression); })()"
        }
    }

    private func jsElementsExpression(root: String) throws -> String {
        switch self {
        case .css(let selector):
            let literal = try JavaScriptString.literal(selector)
            return "(() => { const root = \(root); if (!root) { return []; } return Array.from(root.querySelectorAll(\(literal))); })()"
        case .xpath(let xpath):
            let literal = try JavaScriptString.literal(xpath)
            return "(() => { const root = \(root); if (!root) { return []; } const doc = root.ownerDocument || document; const result = doc.evaluate(\(literal), root, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null); return Array.from({ length: result.snapshotLength }, (_, i) => result.snapshotItem(i)); })()"
        case .text(let text):
            let literal = try JavaScriptString.literal(text)
            return "(() => { const root = \(root); if (!root) { return []; } return Array.from(root.querySelectorAll('*')).filter(el => (el.textContent || '').trim() === \(literal)); })()"
        case .testId(let value):
            let selectorLiteral = try JavaScriptString.literal("[data-testid='\(value)']")
            return "(() => { const root = \(root); if (!root) { return []; } return Array.from(root.querySelectorAll(\(selectorLiteral))); })()"
        case .role(let role, let name):
            let selectorLiteral = try JavaScriptString.literal(Selector.roleQuerySelector(role))
            if let name {
                let nameLiteral = try JavaScriptString.literal(name)
                let helper = Selector.accessibleNameHelper(rootVariable: "root")
                return "(() => { const root = \(root); if (!root) { return []; } \(helper) const elements = Array.from(root.querySelectorAll(\(selectorLiteral))); return elements.filter(el => __webui_accessibleName(el) === \(nameLiteral)); })()"
            }
            return "(() => { const root = \(root); if (!root) { return []; } return Array.from(root.querySelectorAll(\(selectorLiteral))); })()"
        case .formField(let kind, let name):
            let helper = Selector.accessibleNameHelper(rootVariable: "root")
            let kindFilter: String
            switch kind {
            case .secure:
                kindFilter = "const matches = elements.filter(el => el.tagName.toLowerCase() === 'input' && (el.getAttribute('type') || '').toLowerCase() === 'password');"
            case .text:
                kindFilter = "const matches = elements.filter(el => { const tag = el.tagName.toLowerCase(); if (tag === 'textarea') { return true; } if (tag !== 'input') { return false; } const type = (el.getAttribute('type') || 'text').toLowerCase(); const disallowed = ['password','hidden','checkbox','radio','button','submit','reset','file','image']; return !disallowed.includes(type); });"
            }
            if let name {
                let nameLiteral = try JavaScriptString.literal(name)
                return "(() => { const root = \(root); if (!root) { return []; } \(helper) const elements = Array.from(root.querySelectorAll('input, textarea')); \(kindFilter) return matches.filter(el => __webui_accessibleName(el) === \(nameLiteral)); })()"
            }
            return "(() => { const root = \(root); if (!root) { return []; } \(helper) const elements = Array.from(root.querySelectorAll('input, textarea')); \(kindFilter) return matches; })()"
        case .scoped(let rootSelector, let childSelector):
            let rootExpression = try rootSelector.jsElementExpression(root: root, index: nil)
            let childExpression = try childSelector.jsElementsExpression(root: "rootElement")
            return "(() => { const rootElement = \(rootExpression); if (!rootElement) { return []; } return \(childExpression); })()"
        }
    }

    private static func accessibleNameHelper(rootVariable: String) -> String {
        """
        const __webui_accessibleName = (el) => {
            if (!el) { return ''; }
            const doc = (\(rootVariable).ownerDocument || document);
            const ariaLabel = el.getAttribute('aria-label');
            if (ariaLabel) { return ariaLabel.trim(); }
            const labelledBy = el.getAttribute('aria-labelledby');
            if (labelledBy) {
                return labelledBy.split(/\\s+/).map((id) => {
                    const ref = doc.getElementById(id);
                    return ref ? (ref.textContent || '').trim() : '';
                }).filter(Boolean).join(' ').trim();
            }
            if (el.id) {
                const label = doc.querySelector(`label[for=\"${el.id}\"]`);
                if (label) { return (label.textContent || '').trim(); }
            }
            const wrappingLabel = el.closest('label');
            if (wrappingLabel) { return (wrappingLabel.textContent || '').trim(); }
            const title = el.getAttribute('title');
            if (title) { return title.trim(); }
            const alt = el.getAttribute('alt');
            if (alt) { return alt.trim(); }
            const text = (el.textContent || '').trim();
            return text;
        };
        """
    }

    private static func roleQuerySelector(_ role: Role) -> String {
        switch role {
        case .button:
            return "[role=\"button\"],button,input[type=\"button\"],input[type=\"submit\"],input[type=\"reset\"]"
        case .link:
            return "[role=\"link\"],a[href]"
        case .textbox:
            return "[role=\"textbox\"],input:not([type]),input[type=\"text\"],input[type=\"email\"],input[type=\"search\"],input[type=\"url\"],input[type=\"tel\"],input[type=\"number\"],input[type=\"password\"],textarea"
        case .checkbox:
            return "[role=\"checkbox\"],input[type=\"checkbox\"]"
        case .radio:
            return "[role=\"radio\"],input[type=\"radio\"]"
        case .combobox:
            return "[role=\"combobox\"],select"
        case .heading:
            return "[role=\"heading\"],h1,h2,h3,h4,h5,h6"
        case .img:
            return "[role=\"img\"],img"
        case .list:
            return "[role=\"list\"],ul,ol"
        case .listItem:
            return "[role=\"listitem\"],li"
        case .main:
            return "[role=\"main\"],main"
        case .region:
            return "[role=\"region\"],section,main,nav,aside,header,footer"
        case .navigation:
            return "[role=\"navigation\"],nav"
        case .banner:
            return "[role=\"banner\"],header"
        case .contentInfo:
            return "[role=\"contentinfo\"],footer"
        case .form:
            return "[role=\"form\"],form"
        case .table:
            return "[role=\"table\"],table"
        case .row:
            return "[role=\"row\"],tr"
        case .cell:
            return "[role=\"cell\"],td"
        case .columnHeader:
            return "[role=\"columnheader\"],th[scope=\"col\"],th:not([scope])"
        case .rowHeader:
            return "[role=\"rowheader\"],th[scope=\"row\"]"
        }
    }
}
