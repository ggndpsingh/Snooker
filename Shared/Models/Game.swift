//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

class Game: Identifiable, ObservableObject {
    let id: String
    @ObservedObject var playerOne: Player
    @ObservedObject var playerTwo: Player
    
    @Published var activePlayer: Player
    
    internal init(id: String = UUID.id, playerOne: Player, playerTwo: Player) {
        self.id = id
        self.playerOne = playerOne
        self.playerTwo = playerTwo
        self.activePlayer = playerOne
    }
    
    func switchPlayer() {
        activePlayer = activePlayer == playerOne ? playerTwo : playerOne
    }
    
    func pot(_ ball: Ball) {
        activePlayer.didPot(ball)
    }
}

extension Game {
    static let testGame: Game = .init(
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
