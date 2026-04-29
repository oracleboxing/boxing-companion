import Foundation

struct ActionManAnimationMapper {
    static func animationID(for block: WorkoutSessionBlock) -> String {
        if let animationID = block.animationID, !animationID.isEmpty {
            return animationID
        }

        let title = block.title.lowercased()

        if title.contains("knee raises") { return "alternating_knee_raises" }
        if title.contains("step over") { return "step_over_the_gate" }
        if title.contains("torso twist") { return "standing_torso_twists" }
        if title.contains("squat") { return "squat_and_open" }
        if title.contains("lunge") { return "alternating_forward_lunges" }
        if title.contains("jab cross") && title.contains("slip") { return "jab_cross_slip_cross" }
        if title.contains("jab cross") && title.contains("pullback") { return "jab_cross_pullback_cross" }
        if title.contains("move after") { return "move_after_punching" }
        if title.contains("jab cross") { return "jab_cross" }
        if title.contains("jab") { return "jab" }
        if title.contains("cross") { return "cross" }

        return block.type == .recovery ? "rest_bounce" : "guard_bounce"
    }
}
