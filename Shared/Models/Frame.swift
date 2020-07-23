//  Copyright © 2020 DeepGagan. All rights reserved.

import Foundation

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
