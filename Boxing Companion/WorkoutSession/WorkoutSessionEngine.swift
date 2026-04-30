import Foundation

struct WorkoutSession {
    var title: String
    var discipline: WorkoutDiscipline
    var blocks: [WorkoutSessionBlock]

    init(title: String, discipline: WorkoutDiscipline = .boxing, blocks: [WorkoutSessionBlock]) {
        self.title = title
        self.discipline = discipline
        self.blocks = blocks.map(\.playable)
    }

    var firstBlock: WorkoutSessionBlock {
        blocks.first ?? WorkoutSessionBlock(title: title, type: .unknown, durationSeconds: 60, animationID: nil)
    }

    var totalDurationSeconds: Int {
        blocks.reduce(0) { $0 + $1.durationSeconds }
    }

    var totalDurationLabel: String {
        AppTimeFormatter.durationLabel(for: totalDurationSeconds)
    }
}

struct WorkoutSessionBlock: Identifiable, Equatable {
    var id = UUID()
    var title: String
    var type: WorkoutSessionBlockType
    var durationSeconds: Int
    var animationID: String?
    var intensity: String? = nil
    var incline: String? = nil
    var prescription: String? = nil
    var notes: String? = nil
    var cues: [String] = []
    var repeatCount: Int? = nil
    var workSeconds: Int? = nil
    var restSeconds: Int? = nil
    var equipment: [String] = []

    var hasRunningProcedure: Bool {
        intensity != nil || incline != nil || repeatCount != nil || workSeconds != nil || restSeconds != nil
    }

    var hasStrengthPrescription: Bool {
        prescription != nil || !equipment.isEmpty || !cues.isEmpty || notes != nil
    }

    var playable: WorkoutSessionBlock {
        guard durationSeconds > 0 else {
            var copy = self
            copy.durationSeconds = 60
            return copy
        }

        return self
    }

    var durationLabel: String {
        AppTimeFormatter.durationLabel(for: durationSeconds)
    }

    var typeLabel: String {
        switch type {
        case .prep: return "Prep"
        case .warmup: return "Warm Up"
        case .skill: return "Skill"
        case .running: return "Running"
        case .runningIntervals: return "Running Intervals"
        case .strength: return "Strength"
        case .conditioning: return "Conditioning"
        case .recovery: return "Recovery"
        case .cooldown: return "Cooldown"
        case .unknown: return "Workout"
        }
    }
}

enum WorkoutSessionBlockType: String {
    case prep
    case warmup
    case skill
    case running
    case runningIntervals = "running_intervals"
    case strength
    case conditioning
    case recovery
    case cooldown
    case unknown
}

struct WorkoutSessionEngine {
    private(set) var workout = WorkoutFallbackCatalog.defaultSession
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
        AppTimeFormatter.clockTime(for: secondsRemaining)
    }

    var isResting: Bool {
        currentBlock.type == .recovery
    }

    var currentAnimationID: String {
        ActionManAnimationMapper.animationID(for: currentBlock)
    }

    var discipline: WorkoutDiscipline {
        workout.discipline
    }

    var currentBlockNumber: Int {
        currentBlockIndex + 1
    }

    var totalBlocks: Int {
        workout.blocks.count
    }

    var currentSessionBlock: WorkoutSessionBlock {
        currentBlock
    }

    var nextSessionBlock: WorkoutSessionBlock? {
        let nextIndex = currentBlockIndex + 1
        guard workout.blocks.indices.contains(nextIndex) else { return nil }
        return workout.blocks[nextIndex]
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
        guard !workout.blocks.isEmpty, workout.firstBlock.durationSeconds > 0 else {
            isRunning = false
            return
        }

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
