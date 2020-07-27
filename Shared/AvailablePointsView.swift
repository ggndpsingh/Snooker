//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

enum ToWinState {
    case points(Int, [Ball])
    case colors([Ball])
    case snookers(Int)
    case none
}

struct AvailablePointsView: View {
    let viewState: AvailablePointsViewState
    
    var differenceText: String {
        if viewState.difference >= 0 {
            return "\(viewState.difference) ahead"
        } else {
            return "\(-viewState.difference) behind"
        }
    }
    
    var body: some View {
        switch viewState.state {
        case .points(let points, let sequence):
            VStack {
                Text("Points on the table: \(viewState.pointsOnTheTable)")
                Text(differenceText)
                Text("\(points) to win")
                VStack {
                    Text("Sequence to win").font(.subheadline)
                    HStack(spacing: 3) {
                        ForEach(sequence, id: \.self) { ball in
                            BallSphereView(ball: ball)
                        }
                    }
                }
                
                BreakGridView(viewState.currentBreak)
            }
        case .snookers(let snookers):
            Text("\(snookers) Snookers required")
        default:
            Text("Something else")
        }
    }
}

struct BreakGridView: View {
    let currentBreak: Break
    private let size: BallSphereView.Size = .large
    
    init(_ currentBreak: Break) {
        self.currentBreak = currentBreak
    }
    
    private var condencedBreak: [(key: Ball, value: Int)] {
        currentBreak.condenced
            .sorted { $0.key.points < $1.key.points }
    }
    
    private func columns() -> [GridItem] {
        return [GridItem(.adaptive(minimum: size.rawValue, maximum: size.rawValue))]
    }
    
    var body: some View {
        VStack {
            Text("Current Break: \(currentBreak.totalPoints)").font(.subheadline)
            LazyVGrid(columns: columns(), alignment: .center, spacing: size.spacing) {
                ForEach(condencedBreak, id: \.key) { (ball, pots) in
                    BallSphereView(ball: ball, size: size, potCount: pots)
                }
            }
        }.padding()
    }
}

struct BallSphereView: View {
    let ball: Ball
    let size: Size
    let potCount: Int?
    
    init(ball: Ball, size: BallSphereView.Size = .small, potCount: Int? = nil) {
        self.ball = ball
        self.size = size
        self.potCount = potCount
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(ball.color)
                .frame(width: size.rawValue, height: size.rawValue)
                .shadow(color: Color.black.opacity(0.4), radius: size.shadowRadius, x: 1, y: 1)
                .overlay(
                    Circle()
                        .fill(RadialGradient(gradient: Gradient(colors: [.white, ball.color]), center: .init(x: 0.3, y: 0.2), startRadius: size.gradientRadius.start, endRadius:size.gradientRadius.end))
                        .opacity(0.5))
            
            if let count = potCount {
                Text("\(count)")
                    .foregroundColor(.white)
                    .font(size.font)
            }
        }
    }
    
    enum Size: CGFloat {
        case small = 16, medium = 24, large = 48
        var spacing: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
        }
        
        var font: Font {
            switch self {
            case .small: return .footnote
            case .medium: return .caption
            case .large: return .title2
            }
        }
        
        var shadowRadius: CGFloat {
            switch self {
            case .small: return 2
            case .medium: return 3
            case .large: return 4
            }
        }
        
        var gradientRadius: (start: CGFloat, end: CGFloat) {
            switch self {
            case .small: return (1, 12)
            case .medium: return (2, 20)
            case .large: return (4, 36)
            }
        }
    }
}

struct AvailablePointsViewState {
    let difference: Int
    let pointsOnTheTable: Int
    let state: ToWinState
    let currentBreak: Break
    
    init(frame: Frame) {
        difference = frame.activePlayerScore - frame.otherPlayerScore
        pointsOnTheTable = frame.pointsOnTheTable
        currentBreak = frame.currentBreak
        
        let sequence = Self.winningSequence(for: frame)
        if frame.activePlayerScore > sequence.0 {
            state = .none
        } else if (frame.activePlayerScore + frame.pointsOnTheTable) > frame.otherPlayerScore {
            state = .points(sequence.0, sequence.1)
        } else {
            state = .snookers(Self.snookerRequired(in: frame))
        }
    }
    
    static func winningSequence(for frame: Frame) -> (Int, [Ball]) {
        var sequence: [Ball] = []
        
        var remaining = frame.pointsOnTheTable
        var score = frame.activePlayerScore
        var difference: Int { score - frame.otherPlayerScore }
        var skipRed = frame.lastBallPotted == .red
        
        outer: while difference < remaining {
            if !skipRed {
                sequence.append(.red)
                score += 1
                remaining -= 8
                if remaining < difference {
                    break
                }
            }
            skipRed = false
            
            for ball in Ball.colors {
                var temp = score
                temp += ball.points
                let diff = temp - frame.otherPlayerScore
                if remaining < diff {
                    sequence.append(ball)
                    score = temp
                    break outer
                }
            }
            
            sequence.append(.black)
            score += 7
        }
        
        return (score, sequence)
    }
    
    static func snookerRequired(in frame: Frame) -> Int {
        let snookerPoints: Int = {
            guard let ball = frame.remainingColors.first else { return 4 }
            return max(ball.points, 4)
        }()
        
        var diff = (frame.activePlayerScore + frame.pointsOnTheTable) - (frame.otherPlayerScore + 1)
        var snookers = 0
        while diff < 0 {
            diff += snookerPoints
            snookers += 1
        }
        return snookers
    }
    
    static func makeFrame() -> Frame {
        let frame = Frame(numberOfReds: 15, toBreak: .A)
        
        for _ in 1...6 {
            frame.potRed()
            frame.potColor(.black)
        }
        return frame
    }
}


struct AvailablePointsView_Previews: PreviewProvider {
    static var previews: some View {
        AvailablePointsView(viewState: .init(frame: AvailablePointsViewState.makeFrame()))
    }
}


private extension Break {
    var condenced: [Ball: Int] {
        self.reduce(into: [Ball: Int]()) {
            $0[$1] = $0[$1, default: 0] + 1
        }
    }
}
