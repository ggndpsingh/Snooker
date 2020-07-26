//  Copyright © 2020 DeepGagan. All rights reserved.

import Foundation

class Frame: Identifiable {
    let id: String = UUID.id
    private let totalReds: Int
    private(set) var status: Status = .uninitialized
    
    private(set) var playerAScore: Int = 0
    private(set) var playerBScore: Int = 0
    
    var activePlayerScore: Int {
        activePlayerPosition == .A ? playerAScore : playerBScore
    }
    
    var otherPlayerScore: Int {
        activePlayerPosition == .A ? playerBScore : playerAScore
    }
    
    private(set) var pottedReds: Int = 0
    private(set) var lastBallPotted: Ball?
    private(set) var remainingColors: [Ball] = Ball.colors
    private(set) var onFinalColors: Bool = false
    var pointsOnTheTable: Int {
        (remainingReds * 8) + availableColorPoints
    }
    
    private(set) var activePlayerPosition: PlayerPosition
    
    var remainingReds: Int { totalReds - pottedReds }
    private var isScoreTied: Bool { playerAScore == playerBScore }
    
    var ballOn: BallOn {
        switch lastBallPotted {
        case .none:
            if remainingReds > 0 {
                return .red
            } else if onFinalColors {
                if remainingColors.isEmpty && isScoreTied { return .color(.black) }
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
            
            if isScoreTied {
                return .color(.black)
            }
            
            return .none
        }
    }
    
    init(numberOfReds: Int, toBreak player: PlayerPosition) {
        totalReds = numberOfReds
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
    
    var isActive: Bool {
        if case .active = status { return true }
        return false
    }
    
    var isDecided: Bool {
        if case .decided(_) = status { return true }
        return false
    }
    
    func setActive() {
        status = .active
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
        if onFinalColors && !remainingColors.isEmpty {
            remainingColors.removeFirst()
        }
        
        onFinalColors = remainingReds == 0
        pot(ball)
    }
    
    private func pot(_ ball: Ball) {
        lastBallPotted = ball
        switch activePlayerPosition {
        case .A:
            playerAScore += ball.points
        case .B:
            playerBScore += ball.points
        }
        setDecided()
    }
    
    private func setDecided() {
        guard ballOn == .none else { return }
        status = .decided(playerAScore > playerBScore ? .A : .B)
    }
    
    var description: String {
        """
            Remaining Reds: \(remainingReds)
            Remaining Colors: \(remainingColors.map{ $0.description })
            Scores: \(playerAScore) - \(playerBScore)
            On Final Colors: \(onFinalColors)
        """
    }
    
    enum Status {
        case uninitialized
        case decided(PlayerPosition)
        case active
    }
}

extension Frame {
    var availableColorPoints: Int {
        remainingColors.reduce(into: 0) { $0 += $1.points }
    }
    
    var possibleTotalForActivePlayer: Int {
        let points = activePlayerScore + pointsOnTheTable
        return lastBallPotted == .red ? points - 1 : points
    }
}

extension Frame: Equatable {
    static func == (lhs: Frame, rhs: Frame) -> Bool {
        lhs.id == rhs.id
    }
}

extension Array where Element == Frame {
    var decided: Self { filter { $0.isDecided && !$0.isActive } }
    var pending: Self { filter { !$0.isDecided && !$0.isActive } }
}
