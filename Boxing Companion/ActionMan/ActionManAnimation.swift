import CoreGraphics
import Foundation

struct ActionManAnimation: Equatable {
    let id: String
    let duration: TimeInterval
    let loops: Bool
    let keyframes: [ActionManKeyframe]

    func pose(at elapsedTime: TimeInterval) -> ActionManPose {
        guard let firstKeyframe = keyframes.first else {
            return .guardStance
        }

        guard keyframes.count > 1 else {
            return firstKeyframe.pose
        }

        let playbackTime: TimeInterval
        if loops, duration > 0 {
            playbackTime = elapsedTime.truncatingRemainder(dividingBy: duration)
        } else {
            playbackTime = max(0, min(elapsedTime, duration))
        }

        guard playbackTime > firstKeyframe.time else {
            return firstKeyframe.pose
        }

        for index in 0..<(keyframes.count - 1) {
            let current = keyframes[index]
            let next = keyframes[index + 1]

            if playbackTime >= current.time, playbackTime <= next.time {
                let span = max(next.time - current.time, 0.001)
                let progress = CGFloat((playbackTime - current.time) / span)
                return ActionManPose.interpolate(from: current.pose, to: next.pose, progress: progress)
            }
        }

        return keyframes.last?.pose ?? firstKeyframe.pose
    }
}

struct ActionManKeyframe: Equatable {
    let time: TimeInterval
    let pose: ActionManPose
}
