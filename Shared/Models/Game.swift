//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

class Game: Identifiable {
    let id: String = UUID.id
    let playerA: Player
    let playerB: Player
    let frames: [Frame]
    
    private(set) var activeFrame: Frame? {
        didSet {
            activeFrame?.setActive()
        }
    }
    private var decidedFrames: [Frame] { frames.decided }
    private var pendingFrames: [Frame] { frames.pending }
    
    var lastFrame: Frame? { decidedFrames.last }
    var nextFrame: Frame? { pendingFrames.first }
    
    private var activePlayer: Player {
        activeFrame?.activePlayerPosition == .A ? playerA : playerB
    }
    
    init(numberOfReds: Int, framesCount: Int, playerA: Player, playerB: Player) {
        self.frames = Self.makeFrames(framesCount, reds: numberOfReds)
        self.playerA = playerA
        self.playerB = playerB
    }
    
    func startNextFrame(){
        guard let nextFrame = pendingFrames.first else { return }
        activeFrame = nextFrame
    }
    
    func perform(_ action: Action) {
        switch action {
        case .switchPlayer:
            activeFrame?.switchPlayer()
        case .pot(let ball):
            switch ball {
            case .red:
                activeFrame?.potRed()
            default:
                activeFrame?.potColor(ball)
            }
        }
        
        if let frame = activeFrame, frame.isDecided {
            activeFrame = nil
        }
    }
    
    func player(at position: PlayerPosition) -> Player {
        position == .A ? playerA : playerB
    }
}

extension Game {
    var framesWonByPlayerA: [Frame] { framesWonBy(playerAt: .A) }
    var framesWonByPlayerB: [Frame] { framesWonBy(playerAt: .B) }
    
    private func framesWonBy(playerAt position: PlayerPosition) -> [Frame] {
        frames.filter { $0.winnerPosition == position }
    }
}

extension Game{
    enum Action {
        case pot(Ball)
        case switchPlayer
    }
}

extension Game{
    static func makeFrames(_ count: Int, reds: Int) -> [Frame] {
        var frames: [Frame] = []
        for i in 0..<count {
            let toBreak: PlayerPosition = i.isMultiple(of: 2) ? .A : .B
            frames.append(.init(numberOfReds: reds, toBreak: toBreak))
        }
        return frames
    }
}

extension Game {
    static let testGame: Game = .init(
        numberOfReds: 1,
        framesCount: 3,
        playerA: .init(
            name: "Gagandeep"),
        playerB: .init(
            name: "Omkar")
    )
}
