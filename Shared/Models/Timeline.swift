//  Copyright © 2020 DeepGagan. All rights reserved.

import Foundation

//struct Timeline {
//    private(set) var actions: [Action]
//    weak var game: Game?
//    
//    init(actions: [Action] = []) {
//        self.actions = actions
//    }
//    
//    mutating func appendAction(_ action: Action) {
//        actions.append(action)
//    }
//}
//
//extension Timeline {
//    struct GameInfo {
//        let id: String
//        let playerA: PlayerInfo
//        let playerB: PlayerInfo
//        let frameCount: Int
//    }
//    
//    struct PlayerInfo {
//        let id: String
//        let name: String
//    }
//}
//
//enum Action {
//    case beginGame
//    case startFrame(Int, Frame)
//    case endFrame(Int, Frame)
//    case endGame
//    case pot(Ball)
//    case foul(Ball)
//    case switchActivePlayer
//    
//    func description(in game: Game?) -> String {
//        guard let game = game else { return "" }
//
//        switch self {
//        case .beginGame:
//            return """
//            Started game
//            \(game.playerA.name) vs \(game.playerB.name)
//            \(game.frames.count) frames to be played
//            \n
//            """
//        case .startFrame(let index, _):
//            return """
//            Started frame \(index + 1)
//            \(game.activePlayer.name) to break
//            \n
//            """
//        case .endFrame(let index, let frame):
//            guard let position = frame.winnerPosition else { return "" }
//            let winner = game.player(at: position)
//            let (winnerScore, loserScore) = position == .A ? (frame.playerAScore, frame.playerBScore) : (frame.playerBScore, frame.playerAScore)
//            return """
//            Finished frame \(index + 1)
//            \(winner.name) has won the frame \(winnerScore) points to \(loserScore) points
//            \n
//            """
//        case .endGame:
//            return """
//            Started game \(game.playerA.name) vs \(game.playerB.name)
//            \n
//            """
//        case .pot(let ball):
//            return """
//            \(game.activePlayer.name) potted \(ball)
//            \n
//            """
//        case .foul(let ball):
//            return """
//            \(game.activePlayer.name) commited foul for \(ball.foulPoints) points
//            \n
//            """
//        case .switchActivePlayer:
//            return """
//            Switched to \(game.activePlayer.name)
//            \n
//            """
//        }
//    }
//}
