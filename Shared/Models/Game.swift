//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

class GameViewState: CustomStringConvertible {
    @Published var playerA: GameViewState.Player
    @Published var playerB: GameViewState.Player
    var activePlayer: PlayerType
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
    
    init(
        playerA: GameViewState.Player = .init(name: "", score: 0),
        playerB: GameViewState.Player = .init(name: "", score: 0),
        activePlayer: PlayerType,
        ballOn: BallOn)
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

class Game: Identifiable, ObservableObject {
    let id: String = UUID.id
    var playerOne: Player
    var playerTwo: Player
    
    private let frames: [Frame]
    var activeFrame: Frame { frames[frames.count - 1] }
    
    @Published var viewState: GameViewState
    
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
        
        viewState = .init(
            playerA: .init(name: playerOne.name, score: 0),
            playerB: .init(name: playerTwo.name, score: 0),
            activePlayer: .A,
            ballOn: .red)
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
        
        viewState = .init(
            playerA: .init(name: playerOne.name, score: activeFrame.playerOneScore),
            playerB: .init(name: playerTwo.name, score: activeFrame.playerTwoScore),
            activePlayer: activeFrame.activePlayerType,
            ballOn: activeFrame.ballOn)
    }
    
    enum Action {
        case pot(Ball)
        case switchPlayer
    }
}

class Frame: Identifiable, ObservableObject, CustomStringConvertible {
    let id: String = UUID.id
    var playerOneScore: Int = 0
    var playerTwoScore: Int = 0
    var ballOn: BallOn = .red
    
    var totalReds: Int = 3
    var pottedReds: Int = 0
    var lastBallPotted: Ball?
    var remainingReds: Int { totalReds - pottedReds }
    var remainingColors: [Ball] = Ball.colors
    var onFinalColors: Bool = false
    
    var activePlayerType: PlayerType = .A {
        didSet {
            ballOn = .red
        }
    }
    
    func switchPlayer() {
        lastBallPotted = nil
        activePlayerType.toggle()
        onFinalColors = remainingReds == 0
        ballOn = getBallOn(afterPot: nil)
        print("Switch Player")
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
        ballOn = getBallOn(afterPot: ball)
        switch activePlayerType {
        case .A:
            playerOneScore += ball.points
        case .B:
            playerTwoScore += ball.points
        }
        print("Pot: \(ball.description)")
        logDetails()
    }
    
    func getBallOn(afterPot ball: Ball?) -> BallOn {
        switch ball {
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
