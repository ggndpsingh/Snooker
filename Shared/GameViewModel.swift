//  Copyright © 2020 DeepGagan. All rights reserved.

import Foundation

class GameViewModel: ObservableObject {
    @Published var state: GameState
    let game: Game
    
    init(game: Game) {
        self.game = game
        self.game.startNextFrame()
        self.state = .init(game: game)
    }
    
    func startNextFrame() {
        game.startNextFrame()
        updateState()
    }
    
    func perform(_ action: Game.Action) {
        game.perform(action)
        updateState()
    }
    
    private func updateState() {
        state = .init(game: game)
    }
}
