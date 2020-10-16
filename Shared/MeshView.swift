//  Copyright © 2020 DeepGagan. All rights reserved.

import SwiftUI

struct Wave: Shape, Hashable {
    /// how high our waves should be
    let strength: Double
    
    /// how frequent our waves should be
    let frequency: Double
    
    /// how much to offset our waves horizontally
    var phase: Double
    
    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath()
        
        // calculate some important values up front
        let width = Double(rect.width)
        let height = Double(rect.height)
        let midWidth = width / 2
        let midHeight = height / 2
        let oneOverMidWidth = 1 / midWidth
        
        // split our total width up based on the frequency
        let wavelength = width / frequency
        
        // start at the left center
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        // now count across individual horizontal points one by one
        for x in stride(from: 0, through: width, by: 100) {
            // find our current position relative to the wavelength
            let relativeX = x / wavelength
            
            // find how far we are from the horizontal center
            let distanceFromMidWidth = x - midWidth
            
            // bring that into the range of -1 to 1
            let normalDistance = oneOverMidWidth * distanceFromMidWidth
            
            // calculate the sine of that position
            let sine = sin(relativeX + phase)
            
            let parabola = -(normalDistance * normalDistance) + 1
            
            // multiply that sine by our strength to determine final offset, then move it down to the middle of our view
            let y = parabola * strength * sine + midHeight
            
            // add a line to here
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return Path(path.cgPath)
    }
}

struct MeshView: View {
    static let shared = MeshView()
    
    class ColorProvider {
        private(set) var colors: [UIColor] = [.blue, .cyan, .orange, .red, .yellow, .green, .purple, .systemIndigo]
        
        init() {
            colors.shuffle()
        }
    }
    
    @State private var phase = 0.0
    var randomPhase: Double {
        phase * Double(Array(1...3).randomElement()!)
    }
    
    var randomFrequency: Double {
        Double(Array(1...6).randomElement()!)
    }
    
    var randomStrength: Double {
        Double(Array(stride(from: 140, to: 800, by: 60)).randomElement()!)
    }
    
    var randomBlur: CGFloat {
//        return 0
        CGFloat(Array(stride(from: 40, to: 100, by: 20)).randomElement()!)
    }
    
    var randomOpacity: Double {
//        return 0
        Double(Array(6...10).randomElement()!) / 10
    }
    
    private func makeAnimation(duration: TimeInterval) -> Animation {
        Animation.linear(duration: duration).delay(1).repeatForever(autoreverses: true)
    }
    
    let colors = ColorProvider().colors.map(Color.init)
    
    var body: some View {
        ZStack {
            colors[7].edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            HStack {
                ZStack {
                    GeometryReader { geometry in
                        Circle()
                            .frame(width: 300, height: 500)
                            .foregroundColor(colors[0])
                            .blur(radius: randomBlur)
                            .opacity(randomOpacity)
                            .offset(x: -20, y: 300)
                            .scaleEffect(CGFloat(Array(0...3).randomElement()!))
                            .animation(makeAnimation(duration: 10))

                        Circle()
                            .frame(width: 500, height: 600)
                            .foregroundColor(colors[1])
                            .blur(radius: randomBlur)
                            .opacity(randomOpacity)
                            .offset(x: -70, y: -160)
                            .scaleEffect(CGFloat(Array(0...3).randomElement()!))
                            .animation(makeAnimation(duration: 24))
                        
                        Circle()
                            .frame(width: 200, height: 200)
                            .foregroundColor(colors[2])
                            .blur(radius: randomBlur)
                            .opacity(randomOpacity)
                            .offset(x: 200, y: 400)
                            .scaleEffect(CGFloat(Array(0...3).randomElement()!))
                            .animation(makeAnimation(duration: 36))
                        
                        Circle()
                            .frame(width: 200, height: 200)
                            .foregroundColor(colors[3])
                            .blur(radius: randomBlur)
                            .opacity(randomOpacity)
                            .offset(x: 20, y: -160)
                            .scaleEffect(CGFloat(Array(0...3).randomElement()!))
                            .animation(makeAnimation(duration: 16))
                        
                        Wave(strength: randomStrength, frequency: randomFrequency, phase: randomPhase)
                            .foregroundColor(colors[4])
                            .offset(y: -400)
                            .blur(radius: randomBlur)
                            .opacity(randomOpacity)
                            .rotation3DEffect(Angle(degrees: 10), axis: (x: 20.0, y: 10.0, z: 90.0))

                        Wave(strength: randomStrength, frequency: randomFrequency, phase: randomPhase)
                            .foregroundColor(.init(colors[5]))
                            .offset(x: 0, y: 400)
                            .blur(radius: randomBlur)
                            .opacity(randomOpacity)
                            .rotation3DEffect(Angle(degrees: 10), axis: (x: 50.0, y: 80.0, z: 120.0))

                        Wave(strength: randomStrength, frequency: randomFrequency, phase: randomPhase)
                            .foregroundColor(.init(colors[6]))
                            .blur(radius: randomBlur)
                            .opacity(randomOpacity)
                    }
                }
                .overlay(Blur(style: .systemUltraThinMaterialLight))
            }
            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 30).delay(1).repeatForever(autoreverses: false)) {
                self.phase = .pi * 2
            }
        }
    }
}

struct MeshView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MeshView()
        }
    }
}
