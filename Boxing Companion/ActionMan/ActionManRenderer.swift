import SwiftUI

struct ActionManRenderer: View {
    @Environment(\.colorScheme) private var colorScheme

    let pose: ActionManPose
    var lineColor: Color = .primary

    private let gloveColor = Color(red: 0.96, green: 0.62, blue: 0.59)
    private let gloveHighlightColor = Color(red: 1.00, green: 0.78, blue: 0.76)
    private let gloveStrokeColor = Color(red: 0.55, green: 0.04, blue: 0.03)
    private let shoeColor = Color(red: 0.55, green: 0.84, blue: 0.58)
    private let shoeHighlightColor = Color(red: 0.74, green: 0.93, blue: 0.76)
    private let shoeStrokeColor = Color(red: 0.02, green: 0.32, blue: 0.09)

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
            let limbWidth = max(16, scale * 0.105)
            let armWidth = max(14, scale * 0.095)
            let gloveSize = max(34, scale * 0.225)
            let shoeSize = max(28, scale * 0.19)
            let headSize = max(42, scale * 0.245)

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
        let neck = map(pose.neck, in: size)

        return ZStack {
            Capsule(style: .continuous)
                .fill(suitColor)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(lineColor.opacity(0.65), lineWidth: max(2, min(size.width, size.height) * 0.012))
                )
                .frame(width: max(22, size.width * 0.15), height: max(72, distance(neck, pelvis)))
                .rotationEffect(.degrees(angle(from: neck, to: pelvis) + 90))
                .position(CGPoint(x: (neck.x + pelvis.x) / 2, y: (neck.y + pelvis.y) / 2))

            ActionManShortsShape()
                .fill(suitColor)
                .overlay(ActionManShortsShape().stroke(lineColor.opacity(0.65), lineWidth: max(2, size.width * 0.012)))
                .frame(width: max(48, size.width * 0.30), height: max(28, size.height * 0.105))
                .position(CGPoint(x: (chest.x + pelvis.x) / 2, y: (chest.y + pelvis.y) / 2))
                .offset(y: max(30, size.height * 0.10))
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
                .overlay(Circle().stroke(lineColor.opacity(0.72), lineWidth: max(2.5, size * 0.075)))

            Capsule(style: .continuous)
                .fill(Color.white.opacity(colorScheme == .dark ? 0.92 : 0.96))
                .frame(width: size * 0.58, height: size * 0.10)
                .offset(x: -size * 0.02, y: -size * 0.16)
        }
        .frame(width: size, height: size)
        .position(map(pose.head, in: canvasSize))
    }

    private func glove(at point: CGPoint, size: CGFloat, canvasSize: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.33, style: .continuous)
                .fill(gloveColor)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.33, style: .continuous)
                        .stroke(gloveStrokeColor.opacity(colorScheme == .dark ? 0.95 : 0.86), lineWidth: max(3, size * 0.10))
                )

            Circle()
                .fill(gloveHighlightColor.opacity(0.82))
                .overlay(Circle().stroke(gloveStrokeColor.opacity(0.55), lineWidth: max(1.5, size * 0.06)))
                .frame(width: size * 0.43, height: size * 0.43)
                .offset(x: -size * 0.22, y: -size * 0.08)
        }
        .frame(width: size * 0.9, height: size)
        .rotationEffect(.degrees(-8))
        .position(map(point, in: canvasSize))
    }

    private func shoe(at point: CGPoint, size: CGFloat, canvasSize: CGSize) -> some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(shoeColor)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(shoeStrokeColor.opacity(colorScheme == .dark ? 0.95 : 0.88), lineWidth: max(2, size * 0.10))
                )

            Capsule(style: .continuous)
                .fill(shoeHighlightColor.opacity(0.72))
                .frame(width: size * 0.52, height: size * 0.10)
                .offset(x: size * 0.15, y: -size * 0.06)
        }
        .frame(width: size * 1.25, height: size * 0.48)
        .rotationEffect(.degrees(-4))
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

private struct ActionManShortsShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.16, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.12, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.26, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX + rect.width * 0.06, y: rect.minY + rect.height * 0.82))
        path.addLine(to: CGPoint(x: rect.midX - rect.width * 0.06, y: rect.minY + rect.height * 0.82))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.26, y: rect.maxY))
        path.closeSubpath()
        return path
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
