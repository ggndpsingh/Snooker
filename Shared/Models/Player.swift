//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

class Player: Identifiable {
    let id: String
    let name: String
    
    internal init(id: String, name: String, score: Int = 0) {
        self.id = id
        self.name = name
    }
}

extension Player: Equatable {
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
}

enum PlayerPosition {
    case A, B
    
    mutating func toggle() {
        self = self == .A ? .B : .A
    }
    
    var other: Self {
        self == .A ? .B : .A
    }
}
