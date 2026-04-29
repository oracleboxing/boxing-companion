import Foundation

struct WorkoutSession {
    var title: String
    var blocks: [WorkoutSessionBlock]

    var firstBlock: WorkoutSessionBlock {
        blocks.first ?? WorkoutSessionBlock(title: title, type: .unknown, durationSeconds: 0, animationID: nil)
    }

    static let placeholder = WorkoutSession(
        title: "Workout Alpha",
        blocks: [
            WorkoutSessionBlock(title: "Workout Alpha", type: .unknown, durationSeconds: 0, animationID: "guard_bounce")
        ]
    )
}

struct WorkoutSessionBlock: Identifiable, Equatable {
    var id = UUID()
    var title: String
    var type: WorkoutSessionBlockType
    var durationSeconds: Int
    var animationID: String?
}

enum WorkoutSessionBlockType: String {
    case prep
    case warmup
    case skill
    case recovery
    case cooldown
    case unknown
}

struct WorkoutSessionEngine {
    private(set) var workout = WorkoutSession.placeholder
    private(set) var isRunning = false
    private(set) var currentBlockIndex = 0
    private(set) var secondsRemaining = 0

    var primaryActionTitle: String {
        isRunning ? "STOP" : "START"
    }

    var liveText: String {
        currentBlock.title
    }

    var canMovePrevious: Bool {
        currentBlockIndex > 0
    }

    var canMoveNext: Bool {
        currentBlockIndex + 1 < workout.blocks.count
    }

    var formattedTimeRemaining: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var isResting: Bool {
        currentBlock.type == .recovery
    }

    var currentAnimationID: String {
        ActionManAnimationMapper.animationID(for: currentBlock)
    }

    private var currentBlock: WorkoutSessionBlock {
        guard workout.blocks.indices.contains(currentBlockIndex) else {
            return workout.firstBlock
        }

        return workout.blocks[currentBlockIndex]
    }

    mutating func setWorkout(_ workout: WorkoutSession) {
        self.workout = workout
        reset()
    }

    mutating func startStop() {
        if secondsRemaining == 0 {
            reset()
        }

        isRunning.toggle()
    }

    mutating func reset() {
        isRunning = false
        currentBlockIndex = 0
        secondsRemaining = workout.firstBlock.durationSeconds
    }

    mutating func previousBlock() {
        guard canMovePrevious else { return }

        currentBlockIndex -= 1
        secondsRemaining = currentBlock.durationSeconds
    }

    mutating func nextBlock() {
        guard canMoveNext else { return }

        currentBlockIndex += 1
        secondsRemaining = currentBlock.durationSeconds
    }

    mutating func tick() {
        guard isRunning else { return }

        guard secondsRemaining > 0 else {
            advance()
            return
        }

        if secondsRemaining > 1 {
            secondsRemaining -= 1
            return
        }

        advance()
    }

    private mutating func advance() {
        guard currentBlockIndex + 1 < workout.blocks.count else {
            isRunning = false
            secondsRemaining = 0
            return
        }

        currentBlockIndex += 1
        secondsRemaining = currentBlock.durationSeconds
    }
}
