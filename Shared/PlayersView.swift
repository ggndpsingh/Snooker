//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

struct PlayersView: View {
    let viewState: GameViewState
    
    var body: some View {
        ZStack {
            HStack() {
                PlayerView(player: viewState.playerA, isActive: viewState.activePlayer == .A)
                Spacer()
                
                FramesView(frames: viewState.frames)
                    .offset(x: 0, y: 8)
                
                Spacer()
                PlayerView(player: viewState.playerB, isActive: viewState.activePlayer == .B)
            }
        }
    }
}

struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        PlayersView(viewState: .init(game: .testGame, frame: Game.testGame.frames[0]))
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
}

struct ScoreView: View {
    var player: GameViewState.PlayerState
    let isActive: Bool
    
    var body: some View {
        Text("\(player.score)")
            .font(Font.system(size: 40, weight: .medium, design: .rounded))
            .foregroundColor(.white)
            .frame(width: 100, height: 100)
            .background(background)
            .clipShape(Circle())
    }
    
    private var background: Color {
        isActive ? .green : .gray
    }
}

struct FramesView: View {
    let frames: GameViewState.FramesState
    
    var body: some View {
        Text("\(frames.a) (\(frames.total)) \(frames.b)")
            .font(.title2)
    }
}
