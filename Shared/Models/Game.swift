//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

class StateViewModel: ObservableObject {
    @Published var state: GameState = .gameNotStarted
    let game: Game
    
    init(game: Game) {
        self.game = game
        self.game.updateHandler = updateHandler
    }
    
    func startGame() {
        guard let _ = game.startNextFrame() else { return }
        state = .init(game: game)
    }
    
    private func updateHandler() {
        state = .init(game: game)
    }
}

enum GameState: Equatable {
    static func == (lhs: GameState, rhs: GameState) -> Bool {
        switch (lhs, rhs) {
        case (.gameNotStarted, .gameNotStarted):
            return true
        case (.gameOver, .gameOver):
            return true
        case (.playing(let gameA), .playing(let gameB)):
            return gameA.viewState == gameB.viewState
        case (.betweenFrames(let framesALast, let framesANext), .betweenFrames(let framesBLast, let framesBNext)):
            return framesALast == framesBLast && framesANext == framesBNext
        default:
            return false
        }
    }
    
    case gameNotStarted
    case playing(GameViewModel)
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
    
    
}

class GameViewModel: ObservableObject {
    private var game: Game
    private var frame: Frame
    
    var viewState: GameViewState {
        willSet {
            objectWillChange.send()
        }
    }
    
    init(game: Game, frame: Frame) {
        self.game = game
        self.frame = frame
        viewState = .init(game: game, frame: frame)
    }
    
    func startNextFrame() {
        guard let frame = game.startNextFrame() else { return }
        self.frame = frame
        updateFrameStatus()
        updateViewState()
    }
    
    func perform(_ action: Game.Action) {
        game.perform(action)
        updateFrameStatus()
        updateViewState()
    }
    
    func reset() {
        game.reset()
        updateViewState()
    }
    
    func updateViewState() {
        viewState = .init(game: game, frame: frame)
    }
    
    func updateFrameStatus() {
        guard let frame = game.activeFrame, frame.isDecided else { return }
        
    }
}

class GameViewState: Equatable {
    static func == (lhs: GameViewState, rhs: GameViewState) -> Bool {
        lhs.playerAState == rhs.playerAState &&
        lhs.playerBState == rhs.playerBState &&
        lhs.frame == rhs.frame
    }
    
    typealias PlayerState = (name: String, score: Int)
    private let playerA: String
    private let playerB: String
    let frame: FrameState
    
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
        let ballOn: BallOn
    }
    
    init(game: Game, frame: Frame) {
        self.playerA = game.playerOne.name
        self.playerB = game.playerTwo.name
        self.frame = .init(scoreA: frame.playerOneScore, scoreB: frame.playerTwoScore, activePlayer: frame.activePlayerPosition, ballOn: frame.ballOn)
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
    
    func startNextFrame() -> Frame? {
        guard !pendingFrames.isEmpty else { return nil }
        let nextFrame = pendingFrames[0]
        let nextFrameIndex = frames.firstIndex(of: nextFrame)!
        activeFrame = nextFrame
        timeline.appendAction(.beginGame)
        timeline.appendAction(.startFrame(nextFrameIndex, nextFrame))
        return nextFrame
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
    
    func reset() {
        self.frames = {
            var frames: [Frame] = []
            let count = max (self.frames.count, 1)
            for i in 0..<count {
                let toBreak: PlayerPosition = i.isMultiple(of: 2) ? .A : .B
                frames.append(.init(toBreak: toBreak))
            }
            return frames
        }()
        self.playerOne = Game.testGame.playerOne
        self.playerTwo = Game.testGame.playerTwo
    }
    
    func player(at position: PlayerPosition) -> Player {
        position == .A ? playerOne : playerTwo
    }
    
    enum Action {
        case pot(Ball)
        case switchPlayer
    }
}

class Frame: Identifiable, Equatable {
    static func == (lhs: Frame, rhs: Frame) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String = UUID.id
    var status: Status = .uninitialized
    
    var playerOneScore: Int = 0
    var playerTwoScore: Int = 0
    var ballOn: BallOn {
        switch lastBallPotted {
            case .none:
                if remainingReds > 0 {
                    return .red
                } else if onFinalColors {
                    return .color(remainingColors[0])
                } else {
                    return .colors
                }
        case .some(let ball):
            if ball == .red {
                return .colors
            }
            
            if remainingReds > 0 {
                return .red
            }
            
            if remainingColors.count > 0 {
                return .color(remainingColors[0])
            }
            
            return .none
        }
    }
    
    var totalReds: Int = 1
    var pottedReds: Int = 0
    var lastBallPotted: Ball?
    var remainingReds: Int { totalReds - pottedReds }
    var remainingColors: [Ball] = Ball.colors
    var onFinalColors: Bool = false
    
    var activePlayerPosition: PlayerPosition
    
    init(toBreak player: PlayerPosition) {
        self.activePlayerPosition = player
    }
    
    var winnerPosition: PlayerPosition? {
        switch status {
        case .decided(let position):
            return position
        default:
            return nil
        }
    }
    
    var isDecided: Bool {
        if case .decided(_) = status { return true }
        return false
    }
    
    func switchPlayer() {
        lastBallPotted = nil
        activePlayerPosition.toggle()
        onFinalColors = remainingReds == 0
    }
    
    func potRed() {
        pottedReds += 1
        pot(.red)
    }
    
    func potColor(_ ball: Ball) {
        if onFinalColors {
            remainingColors.removeFirst()
        }
        
        onFinalColors = remainingReds == 0
        pot(ball)
    }
    
    func pot(_ ball: Ball) {
        lastBallPotted = ball
        switch activePlayerPosition {
        case .A:
            playerOneScore += ball.points
        case .B:
            playerTwoScore += ball.points
        }
        setDecided()
    }
    
    func setDecided() {
        guard ballOn == .none else { return }
        status = .decided(playerOneScore > playerTwoScore ? .A : .B)
    }
    
    var description: String {
        """
            Remaining Reds: \(remainingReds)
            Remaining Colors: \(remainingColors.map{ $0.description })
            Scores: \(playerOneScore) - \(playerTwoScore)
            On Final Colors: \(onFinalColors)
        """
    }
    
    func logDetails() {
        print(description)
    }
    
    enum Status {
        case uninitialized
        case decided(PlayerPosition)
        case current
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
