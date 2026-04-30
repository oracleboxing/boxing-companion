import SwiftUI

struct WorkoutRunnerRouterView: View {
    let engine: WorkoutSessionEngine
    let primaryTextColor: Color

    var body: some View {
        switch engine.discipline {
        case .running:
            RunningRunnerView(engine: engine, primaryTextColor: primaryTextColor)
        case .strengthConditioning:
            StrengthRunnerView(engine: engine, primaryTextColor: primaryTextColor)
        case .boxing, .hybrid, .unknown, .all:
            BoxingRunnerView(engine: engine, primaryTextColor: primaryTextColor)
        }
    }
}

struct BoxingRunnerView: View {
    let engine: WorkoutSessionEngine
    let primaryTextColor: Color

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ActionManView(
                    animationID: engine.currentAnimationID,
                    isPlaying: engine.isRunning,
                    lineColor: primaryTextColor
                )
                .frame(width: 190, height: 270)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            ZStack {
                Color.clear

                Text(engine.formattedTimeRemaining)
                    .font(.system(size: 100, weight: .heavy, design: .default))
                    .fontWidth(.condensed)
                    .monospacedDigit()
                    .scaleEffect(x: 0.94, y: 1.2, anchor: .center)
                    .foregroundStyle(primaryTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .offset(y: 18)
            }
            .frame(height: 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct StrengthRunnerView: View {
    let engine: WorkoutSessionEngine
    let primaryTextColor: Color

    private var block: WorkoutSessionBlock {
        engine.currentSessionBlock
    }

    var body: some View {
        VStack(spacing: 14) {
            ActionManView(
                animationID: engine.currentAnimationID,
                isPlaying: engine.isRunning,
                lineColor: primaryTextColor
            )
            .frame(width: 210, height: 250)

            Text(engine.formattedTimeRemaining)
                .font(.system(size: 74, weight: .heavy, design: .default))
                .fontWidth(.condensed)
                .monospacedDigit()
                .foregroundStyle(primaryTextColor)
                .lineLimit(1)

            VStack(spacing: 10) {
                if let prescription = block.prescription, !prescription.isEmpty {
                    ProcedureRow(label: "Prescription", value: prescription, primaryTextColor: primaryTextColor)
                }

                if !block.equipment.isEmpty {
                    ProcedureRow(label: "Equipment", value: block.equipment.joined(separator: ", "), primaryTextColor: primaryTextColor)
                }

                if let nextBlock = engine.nextSessionBlock {
                    ProcedureRow(label: "Next", value: nextBlock.title, primaryTextColor: primaryTextColor)
                }
            }
            .padding(14)
            .background(primaryTextColor.opacity(0.07), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct RunningRunnerView: View {
    let engine: WorkoutSessionEngine
    let primaryTextColor: Color

    private var block: WorkoutSessionBlock {
        engine.currentSessionBlock
    }

    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: 6) {
                Text(runningStateTitle)
                    .font(.system(size: 14, weight: .heavy))
                    .tracking(1.2)
                    .textCase(.uppercase)
                    .foregroundStyle(primaryTextColor.opacity(0.65))

                Text(engine.formattedTimeRemaining)
                    .font(.system(size: 118, weight: .heavy, design: .default))
                    .fontWidth(.condensed)
                    .monospacedDigit()
                    .foregroundStyle(primaryTextColor)
                    .minimumScaleFactor(0.65)
                    .lineLimit(1)
            }

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    MetricTile(title: "Speed", value: block.intensity ?? "Easy", primaryTextColor: primaryTextColor)
                    MetricTile(title: "Incline", value: block.incline ?? "Flat", primaryTextColor: primaryTextColor)
                }

                if let repeatCount = block.repeatCount {
                    HStack(spacing: 12) {
                        MetricTile(title: "Repeats", value: "x\(repeatCount)", primaryTextColor: primaryTextColor)
                        MetricTile(title: "Split", value: splitLabel, primaryTextColor: primaryTextColor)
                    }
                }

                if let nextBlock = engine.nextSessionBlock {
                    ProcedureRow(label: "Next", value: nextBlock.title, primaryTextColor: primaryTextColor)
                }
            }
            .padding(14)
            .background(primaryTextColor.opacity(0.07), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var runningStateTitle: String {
        if block.type == .recovery { return "Recover" }
        if block.type == .runningIntervals { return "Interval Work" }
        if block.type == .cooldown { return "Cool Down" }
        return "Treadmill Settings"
    }

    private var splitLabel: String {
        guard let workSeconds = block.workSeconds, let restSeconds = block.restSeconds else {
            return "Timed"
        }

        return "\(workSeconds)s / \(restSeconds)s"
    }
}

private struct MetricTile: View {
    let title: String
    let value: String
    let primaryTextColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .heavy))
                .tracking(1.0)
                .textCase(.uppercase)
                .foregroundStyle(primaryTextColor.opacity(0.6))

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(primaryTextColor)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(primaryTextColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct ProcedureRow: View {
    let label: String
    let value: String
    let primaryTextColor: Color

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(label)
                .font(.system(size: 12, weight: .heavy))
                .tracking(1.0)
                .textCase(.uppercase)
                .foregroundStyle(primaryTextColor.opacity(0.6))
                .frame(width: 92, alignment: .leading)

            Text(value)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(primaryTextColor)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
