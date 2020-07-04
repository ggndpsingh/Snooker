//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

enum Ball: Int, Equatable, CaseIterable, CustomStringConvertible {
    case red = 1
    case yellow
    case green
    case brown
    case blue
    case pink
    case black
    
    static var colors: [Ball] {
        allCases.filter { $0 != .red }
    }
    
    var points: Int { rawValue }
    
    var description: String {
        switch self {
        case .red: return "Red"
        case .yellow: return "Yellow"
        case .green: return "Green"
        case .brown: return "Brown"
        case .blue: return "Blue"
        case .pink: return "Pink"
        case .black: return "black"
        }
    }
}

extension Ball {
    var color: Color {
        switch self {
        case .red: return Color.red
        case .yellow: return Color.yellow
        case .green: return Color.green
        case .brown: return Color(UIColor(red: 210/255, green: 105/255, blue: 30/255, alpha: 1))
        case .blue: return Color.blue
        case .pink: return Color.pink
        case .black: return Color.black
        }
    }
}

enum BallOn: Equatable {
    case none
    case red
    case colors
    case color(Ball)
    
    func isOn(_ ball: Ball) -> Bool {
        switch self {
        case .red:
            return ball == .red
        case .colors:
            return Ball.colors.contains(ball)
        case .color(let this):
            return this == ball
        case .none:
            return false
        }
    }
}
