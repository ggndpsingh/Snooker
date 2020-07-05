//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    private var viewState: GameViewState { viewModel.viewState }
    
    init(viewModel: GameViewModel = .init(game: .testGame)) {
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
                PlayersView(playerOne: viewState.playerA, playerTwo: viewState.playerB, activePlayer: viewState.activePlayer)
                BallsView(ballOn: viewState.ballOn, potAction: { ball in
                    perform(.pot(ball))
                })
                
                Spacer()
                
                SwitchPlayerView(
                    switchPlayerHandler: {
                        perform(.switchPlayer)
                    },
                    resetHandler: viewModel.reset
                )
            }
        }
    }
}

struct PlayersView: View {
    @ObservedObject var playerOne: GameViewState.Player
    @ObservedObject var playerTwo: GameViewState.Player
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
    @ObservedObject var player: GameViewState.Player
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
        @ObservedObject var player: GameViewState.Player
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
            
            Button(action: {}) {
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
            GameView()
//            GameView(game: .testGame)
//                .previewDevice("iPad Pro (12.9-inch) (4th generation)")
//                .preferredColorScheme(.dark)
        }
    }
}
