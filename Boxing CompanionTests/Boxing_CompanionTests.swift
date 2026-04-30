//
//  Boxing_CompanionTests.swift
//  Boxing CompanionTests
//
//  Created by Jordan Lyne on 29/04/2026.
//

import Testing
@testable import Boxing_Companion

struct Boxing_CompanionTests {

    @MainActor
    @Test func engineStartsFallbackWorkoutAndCanNavigateBlocks() async throws {
        var engine = WorkoutSessionEngine()

        engine.startStop()
        engine.tick()

        #expect(engine.isRunning)
        #expect(engine.canMoveNext)

        engine.nextBlock()

        #expect(engine.canMovePrevious)
    }

    @MainActor
    @Test func zeroDurationBlocksAreMadePlayable() async throws {
        var engine = WorkoutSessionEngine()
        engine.setWorkout(
            WorkoutSession(
                title: "Zero Duration Test",
                blocks: [
                    WorkoutSessionBlock(title: "Zero", type: .skill, durationSeconds: 0, animationID: nil),
                    WorkoutSessionBlock(title: "Next", type: .skill, durationSeconds: 0, animationID: nil)
                ]
            )
        )

        #expect(engine.formattedTimeRemaining == "1:00")

        engine.startStop()
        engine.tick()

        #expect(engine.isRunning)
        #expect(engine.formattedTimeRemaining == "0:59")
    }

}
