//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

struct GameView: View {
    @ObservedObject var game: Game
    
    var body: some View {
        VStack {
            HStack() {
                PlayerView(player: game.playerOne, isActive: game.activePlayer == game.playerOne)
                Spacer()
                PlayerView(player: game.playerTwo, isActive: game.activePlayer == game.playerTwo)
            }
            Spacer()
            VStack(spacing: 16) {
                BallView(ball: .red) {
                    game.pot(.red)
                }
                
                HStack {
                    ForEach([Ball.yellow, Ball.green, Ball.brown], id: \.self) { ball in
                        BallView(ball: ball) {
                            self.game.pot(ball)
                        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                    }
                }
                
                HStack {
                    ForEach([Ball.blue, Ball.pink, Ball.black], id: \.self) { ball in
                        BallView(ball: ball) {
                            self.game.pot(ball)
                        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                    }
                }
            }
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 320, alignment: .center)
            
            Spacer()
            
            Button(action: {
                self.game.switchPlayer()
            }) {
                Image(systemName: "arrow.right.arrow.left")
            }
            .frame(width: 60, height: 60, alignment: .center)
            .overlay(
                Circle()
                    .stroke(Color.blue,lineWidth: 2)
            ).foregroundColor(Color.blue)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GameView(game: .testGame)
            GameView(game: .testGame)
                .preferredColorScheme(.dark)
        }
    }
}

struct PlayerView: View {
    @ObservedObject var player: Player
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(player.name)
            ScoreView(player: player, isActive: isActive)
        }
        .padding()
    }
}

struct ScoreView: View {
    @ObservedObject var player: Player
    let isActive: Bool
    
    var body: some View {
        Text("\(player.score)")
            .font(Font.system(size: 32, weight: .medium, design: .rounded))
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

struct BallView: View {
    let ball: Ball
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Text("\(ball.rawValue)")
                .font(Font.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(Color.white)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        }
        .background(ball.color)
        .clipShape(
            RoundedRectangle(cornerRadius: 12, style:.continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style:.continuous)
                .stroke(Color.primary, lineWidth: ball == .black ? 1 : 0))
    }
}
