//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

class GameViewModel: ObservableObject {
    @Published var state: GameState = .gameNotStarted
    let game: Game
    
    init(game: Game) {
        self.game = game
        self.game.updateHandler = updateHandler
    }
    
    func startGame() {
        game.startNextFrame()
        state = .init(game: game)
    }
    
    func startNextFrame() {
        game.startNextFrame()
    }
    
    func perform(_ action: Game.Action) {
        game.perform(action)
    }
    
    private func updateHandler() {
        state = .init(game: game)
    }
}

enum GameState: Equatable {
    case gameNotStarted
    case playing(GameViewState)
    case betweenFrames(Frame, Frame)
    case gameOver
    
    init(game: Game) {
        if let frame = game.activeFrame {
            self = .playing(.init(game: game, frame: frame))
        } else if game.decidedFrames.isEmpty {
            self = .gameNotStarted
        } else if game.activeFrame == nil, let last = game.lastFrame, let next = game.nextFrame {
            self = .betweenFrames(last, next)
        } else {
            self = .gameOver
        }
    }
    
    static func == (lhs: GameState, rhs: GameState) -> Bool {
        switch (lhs, rhs) {
        case (.gameNotStarted, .gameNotStarted):
            return true
        case (.gameOver, .gameOver):
            return true
        case (.playing(let gameA), .playing(let gameB)):
            return gameA == gameB
        case (.betweenFrames(let framesALast, let framesANext), .betweenFrames(let framesBLast, let framesBNext)):
            return framesALast == framesBLast && framesANext == framesBNext
        default:
            return false
        }
    }
}

class Game: Identifiable {
    let id: String = UUID.id
    var playerOne: Player
    var playerTwo: Player
    var updateHandler: (() -> Void)?
    private(set) var frames: [Frame]
    private(set) var activeFrame: Frame?
    
    var decidedFrames: [Frame] { frames.filter { $0.isDecided } }
    var pendingFrames: [Frame] { frames.filter { !$0.isDecided } }
    var lastFrame: Frame? { decidedFrames.last }
    var nextFrame: Frame? { pendingFrames.first }
    
    var activePlayer: Player {
        activeFrame?.activePlayerPosition == .A ? playerOne : playerTwo
    }
    
    var timeline: Timeline = .init()
    
    internal init(framesCount: Int, playerOne: Player, playerTwo: Player) {
        self.frames = {
            var frames: [Frame] = []
            let count = max (framesCount, 1)
            for i in 0..<count {
                let toBreak: PlayerPosition = i.isMultiple(of: 2) ? .A : .B
                frames.append(.init(toBreak: toBreak))
            }
            return frames
        }()
        self.playerOne = playerOne
        self.playerTwo = playerTwo
        timeline.game = self
    }
    
    func startNextFrame(){
        guard !pendingFrames.isEmpty else { return }
        let nextFrame = pendingFrames[0]
        let nextFrameIndex = frames.firstIndex(of: nextFrame)!
        activeFrame = nextFrame
        timeline.appendAction(.beginGame)
        timeline.appendAction(.startFrame(nextFrameIndex, nextFrame))
    }
    
    func perform(_ action: Action) {
        switch action {
        case .switchPlayer:
            activeFrame?.switchPlayer()
            timeline.appendAction(.switchActivePlayer)
        case .pot(let ball):
            switch ball {
            case .red:
                activeFrame?.potRed()
            default:
                activeFrame?.potColor(ball)
            }
            timeline.appendAction(.pot(ball))
        }
        
        if let frame = activeFrame, frame.isDecided {
            activeFrame = nil
        }
        print("\(frames.filter{$0.winnerPosition == .A}.count) (\(frames.count)) \(frames.filter{$0.winnerPosition == .B}.count)")
        
        updateHandler?()
    }
    
    func player(at position: PlayerPosition) -> Player {
        position == .A ? playerOne : playerTwo
    }
    
    enum Action {
        case pot(Ball)
        case switchPlayer
    }
}

extension Game {
    static let testGame: Game = .init(
        framesCount: 3,
        playerOne: .init(
            id: UUID.id,
            name: "Gagandeep",
            score: 0),
        playerTwo: .init(
            id: UUID.id,
            name: "Omkar",
            score: 0)
    )
}
