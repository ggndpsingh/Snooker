//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

class MessageProvider: ObservableObject {
    private let rawMessage: String
    private let interval: TimeInterval
    
    @Published var message: String = ""
    private var messagePrefix: Int = 0 {
        willSet {
            message = String(rawMessage.prefix(newValue))
            objectWillChange.send()
        }
    }
    
    var timer: Timer?
    
    init(message: String, interval: TimeInterval = 0.07) {
        self.rawMessage = message
        self.interval = interval
    }
    
    @discardableResult
    func fire() -> TimeInterval {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            guard self.messagePrefix < self.rawMessage.count else {
                self.timer = nil
                return
            }
            self.messagePrefix += 1
        }
        timer?.fire()
        return Double(rawMessage.count) * interval
    }
}

struct IntroductionView: View {
    @ObservedObject var titleProvider = MessageProvider(
        message: """
        I am
        Gagandeep Singh
        """)
    @ObservedObject var subtitleProvider = MessageProvider(message: "I build ideas💡!")
    
    @State var background: MeshView = MeshView()
    
    var body: some View {
        ZStack(alignment: .leading) {
            background
            
            Blur(style: .systemThinMaterialLight)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .mask(
                    VStack(alignment: .leading) {
                        Text(titleProvider.message)
                            .font(Font.system(size: 60, weight: .black, design: .default))
                        Text(subtitleProvider.message)
                            .font(Font.system(size: 24, weight: .medium, design: .default))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .font(Font.system(size: 72).weight(.black))
                    .background(Color.clear)
                    .foregroundColor(.white))
        }
        .onTapGesture(count: 2) {
            background = MeshView()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let wait = titleProvider.fire()
                DispatchQueue.main.asyncAfter(deadline: .now() + wait) {
                    self.subtitleProvider.fire()
                }
            }
        }
    }
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionView()
    }
}
