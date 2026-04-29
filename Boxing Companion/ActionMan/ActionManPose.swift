import CoreGraphics

struct ActionManPose: Equatable {
    var head: CGPoint
    var neck: CGPoint
    var chest: CGPoint
    var pelvis: CGPoint

    var leftShoulder: CGPoint
    var rightShoulder: CGPoint
    var leftElbow: CGPoint
    var rightElbow: CGPoint
    var leftGlove: CGPoint
    var rightGlove: CGPoint

    var leftHip: CGPoint
    var rightHip: CGPoint
    var leftKnee: CGPoint
    var rightKnee: CGPoint
    var leftFoot: CGPoint
    var rightFoot: CGPoint
}

extension ActionManPose {
    static let guardStance = ActionManPose(
        head: CGPoint(x: 0.50, y: 0.13),
        neck: CGPoint(x: 0.50, y: 0.25),
        chest: CGPoint(x: 0.50, y: 0.38),
        pelvis: CGPoint(x: 0.52, y: 0.58),
        leftShoulder: CGPoint(x: 0.42, y: 0.30),
        rightShoulder: CGPoint(x: 0.58, y: 0.30),
        leftElbow: CGPoint(x: 0.37, y: 0.42),
        rightElbow: CGPoint(x: 0.62, y: 0.42),
        leftGlove: CGPoint(x: 0.44, y: 0.28),
        rightGlove: CGPoint(x: 0.56, y: 0.31),
        leftHip: CGPoint(x: 0.46, y: 0.59),
        rightHip: CGPoint(x: 0.58, y: 0.59),
        leftKnee: CGPoint(x: 0.39, y: 0.76),
        rightKnee: CGPoint(x: 0.65, y: 0.74),
        leftFoot: CGPoint(x: 0.31, y: 0.92),
        rightFoot: CGPoint(x: 0.73, y: 0.90)
    )

    static let relaxedStance = ActionManPose(
        head: CGPoint(x: 0.50, y: 0.14),
        neck: CGPoint(x: 0.50, y: 0.26),
        chest: CGPoint(x: 0.50, y: 0.39),
        pelvis: CGPoint(x: 0.51, y: 0.59),
        leftShoulder: CGPoint(x: 0.41, y: 0.31),
        rightShoulder: CGPoint(x: 0.59, y: 0.31),
        leftElbow: CGPoint(x: 0.36, y: 0.46),
        rightElbow: CGPoint(x: 0.64, y: 0.46),
        leftGlove: CGPoint(x: 0.39, y: 0.56),
        rightGlove: CGPoint(x: 0.61, y: 0.56),
        leftHip: CGPoint(x: 0.45, y: 0.60),
        rightHip: CGPoint(x: 0.57, y: 0.60),
        leftKnee: CGPoint(x: 0.40, y: 0.77),
        rightKnee: CGPoint(x: 0.64, y: 0.76),
        leftFoot: CGPoint(x: 0.32, y: 0.92),
        rightFoot: CGPoint(x: 0.72, y: 0.91)
    )

    func offset(x: CGFloat = 0, y: CGFloat = 0) -> ActionManPose {
        ActionManPose(
            head: head.offsetBy(dx: x, dy: y),
            neck: neck.offsetBy(dx: x, dy: y),
            chest: chest.offsetBy(dx: x, dy: y),
            pelvis: pelvis.offsetBy(dx: x, dy: y),
            leftShoulder: leftShoulder.offsetBy(dx: x, dy: y),
            rightShoulder: rightShoulder.offsetBy(dx: x, dy: y),
            leftElbow: leftElbow.offsetBy(dx: x, dy: y),
            rightElbow: rightElbow.offsetBy(dx: x, dy: y),
            leftGlove: leftGlove.offsetBy(dx: x, dy: y),
            rightGlove: rightGlove.offsetBy(dx: x, dy: y),
            leftHip: leftHip.offsetBy(dx: x, dy: y),
            rightHip: rightHip.offsetBy(dx: x, dy: y),
            leftKnee: leftKnee.offsetBy(dx: x, dy: y),
            rightKnee: rightKnee.offsetBy(dx: x, dy: y),
            leftFoot: leftFoot.offsetBy(dx: x, dy: y),
            rightFoot: rightFoot.offsetBy(dx: x, dy: y)
        )
    }

    static func interpolate(from start: ActionManPose, to end: ActionManPose, progress: CGFloat) -> ActionManPose {
        let t = max(0, min(1, progress))

        return ActionManPose(
            head: .interpolate(start.head, end.head, t),
            neck: .interpolate(start.neck, end.neck, t),
            chest: .interpolate(start.chest, end.chest, t),
            pelvis: .interpolate(start.pelvis, end.pelvis, t),
            leftShoulder: .interpolate(start.leftShoulder, end.leftShoulder, t),
            rightShoulder: .interpolate(start.rightShoulder, end.rightShoulder, t),
            leftElbow: .interpolate(start.leftElbow, end.leftElbow, t),
            rightElbow: .interpolate(start.rightElbow, end.rightElbow, t),
            leftGlove: .interpolate(start.leftGlove, end.leftGlove, t),
            rightGlove: .interpolate(start.rightGlove, end.rightGlove, t),
            leftHip: .interpolate(start.leftHip, end.leftHip, t),
            rightHip: .interpolate(start.rightHip, end.rightHip, t),
            leftKnee: .interpolate(start.leftKnee, end.leftKnee, t),
            rightKnee: .interpolate(start.rightKnee, end.rightKnee, t),
            leftFoot: .interpolate(start.leftFoot, end.leftFoot, t),
            rightFoot: .interpolate(start.rightFoot, end.rightFoot, t)
        )
    }
}

private extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        CGPoint(x: x + dx, y: y + dy)
    }

    static func interpolate(_ start: CGPoint, _ end: CGPoint, _ progress: CGFloat) -> CGPoint {
        CGPoint(
            x: start.x + (end.x - start.x) * progress,
            y: start.y + (end.y - start.y) * progress
        )
    }
}
