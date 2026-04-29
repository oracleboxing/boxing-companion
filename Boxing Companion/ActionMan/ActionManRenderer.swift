import SwiftUI

struct ActionManRenderer: View {
    @Environment(\.colorScheme) private var colorScheme

    let pose: ActionManPose
    var lineColor: Color = .primary
    var accentColor: Color = Color(red: 0.84, green: 0.62, blue: 0.27)

    private var suitColor: Color {
        colorScheme == .dark
            ? Color(red: 0.92, green: 0.94, blue: 0.96)
            : Color(red: 0.08, green: 0.09, blue: 0.10)
    }

    private var shadowColor: Color {
        lineColor.opacity(colorScheme == .dark ? 0.18 : 0.10)
    }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let scale = min(size.width, size.height)
            let limbWidth = max(14, scale * 0.085)
            let armWidth = max(12, scale * 0.072)
            let jointSize = max(11, scale * 0.06)
            let gloveSize = max(23, scale * 0.16)
            let shoeSize = max(22, scale * 0.15)
            let headSize = max(34, scale * 0.18)

            ZStack {
                groundShadow(in: size)

                limb(from: pose.rightHip, to: pose.rightKnee, width: limbWidth, size: size)
                limb(from: pose.rightKnee, to: pose.rightFoot, width: limbWidth * 0.92, size: size)
                limb(from: pose.leftHip, to: pose.leftKnee, width: limbWidth, size: size)
                limb(from: pose.leftKnee, to: pose.leftFoot, width: limbWidth * 0.92, size: size)

                shoe(at: pose.rightFoot, size: shoeSize, canvasSize: size)
                shoe(at: pose.leftFoot, size: shoeSize, canvasSize: size)

                torso(in: size)

                limb(from: pose.rightShoulder, to: pose.rightElbow, width: armWidth, size: size)
                limb(from: pose.rightElbow, to: pose.rightGlove, width: armWidth * 0.92, size: size)
                limb(from: pose.leftShoulder, to: pose.leftElbow, width: armWidth, size: size)
                limb(from: pose.leftElbow, to: pose.leftGlove, width: armWidth * 0.92, size: size)

                joint(at: pose.rightElbow, size: jointSize, canvasSize: size)
                joint(at: pose.leftElbow, size: jointSize, canvasSize: size)
                joint(at: pose.rightKnee, size: jointSize, canvasSize: size)
                joint(at: pose.leftKnee, size: jointSize, canvasSize: size)

                head(size: headSize, canvasSize: size)

                glove(at: pose.rightGlove, size: gloveSize, canvasSize: size)
                glove(at: pose.leftGlove, size: gloveSize, canvasSize: size)
            }
            .animation(.linear(duration: 0.05), value: pose)
        }
    }

    private func torso(in size: CGSize) -> some View {
        let chest = map(pose.chest, in: size)
        let pelvis = map(pose.pelvis, in: size)
        let leftShoulder = map(pose.leftShoulder, in: size)
        let rightShoulder = map(pose.rightShoulder, in: size)
        let leftHip = map(pose.leftHip, in: size)
        let rightHip = map(pose.rightHip, in: size)

        return ZStack {
            ActionManTorsoShape(
                leftShoulder: leftShoulder,
                rightShoulder: rightShoulder,
                leftHip: leftHip,
                rightHip: rightHip
            )
            .fill(suitColor)
            .overlay(
                ActionManTorsoShape(
                    leftShoulder: leftShoulder,
                    rightShoulder: rightShoulder,
                    leftHip: leftHip,
                    rightHip: rightHip
                )
                .stroke(lineColor.opacity(0.9), lineWidth: max(2.5, min(size.width, size.height) * 0.014))
            )

            Capsule(style: .continuous)
                .fill(accentColor.opacity(0.95))
                .frame(width: max(7, size.width * 0.035), height: max(38, distance(chest, pelvis) * 0.82))
                .rotationEffect(.degrees(angle(from: chest, to: pelvis) + 90))
                .position(CGPoint(x: (chest.x + pelvis.x) / 2, y: (chest.y + pelvis.y) / 2))
                .opacity(0.9)
        }
    }

    private func limb(from start: CGPoint, to end: CGPoint, width: CGFloat, size: CGSize) -> some View {
        let startPoint = map(start, in: size)
        let endPoint = map(end, in: size)
        let length = max(1, distance(startPoint, endPoint))
        let midpoint = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)

        return Capsule(style: .continuous)
            .fill(suitColor)
            .overlay(
                Capsule(style: .continuous)
                    .stroke(lineColor.opacity(0.82), lineWidth: max(2, width * 0.16))
            )
            .frame(width: length, height: width)
            .rotationEffect(.degrees(angle(from: startPoint, to: endPoint)))
            .position(midpoint)
    }

    private func head(size: CGFloat, canvasSize: CGSize) -> some View {
        ZStack {
            Circle()
                .fill(suitColor)
                .overlay(Circle().stroke(lineColor.opacity(0.92), lineWidth: max(2.5, size * 0.09)))

            Capsule(style: .continuous)
                .fill(accentColor.opacity(0.92))
                .frame(width: size * 0.46, height: size * 0.10)
                .offset(x: -size * 0.04, y: -size * 0.02)

            Circle()
                .fill(lineColor.opacity(0.78))
                .frame(width: size * 0.08, height: size * 0.08)
                .offset(x: -size * 0.13, y: -size * 0.04)
        }
        .frame(width: size, height: size)
        .position(map(pose.head, in: canvasSize))
    }

    private func glove(at point: CGPoint, size: CGFloat, canvasSize: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.33, style: .continuous)
                .fill(accentColor)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.33, style: .continuous)
                        .stroke(lineColor.opacity(0.86), lineWidth: max(2.5, size * 0.12))
                )

            Circle()
                .fill(accentColor.opacity(0.82))
                .overlay(Circle().stroke(lineColor.opacity(0.55), lineWidth: max(1.5, size * 0.06)))
                .frame(width: size * 0.43, height: size * 0.43)
                .offset(x: -size * 0.22, y: -size * 0.08)
        }
        .frame(width: size * 0.9, height: size)
        .rotationEffect(.degrees(-8))
        .position(map(point, in: canvasSize))
    }

    private func shoe(at point: CGPoint, size: CGFloat, canvasSize: CGSize) -> some View {
        Capsule(style: .continuous)
            .fill(suitColor)
            .overlay(
                Capsule(style: .continuous)
                    .stroke(lineColor.opacity(0.88), lineWidth: max(2, size * 0.10))
            )
            .frame(width: size * 1.25, height: size * 0.48)
            .rotationEffect(.degrees(-4))
            .position(map(point, in: canvasSize))
    }

    private func joint(at point: CGPoint, size: CGFloat, canvasSize: CGSize) -> some View {
        Circle()
            .fill(suitColor)
            .overlay(Circle().stroke(lineColor.opacity(0.65), lineWidth: max(1.5, size * 0.12)))
            .frame(width: size, height: size)
            .position(map(point, in: canvasSize))
    }

    private func groundShadow(in size: CGSize) -> some View {
        Ellipse()
            .fill(shadowColor)
            .frame(width: size.width * 0.58, height: size.height * 0.08)
            .position(x: size.width * 0.52, y: size.height * 0.94)
    }

    private func map(_ point: CGPoint, in size: CGSize) -> CGPoint {
        CGPoint(x: point.x * size.width, y: point.y * size.height)
    }

    private func distance(_ start: CGPoint, _ end: CGPoint) -> CGFloat {
        hypot(end.x - start.x, end.y - start.y)
    }

    private func angle(from start: CGPoint, to end: CGPoint) -> CGFloat {
        atan2(end.y - start.y, end.x - start.x) * 180 / .pi
    }
}

private struct ActionManTorsoShape: Shape {
    let leftShoulder: CGPoint
    let rightShoulder: CGPoint
    let leftHip: CGPoint
    let rightHip: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: leftShoulder)
        path.addQuadCurve(to: rightShoulder, control: midpoint(leftShoulder, rightShoulder, yOffset: -10))
        path.addLine(to: rightHip)
        path.addQuadCurve(to: leftHip, control: midpoint(leftHip, rightHip, yOffset: 8))
        path.closeSubpath()
        return path
    }

    private func midpoint(_ first: CGPoint, _ second: CGPoint, yOffset: CGFloat) -> CGPoint {
        CGPoint(x: (first.x + second.x) / 2, y: (first.y + second.y) / 2 + yOffset)
    }
}

#Preview {
    VStack(spacing: 24) {
        ActionManRenderer(pose: .guardStance)
            .frame(width: 220, height: 320)

        ActionManRenderer(pose: .guardStance.offset(y: 0.03), lineColor: .white)
            .frame(width: 220, height: 320)
            .padding()
            .background(Color.black)
    }
    .padding()
}
