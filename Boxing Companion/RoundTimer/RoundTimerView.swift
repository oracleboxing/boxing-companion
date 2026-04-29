import SwiftUI
import Combine

struct RoundTimerView: View {
    private let roundDurations = [60, 120, 180, 240, 300]
    private let restDurations = [30, 45, 60, 90, 120]
    private let rounds = Array(1...12) + [0]
    private let prepareOptions = [0, 10, 30]

    @State private var selectedRoundDuration = 180
    @State private var selectedRestDuration = 60
    @State private var selectedRounds = 4
    @State private var selectedPrepareDuration = 0
    @State private var isInSetup = true
    @State private var engine = RoundTimerEngine(prepareDuration: 0, roundDuration: 180, restDuration: 60, totalRounds: 4)

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 22) {
                Spacer(minLength: 8)

                if !isInSetup {
                    VStack(spacing: 10) {
                        Text(formattedTime(engine.secondsRemaining))
                            .font(.system(size: 168, weight: .heavy, design: .default))
                            .fontWidth(.condensed)
                            .monospacedDigit()
                        .scaleEffect(x: 0.94, y: 1.34, anchor: .center)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .foregroundStyle(timerTextColor)

                        Text(roundProgressText)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(progressTextColor)
                    }
                }

                if isInSetup {
                    RoundTimerWheelRow(
                        restSelection: $selectedRestDuration,
                        roundSelection: $selectedRoundDuration,
                        roundsSelection: $selectedRounds,
                        restValues: restDurations,
                        roundValues: roundDurations,
                        rounds: rounds
                    )
                    .onChange(of: selectedRoundDuration) { _, _ in applySettings() }
                    .onChange(of: selectedRestDuration) { _, _ in applySettings() }
                    .onChange(of: selectedRounds) { _, _ in applySettings() }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("PREPARE")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.primary.opacity(0.72))

                        Picker("Prepare", selection: $selectedPrepareDuration) {
                            ForEach(prepareOptions, id: \.self) { duration in
                                Text(prepareLabel(duration))
                                    .tag(duration)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.top, 18)
                }

                Spacer(minLength: 8)

                Button {
                    if isInSetup {
                        applySettings()
                        isInSetup = false
                        engine.startStop()
                    } else {
                        engine.startStop()
                    }
                } label: {
                    Text(engine.isRunning ? "STOP" : "START")
                        .font(.system(size: 44, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 104)
                }
                .buttonStyle(.plain)
                .background(startStopBackground)
                .foregroundStyle(startStopForegroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: startStopShadowColor, radius: 14, y: 8)
            }

            if !isInSetup {
                Button {
                    engine.reset()
                    isInSetup = true
                } label: {
                    Label("Back", systemImage: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(timerTextColor)
            }
        }
        .padding(24)
        .background(screenBackground.ignoresSafeArea())
        .onReceive(timer) { _ in
            engine.tick()
        }
    }

    private var roundProgressText: String {
        switch engine.phase {
        case .prepare:
            "PREPARE"
        case .round:
            selectedRounds == 0
                ? "ROUND \(engine.currentRound)"
                : "ROUND \(engine.currentRound) OF \(selectedRounds)"
        case .rest:
            "REST"
        case .complete:
            "COMPLETE"
        }
    }

    private var screenBackground: Color {
        !isInSetup && engine.phase == .rest
            ? Color(red: 0.05, green: 0.06, blue: 0.07)
            : Color.systemBackground
    }

    private var progressTextColor: Color {
        engine.phase == .rest
            ? Color.white.opacity(0.72)
            : .primary
    }

    private var timerTextColor: Color {
        !isInSetup && engine.phase == .rest
            ? .white
            : .primary
    }

    private func applySettings() {
        engine.applySettings(
            prepareDuration: selectedPrepareDuration,
            roundDuration: selectedRoundDuration,
            restDuration: selectedRestDuration,
            totalRounds: selectedRounds
        )
    }

    private func formattedTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }

    private func prepareLabel(_ seconds: Int) -> String {
        seconds == 0 ? "Off" : "\(seconds) sec"
    }

    private var startStopBackground: some ShapeStyle {
        LinearGradient(
            colors: engine.isRunning
                ? [Color(red: 1.00, green: 0.78, blue: 0.76), Color(red: 0.96, green: 0.62, blue: 0.59)]
                : [Color(red: 0.74, green: 0.93, blue: 0.76), Color(red: 0.55, green: 0.84, blue: 0.58)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var startStopShadowColor: Color {
        engine.isRunning
            ? Color(red: 0.68, green: 0.12, blue: 0.10).opacity(0.24)
            : Color(red: 0.12, green: 0.45, blue: 0.16).opacity(0.24)
    }

    private var startStopForegroundColor: Color {
        engine.isRunning
            ? Color(red: 0.55, green: 0.04, blue: 0.03)
            : Color(red: 0.02, green: 0.32, blue: 0.09)
    }

}

private extension Color {
    static var systemBackground: Color {
#if os(iOS)
        Color(uiColor: .systemBackground)
#elseif os(macOS)
        Color(nsColor: .windowBackgroundColor)
#else
        Color.white
#endif
    }
}

private struct RoundTimerWheelRow: View {
    @Binding var restSelection: Int
    @Binding var roundSelection: Int
    @Binding var roundsSelection: Int

    let restValues: [Int]
    let roundValues: [Int]
    let rounds: [Int]

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 0) {
                Text("REST").frame(maxWidth: .infinity)
                Text("ROUND").frame(maxWidth: .infinity)
                Text("ROUNDS").frame(maxWidth: .infinity)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.primary.opacity(0.72))

            GeometryReader { proxy in
                ZStack {
#if os(iOS)
                    NativeRoundPicker(
                        restSelection: $restSelection,
                        roundSelection: $roundSelection,
                        roundsSelection: $roundsSelection,
                        restValues: restValues,
                        roundValues: roundValues,
                        rounds: rounds
                    )
#else
                    HStack(spacing: 0) {
                        NumberWheel(selection: $restSelection, values: restValues) { "\($0)" }
                        NumberWheel(selection: $roundSelection, values: roundValues) { roundNumberLabel($0) }
                        NumberWheel(selection: $roundsSelection, values: rounds) { $0 == 0 ? "∞" : "\($0)" }
                    }
#endif
                    HStack(spacing: 0) {
                        FixedSelectionUnit(
                            "sec",
                            unitOffset: unitOffset(for: proxy.size.width),
                            numberOffset: numberOffset(for: proxy.size.width)
                        )
                        FixedSelectionUnit(
                            roundSelection < 60 ? "sec" : "min",
                            unitOffset: unitOffset(for: proxy.size.width),
                            numberOffset: numberOffset(for: proxy.size.width)
                        )
                        FixedSelectionUnit(
                            "",
                            unitOffset: unitOffset(for: proxy.size.width),
                            numberOffset: numberOffset(for: proxy.size.width)
                        )
                    }
                }
            }
            .frame(height: 164)
        }
    }

    private func numberOffset(for width: CGFloat) -> CGFloat {
        -(width / 3) * 0.12
    }

    private func unitOffset(for width: CGFloat) -> CGFloat {
        (width / 3) * 0.17
    }
}

#if os(iOS)
private struct NativeRoundPicker: UIViewRepresentable {
    @Binding var restSelection: Int
    @Binding var roundSelection: Int
    @Binding var roundsSelection: Int

    let restValues: [Int]
    let roundValues: [Int]
    let rounds: [Int]

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        picker.backgroundColor = .clear
        return picker
    }

    func updateUIView(_ picker: UIPickerView, context: Context) {
        context.coordinator.parent = self
        picker.selectRow(restValues.firstIndex(of: restSelection) ?? 0, inComponent: 0, animated: false)
        picker.selectRow(roundValues.firstIndex(of: roundSelection) ?? 0, inComponent: 1, animated: false)
        picker.selectRow(rounds.firstIndex(of: roundsSelection) ?? 0, inComponent: 2, animated: false)
    }

    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: NativeRoundPicker

        init(_ parent: NativeRoundPicker) {
            self.parent = parent
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            3
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch component {
            case 0:
                parent.restValues.count
            case 1:
                parent.roundValues.count
            case 2:
                parent.rounds.count
            default:
                0
            }
        }

        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            pickerView.bounds.width / 3
        }

        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            36
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            switch component {
            case 0:
                parent.restSelection = parent.restValues[row]
            case 1:
                parent.roundSelection = parent.roundValues[row]
            case 2:
                parent.roundsSelection = parent.rounds[row]
            default:
                break
            }
        }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = (view as? UILabel) ?? UILabel()
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 24, weight: .semibold)
            label.textColor = .label

            switch component {
            case 0:
                label.text = "\(parent.restValues[row])"
            case 1:
                label.text = roundNumberLabel(parent.roundValues[row])
            case 2:
                label.text = parent.rounds[row] == 0 ? "∞" : "\(parent.rounds[row])"
            default:
                label.text = ""
            }

            if component == 0 || component == 1 {
                let container = UIView()
                label.textAlignment = .right
                label.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: (pickerView.bounds.width / 3) * 0.50,
                    height: 36
                )
                container.addSubview(label)
                return container
            }

            return label
        }
    }
}
#endif

private struct NumberWheel: View {
    @Binding var selection: Int
    let values: [Int]
    let label: (Int) -> String

    var body: some View {
        picker
            .frame(maxWidth: .infinity, maxHeight: 150)
            .compositingGroup()
            .clipped()
    }

    @ViewBuilder
    private var picker: some View {
#if os(iOS)
        Picker("", selection: $selection) {
            ForEach(values, id: \.self) { value in
                Text(label(value))
                    .font(.title2.weight(.semibold))
                    .tag(value)
            }
        }
        .pickerStyle(.wheel)
        .labelsHidden()
#else
        Picker("", selection: $selection) {
            ForEach(values, id: \.self) { value in
                Text(label(value))
                    .tag(value)
            }
        }
        .pickerStyle(.menu)
        .labelsHidden()
#endif
    }
}

private func roundNumberLabel(_ seconds: Int) -> String {
    seconds < 60 ? "\(seconds)" : "\(seconds / 60)"
}

private func roundDurationLabel(_ seconds: Int) -> String {
    seconds < 60 ? "\(seconds) sec" : "\(seconds / 60) min"
}

private struct FixedSelectionUnit: View {
    let text: String
    let unitOffset: CGFloat
    let numberOffset: CGFloat

    init(_ text: String, unitOffset: CGFloat, numberOffset: CGFloat) {
        self.text = text
        self.unitOffset = unitOffset
        self.numberOffset = numberOffset
    }

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .center)
            .offset(x: text.isEmpty ? 0 : unitOffset - numberOffset)
            .allowsHitTesting(false)
    }
}

#Preview {
    RoundTimerView()
}
