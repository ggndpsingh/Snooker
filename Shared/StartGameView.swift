//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

struct StartGameView: View {
    var body: some View {
        NavigationView {
            StartGameFormView()
                .navigationTitle("Welcome")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct StartGameView_Previews: PreviewProvider {
    static var previews: some View {
        StartGameView()
    }
}

struct StartGameFormView: View {
    @State var playerAName: String = ""
    @State private var playerBName: String = ""
    @State private var numberOfFrames: Int = 7
    @State private var numberOfReds: Double = 15
    
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    var canStart: Bool {
        !playerAName.isEmpty && !playerBName.isEmpty
    }
    
    @State private var isPresentingGameView: Bool = false
    
    func makeGame() -> Game {
//        .testGame
        Game(numberOfReds: Int(numberOfReds), framesCount: numberOfFrames, playerA: .init(name: playerAName), playerB: .init(name: playerBName))
    }
    
    var body: some View {
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
                    Slider(value: $numberOfReds, in: 0...15, step: 1.0)
                }
                
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
            .font(.subheadline)
            .background(BackgroundView())
        }
        .fullScreenCover(isPresented: $isPresentingGameView, content: {
            MainView(viewModel: .init(game: makeGame()))
        })
        .navigationBarItems(
            trailing: Button("Start") {
                self.isPresentingGameView.toggle()
            }
            .disabled(!canStart)
        )
    }
}
