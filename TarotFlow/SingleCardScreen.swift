import SwiftUI

struct SingleCardScreen: View {
    
    @EnvironmentObject var userData: UserData
    
    let totalCards = 78
    let radius: CGFloat = 250
    let totalDegrees: Double = 300 // Changed from 360 to 300
    @State private var currentRotation: Double = 0
    @State private var dragRotation: Double = 0
    @State private var selectedCard: Int?
    @State private var isDragging = false
    @State private var cardOrder: [Int] = []
    @State private var showTypewriterOverlay = false
    @State public var flippedCards: [Bool] = Array(repeating: false, count: 78)
    @State private var cardOpacities: [Double] = Array(repeating: 1.0, count: 78) //
  
    @State private var displayedText = ""
    @State private var singleRectanglePosition: CGPoint = .zero
    
    @State private var currentIndex = 0
    @State private var offsetY: CGFloat = 300 // Metnin yukarı kayma başlangıç noktası
    @State private var showTypewriter = false
    @State private var frameWidth: CGFloat?
    @State private var isInteractionDisabled = false
    let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()

    private var maxRotation: Double {
        let rotationPerCard = totalDegrees / Double(totalCards)
        return rotationPerCard * Double(totalCards - 39) }// Sağ tarafta 77. kartı merkezde tutacak şekilde
    

    private var minRotation: Double {
        let rotationPerCard = totalDegrees / Double(totalCards)
        return -rotationPerCard * Double(totalCards - 40) }// Sol tarafta 0. kartı merkezde tutacak şekilde
    
    init() {
            // Randomize card order when view is created
            _cardOrder = State(initialValue: Array(0..<78).shuffled())
        }
    
    
    var body: some View {
        GeometryReader { geometry in
            AppColors.newBackground.edgesIgnoringSafeArea(.all)
            
            ZStack {
                wheelView
                    .frame(width: radius * 1.5, height: radius * 9)
                
                    .rotationEffect(.degrees(currentRotation + dragRotation))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                guard !isInteractionDisabled else { return }
                                isDragging = true
                                let newRotation = value.translation.width / 10
                                let potentialRotation = currentRotation + newRotation
                                
                                if potentialRotation <= maxRotation && potentialRotation >= minRotation {
                                    dragRotation = newRotation
                                } else if potentialRotation > maxRotation && newRotation < 0 {
                                    dragRotation = newRotation
                                } else if potentialRotation < minRotation && newRotation > 0 {
                                    dragRotation = newRotation
                                }
                                updateSelectedCard(geometry: geometry)
                            }
                            .onEnded { _ in
                                guard !isInteractionDisabled else { return }
                                isDragging = false
                                currentRotation += dragRotation
                                withAnimation(.bouncy(duration: 0.5)) {
                                    currentRotation = nearestSnapRotation(currentRotation)
                                }
                                dragRotation = 0
                                updateSelectedCard(geometry: geometry)
                            }
                    )
            }
            VStack{
                
                HStack{
                    Spacer()
                    SingleRectangleView(number: (userData.flippedCards.count > 0) ? userData.flippedCards[0] : -1, color: color(for: (userData.flippedCards.count > 0) ? userData.flippedCards[0] : -1)).animation(.smooth(duration: 1).delay(0.5))
                    Spacer()
                }.padding(UIScreen.main.bounds.height * 0.01)
                Spacer()
                
                // Typewriter efektinin eklenmesi
                TypewriterOverlay(isVisible: $showTypewriterOverlay)
                    .onChange(of: userData.flippedCards.count) { newValue in
                        if newValue == 1 { // 1 kart seçildiğinde
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                showTypewriterOverlay = true
                            }
                        }
                    }
                
                
            }
            .onAppear {
                selectedCard = 1
                updateSelectedCard(geometry: geometry)
                print(UIScreen.main.bounds.height)
                print(UIScreen.main.bounds.width)
            }
            .onAppear {  // **🔥 SingleCardScreen ekrana gelince çalışır**
                userData.chatGPTResponse = nil // **Eski falı temizle**
            }
        }
    }//body
    
    func calculateTextWidth(text: String, font: Font) -> CGFloat {
    let uiFont = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize)
    let attributes = [NSAttributedString.Key.font: uiFont]
    let size = (text as NSString).size(withAttributes: attributes)
    return size.width
    }
                                                              
    var wheelView: some View {
        GeometryReader { geometry in
            
        
        ZStack {
            ForEach(0..<totalCards, id: \.self) { index in
                CardViewSingle(number: cardOrder[index],
                               color: color(for: cardOrder[index]),
                               isSelected: cardOrder[index] == selectedCard,
                               isFlipped: $flippedCards[index],
                               opacity: cardOpacities[index],
                               isClickable: cardOrder[index] == selectedCard && userData.flippedCards.count < 1)
                .position(calculatePosition(geometry: geometry))
                .rotationEffect(.degrees(Double(index) * (totalDegrees / Double(totalCards))))
                
                .onTapGesture {
                    let actualCardNumber = cardOrder[index]
                    
                    if actualCardNumber == selectedCard && userData.flippedCards.count < 1 { // Sadece tek kart açılabilir
                        withAnimation(.bouncy(duration: 0.5)) {
                            selectedCard = actualCardNumber
                            flippedCards[index].toggle()
                            userData.flippedCards.append(actualCardNumber)
                            isInteractionDisabled = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                isInteractionDisabled = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                cardOpacities[index] = 0.0
                            }
                        }
                    }
                }
            }
        }
    }
        
        .rotationEffect(.degrees((360 - totalDegrees) / 2)) // Center the 300-degree arc
    }
    
    func calculatePosition(geometry: GeometryProxy) -> CGPoint {
        let screenWidth = UIScreen.main.bounds.width * UIScreen.main.scale
        let screenHeight = UIScreen.main.bounds.height * UIScreen.main.scale

        //print("Detected Resolution: \(screenWidth) x \(screenHeight)")

        if (screenWidth == 750 && screenHeight == 1334) {
            // 📱 iPhone 6, 6s, 7, 8
            return CGPoint(x: geometry.size.width / 2.0,
                           y: geometry.size.height / 1.28)
        } else if (screenWidth == 828 && screenHeight == 1792) {
            // 📱 iPhone XR, iPhone 11
            return CGPoint(x: geometry.size.width / 2.2,
                           y: geometry.size.height / 1.42)
        }
        else if (screenWidth == 1125 && screenHeight == 2436) {
            return CGPoint(x: geometry.size.width / 2.02,
                           y: geometry.size.height / 1.35)
        } // 11 pro,x,xs
        
        else if (screenWidth == 1242 && screenHeight == 2688) {
            return CGPoint(x: geometry.size.width / 2.25,
                           y: geometry.size.height / 1.4)
        }
        
        else if (screenWidth == 1170 && screenHeight == 2532) {
            return CGPoint(x: geometry.size.width / 2.08,
                           y: geometry.size.height / 1.38)
            // iphone 14,12pro,13,13pro,12
        }
        
        else if (screenWidth == 1179 && screenHeight == 2556) {
            return CGPoint(x: geometry.size.width / 2.08,
                           y: geometry.size.height / 1.36)
        } // 15,15pro,16,14pro
        
        else if (screenWidth == 1290 && screenHeight == 2796) {
            return CGPoint(x: geometry.size.width / 2.34,
                           y: geometry.size.height / 1.4)
        } // 14promax,15promax,16plus
        
        else if (screenWidth == 1206 && screenHeight == 2622) {
            return CGPoint(x: geometry.size.width / 2.15,
                           y: geometry.size.height / 1.37)
        } // 16pro
        
        else if (screenWidth == 1320 && screenHeight == 2868) {
            return CGPoint(x: geometry.size.width / 2.4,
                           y: geometry.size.height / 1.39)
        } // 16promax
        
        else {
            // Varsayılan değer (Eğer eşleşme yoksa)
            return CGPoint(x: geometry.size.width / 2.1,
                           y: geometry.size.height / 1.35)
            // default: 2.1, 1.35
        }
    }
    
    func color(for index: Int) -> Color {
        if index == -1 {return Color.black.opacity(0)}
        let hue = Double(index) / Double(totalCards)
        return Color(hue: hue, saturation: 1, brightness: 0.6)
    }
    
    func nearestSnapRotation(_ rotation: Double) -> Double {
        let snapAngle = totalDegrees / Double(totalCards)
        return round(rotation / snapAngle) * snapAngle
    }
    
    func updateSelectedCard(geometry: GeometryProxy) {
        print("Flipped Card Count: ", userData.flippedCards)
        print("Flipped Cards: ", userData.flippedCards)
        let centerY = geometry.size.height / 2
        let rotationPerCard = 300 / Double(totalCards)
        let totalRotation = currentRotation + dragRotation
        
        for i in 0..<totalCards {
            var cardRotation: Double = 0
            if totalRotation < 0 {
                cardRotation = Double(i) * rotationPerCard - totalRotation
            } else {
                cardRotation = Double(i) * rotationPerCard + totalRotation
            }
            let cardY = centerY - sin(cardRotation * .pi / 150) * (radius - 900)
            
            if abs(cardY - centerY) < 30 {
                if totalRotation < -2 {
                    selectedCard = cardOrder[78 - i ]
                } else if (i == 0 && totalRotation < 10 && totalRotation > -10) {
                    selectedCard = cardOrder[39]
                } else {
                    selectedCard = cardOrder[i]
                }
                print("Selected Card Updated: \(selectedCard ?? -1)")
                break
            }
        }
    }
}



struct CardViewSingle: View {
    @EnvironmentObject var userData: UserData
    let number: Int
    let color: Color
    let isSelected: Bool
    @Binding var isFlipped: Bool
    let opacity: Double
    let isClickable: Bool
    
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    @State private var screenHeight: CGFloat = UIScreen.main.bounds.height
    
    // Sadece flip animasyonu için state'ler
    @State private var cardYOffset: CGFloat = 0
    @State private var cardXOffset: CGFloat = 0
    
    private func getTargetXOffset() -> CGFloat {
            return screenWidth * -0.02
        }
        
        private func getTargetYOffset() -> CGFloat {
            return screenHeight * 0.5
        }
    
    private func updateFlipPosition() {
            if isFlipped {
                withAnimation(.easeInOut(duration: 0.8)) {
                    cardYOffset = getTargetYOffset()
                    cardXOffset = getTargetXOffset()
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    cardYOffset = 0
                    cardXOffset = 0
                }
            }
        }
    
    var body: some View {
        let cardWidth = UIScreen.main.bounds.width * 0.2
        let cardHeight = UIScreen.main.bounds.height * 0.3
        ZStack {
            if isFlipped {
                Image("\(number)") // Use the image named with the card number
                    .resizable()
                    .scaledToFit()
                    .frame(width: cardWidth, height: cardHeight)
                    .rotationEffect(.degrees(180), anchor: .center)
                    .scaleEffect(x: -1, y: 1, anchor: .center)
            } else {
                Image("cardCover")
                    .resizable()
                    .scaledToFit()
                    .frame(width: cardWidth, height: cardHeight)
                    .scaleEffect(x: 1, y: -1, anchor: .center)
                
//                Text("\(number)")
//                    .foregroundColor(.white)
//                    .font(.system(size: 20, weight: .bold))
//                    .rotationEffect(.degrees(180))
            }
        }
        .opacity(opacity)
        .scaleEffect(isSelected && !isFlipped ? 1.4 : 1.0) // isSelected animasyonu eski haline döndü
        .scaleEffect(isSelected && isFlipped ? 1.4 : 1.0)
        .offset(x: cardXOffset, y: isSelected && !isFlipped ? 20 : cardYOffset) // isSelected için y-offset'i eski haline döndü
        .zIndex(isSelected || isFlipped ? 1 : 0)
        
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.bouncy(duration: 0.5), value: isSelected) // isSelected için orijinal animasyon
        .onChange(of: isFlipped) { _ in
            updateFlipPosition()
        }
    }
}

struct SingleRectangleView: View {
    let number: Int
    let color: Color
    
    let cardWidth = UIScreen.main.bounds.width * 0.28
    let cardHeight = UIScreen.main.bounds.height * 0.42

    var body: some View {
        ZStack {
            if number != -1 {
                Image("\(number)") // Use the image named with the card number
                    .resizable()
                    .scaledToFit()
                    .frame(width: cardWidth, height: cardHeight)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color)
                    .frame(width: cardWidth, height: cardHeight)
            }
            
//            Text(number != -1 ? "\(number)" : "")
//                .foregroundColor(.white)
//                .font(.system(size: 20, weight: .bold))
        }
    }
}

struct SingleCardScreen_Previews: PreviewProvider {
    static var previews: some View {
    
        return SingleCardScreen()
            .environmentObject(UserData())
    }
}
