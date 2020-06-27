//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

struct GameView: View {
    @ObservedObject var game: Game
    
    var body: some View {
        ZStack {
            Color.secondarySystemBackground
                .edgesIgnoringSafeArea(.all)
            VStack {
                PlayersView(playerOne: game.playerOne, playerTwo: game.playerTwo, activePlayerID: game.activePlayer.id)
                BallsView(potAction: game.pot)
                Spacer()
                SwitchPlayerView(switchPlayerHandler: game.switchPlayer)
            }
        }
    }
}

struct PlayerView: View {
    @ObservedObject var player: Player
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(player.name)
                .font(Font.system(size: 14, weight: .medium, design: .rounded))
            ScoreView(player: player, isActive: isActive)
        }
        .padding()
    }
    
    struct ScoreView: View {
        @ObservedObject var player: Player
        let isActive: Bool
        
        var body: some View {
            Text("\(player.score)")
                .font(Font.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 100, height: 100)
                .background(background)
                .clipShape(
                    RoundedRectangle(cornerRadius: 12, style:.continuous))
        }
        
        private var background: Color {
            isActive ? .green : .gray
        }
    }
}

struct PlayersView: View {
    @ObservedObject var playerOne: Player
    @ObservedObject var playerTwo: Player
    let activePlayerID: String
    
    var body: some View {
        HStack() {
            PlayerView(player: playerOne, isActive: playerOne.id == activePlayerID)
            Spacer()
            PlayerView(player: playerTwo, isActive: playerTwo.id == activePlayerID)
        }
    }
}

struct BallView: View {
    let ball: Ball
    let potAction: (Ball) -> Void
    
    var body: some View {
        Button(action: {
            potAction(ball)
        }) {
            Text("\(ball.rawValue)")
                .font(Font.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color.white)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, idealHeight: 64, maxHeight: 64, alignment: .center)
        }
        .background(ball.color)
        .clipShape(
            RoundedRectangle(cornerRadius: 12, style:.continuous))
    }
}

struct BallsRowView: View {
    let balls: [Ball]
    let potAction: (Ball) -> Void
    var body: some View {
        HStack {
            ForEach(balls, id: \.self) { ball in
                BallView(ball: ball, potAction: potAction)
            }
        }
    }
}

struct BallsView: View {
    let potAction: (Ball) -> Void
    var body: some View {
        VStack(spacing: 16) {
            BallView(ball: .red, potAction: potAction)
            BallsRowView(balls: [.yellow, .green, .brown], potAction: potAction)
            BallsRowView(balls: [.blue, .pink, .black], potAction: potAction)
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 260, alignment: .center)
    }
}

struct SwitchPlayerView: View {
    let switchPlayerHandler: () -> Void
    var body: some View {
        Button(action: switchPlayerHandler) {
            Image(systemName: "arrow.right.arrow.left")
        }
        .frame(width: 60, height: 60, alignment: .center)
        .overlay(
            Circle()
                .stroke(Color.blue,lineWidth: 2)
        ).foregroundColor(Color.blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GameView(game: .testGame)
//            GameView(game: .testGame)
//                .previewDevice("iPad Pro (12.9-inch) (4th generation)")
//                .preferredColorScheme(.dark)
        }
    }
}
