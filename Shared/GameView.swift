//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: StateViewModel
    
    var body: some View {
        switch viewModel.state {
        case .playing(let viewModel):
            GameView(viewModel: viewModel)
        case .gameNotStarted:
            StartGameView(startHandler: viewModel.startGame)
        case .betweenFrames(let last, let next):
            BetweenFramesView(
                lastFrame: last,
                nextFrame: next,
                nextFrameHandler: viewModel.startGame)
        case .gameOver:
            Text("Game Over!")
        }
    }
}

struct StartGameView: View {
    let startHandler: () -> Void
    
    var body: some View {
        Button(action: startHandler) {
            Text("Start Game")
        }
    }
}

struct BetweenFramesView: View {
    let lastFrame: Frame
    let nextFrame: Frame
    let nextFrameHandler: () -> Void
    
    var body: some View {
        Button(action: nextFrameHandler) {
            Text("Start Nxt Frame")
        }
    }
}

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    private var viewState: GameViewState { viewModel.viewState }
    
    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
    }
    
    func perform(_ action: Game.Action) {
        viewModel.perform(action)
    }
    
    var body: some View {
        ZStack {
            Color.secondarySystemBackground
                .edgesIgnoringSafeArea(.all)
            VStack {
                PlayersView(playerOne: viewState.playerAState, playerTwo: viewState.playerBState, activePlayer: viewState.frame.activePlayer)
                BallsView(ballOn: viewState.frame.ballOn, potAction: { ball in
                    perform(.pot(ball))
                })
                
                Spacer()
                
                SwitchPlayerView(
                    switchPlayerHandler: {
                        perform(.switchPlayer)
                    },
                    resetHandler: viewModel.reset,
                    nextFrameHandler: viewModel.startNextFrame
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
    let resetHandler: () -> Void
    let nextFrameHandler: () -> Void

    var body: some View {
        HStack {
            Button(action: resetHandler) {
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
