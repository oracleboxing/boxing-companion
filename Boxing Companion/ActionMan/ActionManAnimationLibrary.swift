import CoreGraphics
import Foundation

struct ActionManAnimationLibrary {
    static let fallbackID = "guard_bounce"

    static func animation(for id: String?) -> ActionManAnimation {
        guard let id, let animation = animations[id] else {
            return animations[fallbackID] ?? .standing
        }

        return animation
    }

    private static let animations: [String: ActionManAnimation] = {
        [
            "standing": .standing,
            "guard_bounce": .guardBounce,
            "rest_bounce": .restBounce,
            "jab": .jab,
            "cross": .cross,
            "jab_cross": .jabCross,
            "jab_cross_reset": .jabCrossReset,
            "jab_cross_slip_cross": .jabCrossSlipCross,
            "jab_cross_pullback_cross": .jabCrossPullbackCross,
            "alternating_knee_raises": .alternatingKneeRaises,
            "step_over_the_gate": .stepOverTheGate,
            "standing_torso_twists": .standingTorsoTwists,
            "squat_and_open": .squatAndOpen,
            "alternating_forward_lunges": .alternatingForwardLunges,
            "move_after_punching": .moveAfterPunching
        ]
    }()
}

private extension ActionManAnimation {
    static let standing = ActionManAnimation(
        id: "standing",
        duration: 1,
        loops: true,
        keyframes: [ActionManKeyframe(time: 0, pose: .guardStance)]
    )

    static let guardBounce = ActionManAnimation(
        id: "guard_bounce",
        duration: 0.7,
        loops: true,
        keyframes: [
            ActionManKeyframe(time: 0.0, pose: .guardStance),
            ActionManKeyframe(time: 0.35, pose: .guardStance.offset(y: 0.025)),
            ActionManKeyframe(time: 0.7, pose: .guardStance)
        ]
    )

    static let restBounce = ActionManAnimation(
        id: "rest_bounce",
        duration: 0.9,
        loops: true,
        keyframes: [
            ActionManKeyframe(time: 0.0, pose: .relaxedStance),
            ActionManKeyframe(time: 0.45, pose: .relaxedStance.offset(y: 0.02)),
            ActionManKeyframe(time: 0.9, pose: .relaxedStance)
        ]
    )

    static let jab = ActionManAnimation(
        id: "jab",
        duration: 0.55,
        loops: true,
        keyframes: [
            ActionManKeyframe(time: 0.00, pose: .guardStance),
            ActionManKeyframe(time: 0.14, pose: .guardStance.leadJab(progress: 0.55)),
            ActionManKeyframe(time: 0.24, pose: .guardStance.leadJab(progress: 1.0)),
            ActionManKeyframe(time: 0.38, pose: .guardStance.leadJab(progress: 0.45)),
            ActionManKeyframe(time: 0.55, pose: .guardStance)
        ]
    )

    static let cross = ActionManAnimation(
        id: "cross",
        duration: 0.65,
        loops: true,
        keyframes: [
            ActionManKeyframe(time: 0.00, pose: .guardStance),
            ActionManKeyframe(time: 0.16, pose: .guardStance.rearCross(progress: 0.55)),
            ActionManKeyframe(time: 0.30, pose: .guardStance.rearCross(progress: 1.0)),
            ActionManKeyframe(time: 0.46, pose: .guardStance.rearCross(progress: 0.45)),
            ActionManKeyframe(time: 0.65, pose: .guardStance)
        ]
    )

    static let jabCross = ActionManAnimation(
        id: "jab_cross",
        duration: 1.25,
        loops: true,
        keyframes: [
            ActionManKeyframe(time: 0.00, pose: .guardStance),
            ActionManKeyframe(time: 0.12, pose: .guardStance.leadJab(progress: 0.55)),
            ActionManKeyframe(time: 0.22, pose: .guardStance.leadJab(progress: 1.0)),
            ActionManKeyframe(time: 0.38, pose: .guardStance),
            ActionManKeyframe(time: 0.55, pose: .guardStance.rearCross(progress: 0.55)),
            ActionManKeyframe(time: 0.70, pose: .guardStance.rearCross(progress: 1.0)),
            ActionManKeyframe(time: 0.92, pose: .guardStance),
            ActionManKeyframe(time: 1.25, pose: .guardStance)
        ]
    )

    static let jabCrossReset = ActionManAnimation(
        id: "jab_cross_reset",
        duration: 1.65,
        loops: true,
        keyframes: [
            ActionManKeyframe(time: 0.00, pose: .guardStance),
            ActionManKeyframe(time: 0.16, pose: .guardStance.leadJab(progress: 1.0)),
            ActionManKeyframe(time: 0.36, pose: .guardStance),
            ActionManKeyframe(time: 0.58, pose: .guardStance.rearCross(progress: 1.0)),
            ActionManKeyframe(time: 0.84, pose: .guardStance),
            ActionManKeyframe(time: 1.15, pose: .guardStance.smallStepOut()),
            ActionManKeyframe(time: 1.65, pose: .guardStance)
        ]
    )

    static let jabCrossSlipCross = ActionManAnimation(
        id: "jab_cross_slip_cross",
        duration: 1.95,
        loops: true,
        keyframes: [
            ActionManKeyframe(time: 0.00, pose: .guardStance),
            ActionManKeyframe(time: 0.15, pose: .guardStance.leadJab(progress: 1.0)),
            ActionManKeyframe(time: 0.35, pose: .guardStance),
            ActionManKeyframe(time: 0.58, pose: .guardStance.rearCross(progress: 1.0)),
            ActionManKeyframe(time: 0.84, pose: .guardStance),
            ActionManKeyframe(time: 1.08, pose: .guardStance.slipRearSide()),
            ActionManKeyframe(time: 1.30, pose: .guardStance),
            ActionManKeyframe(time: 1.52, pose: .guardStance.rearCross(progress: 1.0)),
            ActionManKeyframe(time: 1.95, pose: .guardStance)
        ]
    )

    static let jabCrossPullbackCross = ActionManAnimation(
        id: "jab_cross_pullback_cross",
        duration: 2.05,
        loops: true,
        keyframes: [
            ActionManKeyframe(time: 0.00, pose: .guardStance),
            ActionManKeyframe(time: 0.15, pose: .guardStance.leadJab(progress: 1.0)),
            ActionManKeyframe(time: 0.35, pose: .guardStance),
            ActionManKeyframe(time: 0.58, pose: .guardStance.rearCross(progress: 1.0)),
            ActionManKeyframe(time: 0.84, pose: .guardStance),
            ActionManKeyframe(time: 1.10, pose: .guardStance.pullback()),
            ActionManKeyframe(time: 1.38, pose: .guardStance),
            ActionManKeyframe(time: 1.62, pose: .guardStance.rearCross(progress: 1.0)),
            ActionManKeyframe(time: 2.05, pose: .guardStance)
        ]
    )

    static let alternatingKneeRaises = ActionManAnimation(
        id: "alternating_knee_raises",
        duration: 1.6,
        loops: true,
        keyframes: [
            ActionManKeyframe(time: 0.0, pose: .relaxedStance),
            ActionManKeyframe(time: 0.4, pose: .relaxedStance.leftKneeRaised()),
            ActionManKeyframe(time: 0.8, pose: .relaxedStance),
            ActionManKeyframe(time: 1.2, pose: .relaxedStance.rightKneeRaised()),
            ActionManKeyframe(time: 1.6, pose: .relaxedStance)
        ]
    )

    static let stepOverTheGate = ActionManAnimation(
        id: "step_over_the_gate",
        duration: 1.8,
        loops: true,
        keyframes: [
            ActionManKeyframe(time: 0.0, pose: .relaxedStance),
            ActionManKeyframe(time: 0.45, pose: .relaxedStance.leftKneeRaised()),
            ActionManKeyframe(time: 0.9, pose: .relaxedStance.leftGateOpen()),
            ActionManKeyframe(time: 1.35, pose: .relaxedStance),
            ActionManKeyframe(time: 1.8, pose: .relaxedStance.rightGateOpen())
        ]
    )

    static let standingTorsoTwists = ActionManAnimation(
        id: "standing_torso_twists",
        duration: 1.2,
        loops: true,
        keyframes: [
            ActionManKeyframe(time: 0.0, pose: .relaxedStance),
            ActionManKeyframe(time: 0.3, pose: .relaxedStance.torsoTwist(left: true)),
            ActionManKeyframe(time: 0.6, pose: .relaxedStance),
            ActionManKeyframe(time: 0.9, pose: .relaxedStance.torsoTwist(left: false)),
            ActionManKeyframe(time: 1.2, pose: .relaxedStance)
        ]
    )

    static let squatAndOpen = ActionManAnimation(
        id: "squat_and_open",
        duration: 1.7,
        loops: true,
        keyframes: [
            ActionManKeyframe(time: 0.0, pose: .relaxedStance),
            ActionManKeyframe(time: 0.55, pose: .relaxedStance.squat(open: false)),
            ActionManKeyframe(time: 0.9, pose: .relaxedStance.squat(open: true)),
            ActionManKeyframe(time: 1.7, pose: .relaxedStance)
        ]
    )

    static let alternatingForwardLunges = ActionManAnimation(
        id: "alternating_forward_lunges",
        duration: 2.0,
        loops: true,
        keyframes: [
            ActionManKeyframe(time: 0.0, pose: .relaxedStance),
            ActionManKeyframe(time: 0.55, pose: .relaxedStance.leftLunge()),
            ActionManKeyframe(time: 1.0, pose: .relaxedStance),
            ActionManKeyframe(time: 1.55, pose: .relaxedStance.rightLunge()),
            ActionManKeyframe(time: 2.0, pose: .relaxedStance)
        ]
    )

    static let moveAfterPunching = ActionManAnimation(
        id: "move_after_punching",
        duration: 1.8,
        loops: true,
        keyframes: [
            ActionManKeyframe(time: 0.0, pose: .guardStance),
            ActionManKeyframe(time: 0.18, pose: .guardStance.leadJab(progress: 1.0)),
            ActionManKeyframe(time: 0.40, pose: .guardStance),
            ActionManKeyframe(time: 0.65, pose: .guardStance.rearCross(progress: 1.0)),
            ActionManKeyframe(time: 0.95, pose: .guardStance),
            ActionManKeyframe(time: 1.25, pose: .guardStance.smallStepOut()),
            ActionManKeyframe(time: 1.8, pose: .guardStance)
        ]
    )
}

private extension ActionManPose {
    func leadJab(progress: CGFloat) -> ActionManPose {
        var pose = self
        pose.leftShoulder = point(leftShoulder, dx: -0.03 * progress, dy: -0.005 * progress)
        pose.leftElbow = point(leftElbow, dx: -0.16 * progress, dy: -0.10 * progress)
        pose.leftGlove = point(leftGlove, dx: -0.33 * progress, dy: -0.05 * progress)
        pose.chest = point(chest, dx: -0.025 * progress, dy: 0)
        pose.pelvis = point(pelvis, dx: -0.015 * progress, dy: 0)
        return pose
    }

    func rearCross(progress: CGFloat) -> ActionManPose {
        var pose = self
        pose.rightShoulder = point(rightShoulder, dx: -0.10 * progress, dy: -0.01 * progress)
        pose.rightElbow = point(rightElbow, dx: -0.23 * progress, dy: -0.09 * progress)
        pose.rightGlove = point(rightGlove, dx: -0.42 * progress, dy: -0.06 * progress)
        pose.leftGlove = point(leftGlove, dx: 0.02 * progress, dy: 0.01 * progress)
        pose.chest = point(chest, dx: -0.06 * progress, dy: 0.005 * progress)
        pose.pelvis = point(pelvis, dx: -0.025 * progress, dy: 0)
        pose.rightHip = point(rightHip, dx: -0.04 * progress, dy: 0)
        pose.rightKnee = point(rightKnee, dx: -0.04 * progress, dy: 0.01 * progress)
        return pose
    }

    func slipRearSide() -> ActionManPose {
        var pose = self
        pose.head = point(head, dx: 0.10, dy: 0.04)
        pose.neck = point(neck, dx: 0.09, dy: 0.04)
        pose.chest = point(chest, dx: 0.06, dy: 0.03)
        pose.leftGlove = point(leftGlove, dx: 0.06, dy: 0.02)
        pose.rightGlove = point(rightGlove, dx: 0.06, dy: 0.02)
        return pose
    }

    func pullback() -> ActionManPose {
        var pose = self
        pose.head = point(head, dx: 0.12, dy: -0.01)
        pose.neck = point(neck, dx: 0.10, dy: 0.00)
        pose.chest = point(chest, dx: 0.08, dy: 0.01)
        pose.pelvis = point(pelvis, dx: 0.04, dy: 0.01)
        pose.leftGlove = point(leftGlove, dx: 0.08, dy: 0)
        pose.rightGlove = point(rightGlove, dx: 0.08, dy: 0)
        return pose
    }

    func smallStepOut() -> ActionManPose {
        var pose = self.offset(x: 0.05, y: 0)
        pose.leftFoot = point(pose.leftFoot, dx: -0.04, dy: 0)
        pose.rightFoot = point(pose.rightFoot, dx: 0.05, dy: 0)
        return pose
    }

    func leftKneeRaised() -> ActionManPose {
        var pose = self
        pose.leftKnee = CGPoint(x: 0.42, y: 0.58)
        pose.leftFoot = CGPoint(x: 0.43, y: 0.69)
        return pose
    }

    func rightKneeRaised() -> ActionManPose {
        var pose = self
        pose.rightKnee = CGPoint(x: 0.60, y: 0.58)
        pose.rightFoot = CGPoint(x: 0.60, y: 0.69)
        return pose
    }

    func leftGateOpen() -> ActionManPose {
        var pose = leftKneeRaised()
        pose.leftKnee = CGPoint(x: 0.31, y: 0.59)
        pose.leftFoot = CGPoint(x: 0.30, y: 0.72)
        return pose
    }

    func rightGateOpen() -> ActionManPose {
        var pose = rightKneeRaised()
        pose.rightKnee = CGPoint(x: 0.71, y: 0.59)
        pose.rightFoot = CGPoint(x: 0.72, y: 0.72)
        return pose
    }

    func torsoTwist(left: Bool) -> ActionManPose {
        let direction: CGFloat = left ? -1 : 1
        var pose = self
        pose.leftShoulder = point(leftShoulder, dx: 0.05 * direction, dy: 0)
        pose.rightShoulder = point(rightShoulder, dx: 0.05 * direction, dy: 0)
        pose.leftGlove = point(leftGlove, dx: 0.12 * direction, dy: -0.03)
        pose.rightGlove = point(rightGlove, dx: 0.12 * direction, dy: 0.03)
        pose.chest = point(chest, dx: 0.03 * direction, dy: 0)
        return pose
    }

    func squat(open: Bool) -> ActionManPose {
        var pose = self
        pose.head = point(head, dx: 0, dy: 0.13)
        pose.neck = point(neck, dx: 0, dy: 0.13)
        pose.chest = point(chest, dx: 0, dy: 0.12)
        pose.pelvis = point(pelvis, dx: 0, dy: 0.16)
        pose.leftKnee = CGPoint(x: open ? 0.32 : 0.38, y: 0.78)
        pose.rightKnee = CGPoint(x: open ? 0.70 : 0.64, y: 0.78)
        pose.leftFoot = CGPoint(x: 0.28, y: 0.92)
        pose.rightFoot = CGPoint(x: 0.75, y: 0.92)
        pose.leftGlove = point(leftGlove, dx: -0.07, dy: open ? 0.16 : 0.08)
        pose.rightGlove = point(rightGlove, dx: 0.07, dy: open ? 0.16 : 0.08)
        return pose
    }

    func leftLunge() -> ActionManPose {
        var pose = self
        pose.pelvis = point(pelvis, dx: -0.04, dy: 0.07)
        pose.leftKnee = CGPoint(x: 0.34, y: 0.76)
        pose.leftFoot = CGPoint(x: 0.24, y: 0.91)
        pose.rightKnee = CGPoint(x: 0.68, y: 0.80)
        pose.rightFoot = CGPoint(x: 0.78, y: 0.91)
        return pose
    }

    func rightLunge() -> ActionManPose {
        var pose = self
        pose.pelvis = point(pelvis, dx: 0.04, dy: 0.07)
        pose.leftKnee = CGPoint(x: 0.35, y: 0.80)
        pose.leftFoot = CGPoint(x: 0.25, y: 0.91)
        pose.rightKnee = CGPoint(x: 0.68, y: 0.76)
        pose.rightFoot = CGPoint(x: 0.80, y: 0.91)
        return pose
    }

    private func point(_ point: CGPoint, dx: CGFloat, dy: CGFloat) -> CGPoint {
        CGPoint(x: point.x + dx, y: point.y + dy)
    }
}
