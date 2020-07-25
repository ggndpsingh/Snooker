//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

struct StartGameView: View {
    @State var playerAName: String = ""
    @State private var playerBName: String = ""
    @State private var numberOfFrames: Int = 7
    @State private var numberOfReds: Double = 15
    
    var canStart: Bool {
        !playerAName.isEmpty && !playerBName.isEmpty
    }
    
    @State private var isPresentingGameView: Bool = false
    
    func makeGame() -> Game {
        .testGame
//        Game(numberOfReds: Int(numberOfReds), framesCount: numberOfFrames, playerA: .init(name: playerAName), playerB: .init(name: playerBName))
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                Form {
                    Section {
                        (Text(Image(systemName: "person")) + Text(" Player A"))
                        TextField("Ronnie O' Sullivan", text: $playerAName)
                    }
                    
                    Section {
                        (Text(Image(systemName: "person")) + Text(" Player B"))
                        TextField("Neil Robertson", text: $playerBName)
                    }
                    
                    Section {
                        Stepper(("Number of frames: \(numberOfFrames)"), value: $numberOfFrames, in: 1...99, step: 2)
                    }
                    
                    Section {
                        Text("Number of reds: \(Int(numberOfReds))")
                        Slider(value: $numberOfReds, in: 1...15, step: 1.0)
                    }
                }
                .font(.subheadline)
                
                HStack(spacing: 8) {
                    if playerAName.isEmpty {
                        Text("Player A Name")
                            .redacted(reason: .placeholder)
                    } else {
                        Text("\(playerAName)")
                    }
                    
                    Text("( \(numberOfFrames) )")
                    
                    if playerBName.isEmpty {
                        Text("Player B Name")
                            .redacted(reason: .placeholder)
                    } else {
                        Text("\(playerBName)")
                    }
                }.frame(maxWidth: .infinity, idealHeight: 44)
            }
            .navigationTitle("Welcome")
            .navigationBarItems(
                trailing: Button("Start") {
                    self.isPresentingGameView.toggle()
                }
//                .disabled(!canStart)
            )
        }
        .fullScreenCover(isPresented: $isPresentingGameView, content: {
            MainView(viewModel: .init(game: makeGame()))
        })
    }
}

struct StartGameView_Previews: PreviewProvider {
    static var previews: some View {
        StartGameView()
    }
}
