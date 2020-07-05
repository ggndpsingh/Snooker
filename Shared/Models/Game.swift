//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

class GameViewModel: ObservableObject {
    private var game: Game
    var viewState: GameViewState {
        willSet {
            objectWillChange.send()
        }
    }
    
    init(game: Game) {
        self.game = game
        viewState = .init(game: game)
    }
    
    func perform(_ action: Game.Action) {
        game.perform(action)
        updateFrameStatus()
        viewState = .init(game: game)
    }
    
    func reset() {
        game.reset()
        viewState = .init(game: game)
    }
    
    func updateFrameStatus() {
        guard game.activeFrame.isDecided else { return }
        if !game.startNextFrame() {
            print("Game Over!")
        }
    }
}

class GameViewState: CustomStringConvertible {
    var playerA: GameViewState.Player
    var playerB: GameViewState.Player
    var activePlayer: PlayerPosition
    var ballOn: BallOn
    
    class Player: ObservableObject {
        let name: String
        @Published var score: Int
        
        internal init(name: String, score: Int) {
            self.name = name
            self.score = score
        }
        
        func setScore(_ score: Int) {
            self.score = score
        }
    }
    
    init(game: Game) {
        self.playerA = .init(name: game.playerOne.name, score: game.activeFrame.playerOneScore)
        self.playerB = .init(name: game.playerTwo.name, score: game.activeFrame.playerTwoScore)
        self.activePlayer = game.activeFrame.activePlayerPosition
        self.ballOn = game.activeFrame.ballOn
    }
    
    init(
        playerA: GameViewState.Player = .init(name: "", score: 0),
        playerB: GameViewState.Player = .init(name: "", score: 0),
        activePlayer: PlayerPosition = .A,
        ballOn: BallOn = .red)
    {
        self.playerA = playerA
        self.playerB = playerB
        self.activePlayer = activePlayer
        self.ballOn = ballOn
        
        print(self)
    }
    
    var description: String {
        """
            Player A: \(playerA.name) - \(playerA.score)
            Player B: \(playerB.name) - \(playerB.score)
            Ball On: \(ballOn)
        """
    }
}

class Game: Identifiable {
    let id: String = UUID.id
    var playerOne: Player
    var playerTwo: Player
    private var frames: [Frame]
    
    var activeFrame: Frame
    
    internal init(framesCount: Int, playerOne: Player, playerTwo: Player) {
        self.frames = {
            var frames: [Frame] = []
            let count = max (framesCount, 1)
            for _ in 0..<count {
                frames.append(.init())
            }
            return frames
        }()
        self.playerOne = playerOne
        self.playerTwo = playerTwo
        self.activeFrame = frames[0]
    }
    
    func perform(_ action: Action) {
        switch action {
        case .switchPlayer:
            activeFrame.switchPlayer()
        case .pot(let ball):
            switch ball {
            case .red:
                activeFrame.potRed()
            default:
                activeFrame.potColor(ball)
            }
        }
        print("\(frames.filter{$0.winnerPosition == .A}.count) (\(frames.count)) \(frames.filter{$0.winnerPosition == .B}.count)")
    }
    
    func startNextFrame() -> Bool {
        guard
            let activeIndex = frames.firstIndex(where: { $0.id == activeFrame.id }),
            activeIndex < frames.count - 1
        else { return false }
        
        activeFrame = frames[activeIndex + 1]
        return true
    }
    
    func reset() {
        self.frames = {
            var frames: [Frame] = []
            let count = max (self.frames.count, 1)
            for _ in 0..<count {
                frames.append(.init())
            }
            return frames
        }()
        self.playerOne = Game.testGame.playerOne
        self.playerTwo = Game.testGame.playerTwo
    }
    
    enum Action {
        case pot(Ball)
        case switchPlayer
    }
}

class Frame: Identifiable, ObservableObject, CustomStringConvertible {
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
    
    var totalReds: Int = 3
    var pottedReds: Int = 0
    var lastBallPotted: Ball?
    var remainingReds: Int { totalReds - pottedReds }
    var remainingColors: [Ball] = Ball.colors
    var onFinalColors: Bool = false
    
    var activePlayerPosition: PlayerPosition = .A
    
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
        logDetails()
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
