import SwiftUI

struct ActionManRenderer: View {
    let pose: ActionManPose
    var lineColor: Color = .primary
    var accentColor: Color = Color(red: 0.84, green: 0.62, blue: 0.27)

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let lineWidth = max(5, min(size.width, size.height) * 0.045)
            let gloveSize = max(16, min(size.width, size.height) * 0.13)
            let headRadius = max(13, min(size.width, size.height) * 0.085)

            ZStack {
                ActionManSkeletonShape(pose: pose)
                    .stroke(
                        lineColor,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                    )

                Circle()
                    .stroke(lineColor, lineWidth: lineWidth * 0.65)
                    .frame(width: headRadius * 2, height: headRadius * 2)
                    .position(map(pose.head, in: size))

                glove(at: pose.leftGlove, size: gloveSize, canvasSize: size)
                glove(at: pose.rightGlove, size: gloveSize, canvasSize: size)
            }
            .animation(.linear(duration: 0.05), value: pose)
        }
    }

    private func glove(at point: CGPoint, size: CGFloat, canvasSize: CGSize) -> some View {
        Capsule(style: .continuous)
            .fill(accentColor)
            .overlay(
                Capsule(style: .continuous)
                    .stroke(lineColor.opacity(0.85), lineWidth: max(2, size * 0.14))
            )
            .frame(width: size * 0.8, height: size)
            .position(map(point, in: canvasSize))
    }

    private func map(_ point: CGPoint, in size: CGSize) -> CGPoint {
        CGPoint(x: point.x * size.width, y: point.y * size.height)
    }
}

private struct ActionManSkeletonShape: Shape {
    let pose: ActionManPose

    func path(in rect: CGRect) -> Path {
        var path = Path()

        line(&path, rect, pose.neck, pose.chest)
        line(&path, rect, pose.chest, pose.pelvis)

        line(&path, rect, pose.leftShoulder, pose.neck)
        line(&path, rect, pose.neck, pose.rightShoulder)

        line(&path, rect, pose.leftShoulder, pose.leftElbow)
        line(&path, rect, pose.leftElbow, pose.leftGlove)
        line(&path, rect, pose.rightShoulder, pose.rightElbow)
        line(&path, rect, pose.rightElbow, pose.rightGlove)

        line(&path, rect, pose.leftHip, pose.pelvis)
        line(&path, rect, pose.pelvis, pose.rightHip)

        line(&path, rect, pose.leftHip, pose.leftKnee)
        line(&path, rect, pose.leftKnee, pose.leftFoot)
        line(&path, rect, pose.rightHip, pose.rightKnee)
        line(&path, rect, pose.rightKnee, pose.rightFoot)

        return path
    }

    private func line(_ path: inout Path, _ rect: CGRect, _ start: CGPoint, _ end: CGPoint) {
        path.move(to: map(start, in: rect))
        path.addLine(to: map(end, in: rect))
    }

    private func map(_ point: CGPoint, in rect: CGRect) -> CGPoint {
        CGPoint(
            x: rect.minX + point.x * rect.width,
            y: rect.minY + point.y * rect.height
        )
    }
}

#Preview {
    ActionManRenderer(pose: .guardStance)
        .frame(width: 220, height: 320)
        .padding()
}
