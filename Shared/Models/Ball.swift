//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

enum Ball: Int, CaseIterable {
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
