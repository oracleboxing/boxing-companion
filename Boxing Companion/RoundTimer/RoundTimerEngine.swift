import Foundation

enum RoundTimerPhase {
    case prepare
    case round
    case rest
    case complete
}

struct RoundTimerEngine {
    var prepareDuration: Int
    var roundDuration: Int
    var restDuration: Int
    var totalRounds: Int
    private(set) var currentRound = 1
    private(set) var phase: RoundTimerPhase = .round
    private(set) var secondsRemaining: Int
    private(set) var isRunning = false

    init(prepareDuration: Int = 0, roundDuration: Int, restDuration: Int, totalRounds: Int) {
        self.prepareDuration = prepareDuration
        self.roundDuration = roundDuration
        self.restDuration = restDuration
        self.totalRounds = totalRounds
        self.secondsRemaining = roundDuration
    }

    mutating func startStop() {
        if phase == .complete {
            reset()
        }

        isRunning.toggle()
    }

    mutating func reset() {
        currentRound = 1
        phase = prepareDuration > 0 ? .prepare : .round
        secondsRemaining = prepareDuration > 0 ? prepareDuration : roundDuration
        isRunning = false
    }

    mutating func applySettings(prepareDuration: Int, roundDuration: Int, restDuration: Int, totalRounds: Int) {
        self.prepareDuration = prepareDuration
        self.roundDuration = roundDuration
        self.restDuration = restDuration
        self.totalRounds = totalRounds
        reset()
    }

    mutating func tick() {
        guard isRunning else { return }

        if secondsRemaining > 1 {
            secondsRemaining -= 1
            return
        }

        advance()
    }

    private mutating func advance() {
        switch phase {
        case .prepare:
            phase = .round
            secondsRemaining = roundDuration
        case .round:
            if totalRounds > 0 && currentRound >= totalRounds {
                phase = .complete
                isRunning = false
                secondsRemaining = 0
            } else if restDuration > 0 {
                phase = .rest
                secondsRemaining = restDuration
            } else {
                currentRound += 1
                secondsRemaining = roundDuration
            }
        case .rest:
            currentRound += 1
            phase = .round
            secondsRemaining = roundDuration
        case .complete:
            isRunning = false
        }
    }
}
