//  Copyright © 2020 DeepGagan. All rights reserved.

import Foundation

class GameViewState {
    typealias PlayerState = (name: String, score: Int)
    typealias FramesState = (a: Int, b: Int, total: Int)
    
    let playerA: PlayerState
    let playerB: PlayerState
    let frames: FramesState
    let activePlayer: PlayerPosition
    let ballOn: BallOn
    let toWinViewState: AvailablePointsViewState
    
    init(game: Game, frame: Frame) {
        playerA = (name: game.playerA.name, frame.playerAScore)
        playerB = (name: game.playerB.name, frame.playerBScore)
        frames = (game.framesWonByPlayerA.count, game.framesWonByPlayerB.count, game.frames.count)
        activePlayer = frame.activePlayerPosition
        ballOn = frame.ballOn
        toWinViewState = .init(frame: frame)
    }
}

extension GameViewState: Equatable {
    static func == (lhs: GameViewState, rhs: GameViewState) -> Bool {
        lhs.playerA == rhs.playerA &&
        lhs.playerB == rhs.playerB &&
        lhs.frames == rhs.frames &&
        lhs.activePlayer == rhs.activePlayer &&
        lhs.ballOn == rhs.ballOn
    }
}
