import Foundation
import AxiomWebUI

private func animationClassNames(for spec: AnimationSpec) -> [String] {
    var classNames: [String] = [
        ArbitraryStyleRegistry.className(property: .animation, value: spec.toCSSValue()),
    ]

    if let declarations = spec.inferredStartingStyleDeclarations(), !declarations.isEmpty {
        classNames.append(StartingStyleRegistry.className(declarations: declarations))
    }

    return classNames
}

public extension Markup {
    func animate(_ spec: AnimationSpec) -> some Markup {
        modifiers(animationClassNames(for: spec))
    }

    func animate(
        _ name: AnimationName,
        duration: Double = 0.3,
        timing: AnimationTiming = .ease,
        delay: Double = 0,
        iteration: AnimationIteration = .count(1),
        direction: AnimationDirection = .normal,
        fillMode: AnimationFillMode = .both,
        playState: AnimationPlayState = .running,
        startingStyle: AnimationStartingStylePolicy = .automatic
    ) -> some Markup {
        animate(
            AnimationSpec(
                name: name,
                duration: duration,
                timing: timing,
                delay: delay,
                iteration: iteration,
                direction: direction,
                fillMode: fillMode,
                playState: playState,
                startingStyle: startingStyle
            )
        )
    }

    func animation(_ spec: AnimationSpec) -> some Markup {
        animate(spec)
    }

    func animation(
        _ name: AnimationName,
        duration: Double = 0.3,
        timing: AnimationTiming = .ease,
        delay: Double = 0,
        iteration: AnimationIteration = .count(1),
        direction: AnimationDirection = .normal,
        fillMode: AnimationFillMode = .both,
        playState: AnimationPlayState = .running,
        startingStyle: AnimationStartingStylePolicy = .automatic
    ) -> some Markup {
        animate(
            name,
            duration: duration,
            timing: timing,
            delay: delay,
            iteration: iteration,
            direction: direction,
            fillMode: fillMode,
            playState: playState,
            startingStyle: startingStyle
        )
    }
}

public extension VariantScope {
    func animate(_ spec: AnimationSpec) {
        for className in animationClassNames(for: spec) {
            addClass(className)
        }
    }

    func animate(
        _ name: AnimationName,
        duration: Double = 0.3,
        timing: AnimationTiming = .ease,
        delay: Double = 0,
        iteration: AnimationIteration = .count(1),
        direction: AnimationDirection = .normal,
        fillMode: AnimationFillMode = .both,
        playState: AnimationPlayState = .running,
        startingStyle: AnimationStartingStylePolicy = .automatic
    ) {
        animate(
            AnimationSpec(
                name: name,
                duration: duration,
                timing: timing,
                delay: delay,
                iteration: iteration,
                direction: direction,
                fillMode: fillMode,
                playState: playState,
                startingStyle: startingStyle
            )
        )
    }

    func animation(_ spec: AnimationSpec) {
        animate(spec)
    }

    func animation(
        _ name: AnimationName,
        duration: Double = 0.3,
        timing: AnimationTiming = .ease,
        delay: Double = 0,
        iteration: AnimationIteration = .count(1),
        direction: AnimationDirection = .normal,
        fillMode: AnimationFillMode = .both,
        playState: AnimationPlayState = .running,
        startingStyle: AnimationStartingStylePolicy = .automatic
    ) {
        animate(
            name,
            duration: duration,
            timing: timing,
            delay: delay,
            iteration: iteration,
            direction: direction,
            fillMode: fillMode,
            playState: playState,
            startingStyle: startingStyle
        )
    }
}
