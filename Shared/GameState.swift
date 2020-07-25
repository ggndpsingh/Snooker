//  Copyright © 2020 DeepGagan. All rights reserved.

import Foundation

enum GameState: Equatable {
    case playing(GameViewState)
    case betweenFrames(FrameResultViewState)
    case gameOver
    
    init(game: Game) {
        if let frame = game.activeFrame {
            self = .playing(.init(game: game, frame: frame))
        } else if game.activeFrame == nil, let last = game.lastFrame, let winner = last.winnerPosition, let _ = game.nextFrame {
            let gameViewState = GameViewState(game: game, frame: last)
            let viewState = FrameResultViewState(playerA: gameViewState.playerA, playerB: gameViewState.playerB, winnerPosition: winner)
            self = .betweenFrames(viewState)
        } else {
            self = .gameOver
        }
    }
}

struct FrameResultViewState {
    let playerA: GameViewState.PlayerState
    let playerB: GameViewState.PlayerState
    let winner: GameViewState.PlayerState
    
    
    internal init(playerA: GameViewState.PlayerState, playerB: GameViewState.PlayerState, winnerPosition: PlayerPosition) {
        self.playerA = playerA
        self.playerB = playerB
        self.winner = winnerPosition == .A ? playerA : playerB
    }
}

extension FrameResultViewState: Equatable {
    static func == (lhs: FrameResultViewState, rhs: FrameResultViewState) -> Bool {
        lhs.playerA == rhs.playerA
    }
}
