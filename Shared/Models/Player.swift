//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

class Player: Identifiable, ObservableObject {
    let id: String
    let name: String
    
    @Published var score: Int
    
    internal init(id: String, name: String, score: Int = 0) {
        self.id = id
        self.name = name
        self.score = score
    }
    
    func didPot(_ ball: Ball) {
        score += ball.rawValue
    }
}

extension Player: Equatable {
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
}

enum PlayerType {
    case A, B
    
    mutating func toggle() {
        self = self == .A ? .B : .A
    }
}
