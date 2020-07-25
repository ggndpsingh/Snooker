//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .pink]), center: .center)
                .edgesIgnoringSafeArea(.all)
            
            switch viewModel.state {
            case .playing(let viewState):
                GameView(viewState: viewState, actionHandler: viewModel.perform, startNextFrameHandler: viewModel.startNextFrame)
            case .betweenFrames(let last, _):
                BetweenFramesView(
                    state: .init(game: viewModel.game, frame: last),
                    nextFrameHandler: viewModel.startNextFrame)
            case .gameOver:
                Text("Game Over!")
            }
        }
    }
}

struct BetweenFramesView: View {
    let state: GameViewState
    let nextFrameHandler: () -> Void
    
    var body: some View {
        VStack {
            Text("Winner")
                .font(.subheadline)
            Text(state.winner!.name)
                .font(.largeTitle)
            
            Text("\(state.playerAState.score) - \(state.playerBState.score)")
                .font(.largeTitle)
            
            Button(action: nextFrameHandler) {
                Text("Start Next Frame")
                    .font(.subheadline)
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct GameView: View {
    let viewState: GameViewState
    let actionHandler: (Game.Action) -> Void
    let startNextFrameHandler: () -> Void
    
    var body: some View {
        ZStack {
            VStack {
                PlayersView(playerOne: viewState.playerAState, playerTwo: viewState.playerBState, activePlayer: viewState.frame.activePlayer)
                BallsView(ballOn: viewState.frame.ballOn, potAction: { ball in
                    actionHandler(.pot(ball))
                })
                
                Spacer()
                
                SwitchPlayerView(
                    switchPlayerHandler: {
                        actionHandler(.switchPlayer)
                    },
                    nextFrameHandler: startNextFrameHandler
                )
            }
        }
    }
}

struct PlayersView: View {
    var playerOne: GameViewState.PlayerState
    var playerTwo: GameViewState.PlayerState
    let activePlayer: PlayerPosition
    
    var body: some View {
        HStack() {
            PlayerView(player: playerOne, isActive: activePlayer == .A)
            Spacer()
            PlayerView(player: playerTwo, isActive: activePlayer == .B)
        }
    }
}

struct PlayerView: View {
    var player: GameViewState.PlayerState
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
        var player: GameViewState.PlayerState
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

struct BallView: View {
    let ball: Ball
    let isOn: Bool
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
        .disabled(!isOn)
        .background(isOn ? ball.color : Color.gray)
        .clipShape(
            RoundedRectangle(cornerRadius: 12, style:.continuous))
    }
}

struct BallsRowView: View {
    let balls: [Ball]
    let ballOn: BallOn
    let potAction: (Ball) -> Void
    
    var body: some View {
        HStack {
            ForEach(balls, id: \.self) { ball in
                BallView(ball: ball, isOn: ballOn.isOn(ball), potAction: potAction)
            }
        }
    }
}

struct BallsView: View {
    let ballOn: BallOn
    let potAction: (Ball) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            BallView(ball: .red, isOn: ballOn == .red, potAction: potAction)
            BallsRowView(balls: [.yellow, .green, .brown], ballOn: ballOn, potAction: potAction)
            BallsRowView(balls: [.blue, .pink, .black], ballOn: ballOn, potAction: potAction)
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 260, alignment: .center)
    }
}

struct SwitchPlayerView: View {
    let switchPlayerHandler: () -> Void
    let nextFrameHandler: () -> Void

    var body: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "arrow.counterclockwise")
            }
            .frame(width: 60, height: 60, alignment: .center)
            .overlay(
                Circle()
                    .stroke(Color.blue,lineWidth: 2)
            ).foregroundColor(Color.blue)
            
            Spacer()
            
            Button(action: switchPlayerHandler) {
                Image(systemName: "arrow.right.arrow.left")
            }
            .frame(width: 60, height: 60, alignment: .center)
            .overlay(
                Circle()
                    .stroke(Color.blue,lineWidth: 2)
            ).foregroundColor(Color.blue)
            
            Spacer()
            
            Button(action: nextFrameHandler) {
                Image(systemName: "arrow.clockwise")
            }
            .frame(width: 60, height: 60, alignment: .center)
            .overlay(
                Circle()
                    .stroke(Color.blue,lineWidth: 2)
            ).foregroundColor(Color.blue)
        }
        .padding(24)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView(viewModel: .init(game: .testGame))
//            GameView(game: .testGame)
//                .previewDevice("iPad Pro (12.9-inch) (4th generation)")
//                .preferredColorScheme(.dark)
        }
    }
}
