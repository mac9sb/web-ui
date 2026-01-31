import Foundation

/// Generates JavaScript state machine code from declarative definitions.
///
/// JSGenerator creates JavaScript code for state machines that can be used
/// for interactive UI components, form handling, and other client-side logic.
///
/// ## Architecture
///
/// The generator uses a declarative approach where state machines are defined
/// using Swift types, then compiled to efficient JavaScript state machines.
///
/// ## Supported Features
///
/// - **State Definitions**: Define states and their properties
/// - **Transitions**: Define valid state transitions with guards
/// - **Actions**: Define side effects for state changes
/// - **Events**: Define events that trigger transitions
/// - **Guards**: Define conditions for transitions
///
/// ## Example
///
/// ```swift
/// let stateMachine = StateMachine {
///     state("idle") {
///         event("start") { transition(to: "running") }
///     }
///     state("running") {
///         event("pause") { transition(to: "paused") }
///         event("stop") { transition(to: "idle") }
///     }
/// }
/// let js = JSGenerator.generateStateMachine(stateMachine)
/// ```
public enum JSGenerator {
    /// Generates JavaScript code for a state machine.
    ///
    /// - Parameter stateMachine: The state machine definition
    /// - Returns: JavaScript code as a string
    public static func generateStateMachine(_ stateMachine: StateMachine) -> String {
        var js = """
            class StateMachine {
                constructor(initialState = '\(stateMachine.initialState)') {
                    this.currentState = initialState;
                    this.states = \(generateStatesObject(stateMachine.states));
                    this.transitions = \(generateTransitionsObject(stateMachine.transitions));
                    this.listeners = [];
                }

                getCurrentState() {
                    return this.currentState;
                }

                canTransition(event) {
                    const currentTransitions = this.transitions[this.currentState];
                    return currentTransitions && currentTransitions.hasOwnProperty(event);
                }

                transition(event, data = {}) {
                    if (!this.canTransition(event)) {
                        console.warn(`Invalid transition: ${event} from state ${this.currentState}`);
                        return false;
                    }

                    const transition = this.transitions[this.currentState][event];
                    const nextState = transition.to;

                    // Check guard condition if present
                    if (transition.guardCondition && !transition.guardCondition(data)) {
                        console.warn(`Transition guard failed: ${event} from state ${this.currentState}`);
                        return false;
                    }

                    const prevState = this.currentState;
                    this.currentState = nextState;

                    // Execute action if present
                    if (transition.action) {
                        transition.action(data);
                    }

                    // Notify listeners
                    this.notifyListeners({
                        event,
                        from: prevState,
                        to: nextState,
                        data
                    });

                    return true;
                }

                onTransition(listener) {
                    this.listeners.push(listener);
                }

                offTransition(listener) {
                    this.listeners = this.listeners.filter(l => l !== listener);
                }

                notifyListeners(transition) {
                    this.listeners.forEach(listener => {
                        try {
                            listener(transition);
                        } catch (error) {
                            console.error('State machine listener error:', error);
                        }
                    });
                }

                reset() {
                    this.currentState = '\(stateMachine.initialState)';
                    this.notifyListeners({
                        event: 'reset',
                        from: this.currentState,
                        to: this.currentState,
                        data: {}
                    });
                }
            }

            """

        // Add utility functions
        js += """

            // State machine factory function
            function createStateMachine(initialState) {
                return new StateMachine(initialState);
            }

            // Export for module systems
            if (typeof module !== 'undefined' && module.exports) {
                module.exports = { StateMachine, createStateMachine };
            } else if (typeof define === 'function' && define.amd) {
                define([], function() { return { StateMachine, createStateMachine }; });
            } else if (typeof window !== 'undefined') {
                window.StateMachine = StateMachine;
                window.createStateMachine = createStateMachine;
            }

            """

        return js
    }

    /// Generates JavaScript code for multiple state machines.
    ///
    /// - Parameter stateMachines: Array of state machine definitions with identifiers
    /// - Returns: Combined JavaScript code
    public static func generateStateMachines(_ stateMachines: [(id: String, machine: StateMachine)]) -> String {
        var js = ""

        for (id, machine) in stateMachines {
            js += """
                // State Machine: \(id)
                \(generateStateMachine(machine))

                const \(id)StateMachine = new StateMachine();

                """
        }

        js += """

            // Combined state machines object
            const stateMachines = {
                \(stateMachines.map { "\($0.id): \($0.id)StateMachine" }.joined(separator: ",\n    "))
            };

            // Export combined state machines
            if (typeof module !== 'undefined' && module.exports) {
                module.exports = { ...module.exports, stateMachines };
            } else if (typeof window !== 'undefined') {
                window.stateMachines = stateMachines;
            }

            """

        return js
    }

    /// Generates a JavaScript object representing the states.
    private static func generateStatesObject(_ states: [String: StateDefinition]) -> String {
        var stateEntries: [String] = []

        for (name, definition) in states {
            let entry = """
                    "\(name)": {
                        name: "\(name)",
                        data: \(definition.data ?? "null")
                    }
                """
            stateEntries.append(entry)
        }

        return "{\n        \(stateEntries.joined(separator: ",\n        "))\n    }"
    }

    /// Generates a JavaScript object representing the transitions.
    private static func generateTransitionsObject(_ transitions: [String: [String: TransitionDefinition]]) -> String {
        var stateEntries: [String] = []

        for (fromState, eventTransitions) in transitions {
            var eventEntries: [String] = []

            for (event, transition) in eventTransitions {
                let guardJS = transition.guardCondition.map { "data => \($0)" } ?? "null"
                let actionJS = transition.action.map { "data => \($0)" } ?? "null"

                let entry = """
                        "\(event)": {
                            to: "\(transition.to)",
                            guard: \(guardJS),
                            action: \(actionJS)
                        }
                    """
                eventEntries.append(entry)
            }

            let stateEntry = """
                    "\(fromState)": {
                        \(eventEntries.joined(separator: ",\n            "))
                    }
                """
            stateEntries.append(stateEntry)
        }

        return "{\n        \(stateEntries.joined(separator: ",\n        "))\n    }"
    }
}

// MARK: - State Machine Definition Types

/// A declarative state machine definition.
public struct StateMachine {
    public let initialState: String
    public let states: [String: StateDefinition]
    public let transitions: [String: [String: TransitionDefinition]]

    public init(initialState: String = "idle", @StateMachineBuilder builder: () -> [StateDefinition]) {
        self.initialState = initialState
        let stateDefs = builder()
        self.states = Dictionary(uniqueKeysWithValues: stateDefs.map { ($0.name, $0) })

        // Build transitions from state definitions
        var transitions: [String: [String: TransitionDefinition]] = [:]
        for stateDef in stateDefs {
            transitions[stateDef.name] = Dictionary(uniqueKeysWithValues: stateDef.events.map { ($0.name, $0.transition) })
        }
        self.transitions = transitions
    }
}

/// A state definition.
public struct StateDefinition {
    public let name: String
    public let data: String?
    public let events: [EventDefinition]

    public init(name: String, data: String? = nil, @EventBuilder builder: () -> [EventDefinition] = { [] }) {
        self.name = name
        self.data = data
        self.events = builder()
    }
}

/// An event definition.
public struct EventDefinition {
    public let name: String
    public let transition: TransitionDefinition

    public init(name: String, transition: TransitionDefinition) {
        self.name = name
        self.transition = transition
    }
}

/// A transition definition.
public struct TransitionDefinition {
    public let to: String
    public let guardCondition: String?
    public let action: String?

    public init(to: String, guardCondition: String? = nil, action: String? = nil) {
        self.to = to
        self.guardCondition = guardCondition
        self.action = action
    }
}

// MARK: - Result Builders

@resultBuilder
public struct StateMachineBuilder {
    public static func buildBlock(_ components: StateDefinition...) -> [StateDefinition] {
        Array(components)
    }
}

@resultBuilder
public struct EventBuilder {
    public static func buildBlock(_ components: EventDefinition...) -> [EventDefinition] {
        Array(components)
    }
}

// MARK: - Convenience Functions

/// Creates a state definition.
public func state(_ name: String, data: String? = nil, @EventBuilder builder: () -> [EventDefinition] = { [] }) -> StateDefinition {
    StateDefinition(name: name, data: data, builder: builder)
}

/// Creates an event definition.
public func event(_ name: String, @TransitionBuilder builder: () -> TransitionDefinition) -> EventDefinition {
    EventDefinition(name: name, transition: builder())
}

/// Creates a transition definition.
public func transition(to state: String, guardCondition: String? = nil, action: String? = nil) -> TransitionDefinition {
    TransitionDefinition(to: state, guardCondition: guardCondition, action: action)
}

@resultBuilder
public struct TransitionBuilder {
    public static func buildBlock(_ component: TransitionDefinition) -> TransitionDefinition {
        component
    }
}
