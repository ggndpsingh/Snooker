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
                HStack(spacing: 3) {
                    ForEach(sequence, id: \.self) { ball in
                        Circle()
                            .fill(ball.color)
                            .frame(width: 16, height: 16)
                            .shadow(color: Color/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.4), radius: 2, x: 1, y: 1)
                            .overlay(
                                Circle()
                                    .fill(RadialGradient(gradient: Gradient(colors: [.white, ball.color]), center: .init(x: 0.3, y: 0.2), startRadius: 1, endRadius: 15))
                                    .opacity(0.5))
                    }
                }
                .padding(10)
            }
        case .snookers(let snookers):
            Text("\(snookers) Snookers required")
        default:
            Text("Something else")
        }
    }
}

struct AvailablePointsViewState {
    let difference: Int
    let pointsOnTheTable: Int
    
    let state: ToWinState
    
    init(frame: Frame) {
        difference = frame.activePlayerScore - frame.otherPlayerScore
        pointsOnTheTable = frame.pointsOnTheTable
        
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
