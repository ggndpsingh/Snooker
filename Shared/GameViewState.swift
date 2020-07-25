//  Copyright © 2020 DeepGagan. All rights reserved.

import Foundation

class GameViewState {
    typealias PlayerState = (name: String, score: Int)
    
    private let playerA: String
    private let playerB: String
    let frame: FrameState
    
    var winner: PlayerState? {
        guard let position = frame.winnerPosition else { return nil }
        return position == .A ? playerAState : playerBState
    }
    
    var playerAState: PlayerState {
        (name: playerA, score: frame.scoreA)
    }
    
    var playerBState: PlayerState {
        (name: playerB, score: frame.scoreB)
    }
    
    struct FrameState: Equatable {
        let scoreA: Int
        let scoreB: Int
        let activePlayer: PlayerPosition
        let winnerPosition: PlayerPosition?
        let ballOn: BallOn
    }
    
    init(game: Game, frame: Frame) {
        self.playerA = game.playerOne.name
        self.playerB = game.playerTwo.name
        self.frame = .init(scoreA: frame.playerOneScore, scoreB: frame.playerTwoScore, activePlayer: frame.activePlayerPosition, winnerPosition: frame.winnerPosition, ballOn: frame.ballOn)
    }
}

extension GameViewState: Equatable {
    static func == (lhs: GameViewState, rhs: GameViewState) -> Bool {
        lhs.playerAState == rhs.playerAState &&
        lhs.playerBState == rhs.playerBState &&
        lhs.frame == rhs.frame
    }
}
