import SwiftUI

// MARK: - Models
struct AzizeCard: Identifiable, Equatable {
    let id = UUID()
    let number: Int
    var position: CardPosition
    
    static func == (lhs: AzizeCard, rhs: AzizeCard) -> Bool {
        lhs.id == rhs.id
    }
}

enum CardPosition: Int {
    case deck = 0
    case leftTop = 1
    case centerTop = 2
    case rightTop = 3
    case centerMiddle = 4
    
    var offset: (x: CGFloat, y: CGFloat) {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        switch self {
        case .deck:
            return (0, 0)
        case .leftTop:
            return (-screenWidth * 0.3, -screenHeight * 0.65)
        case .centerTop:
            return (0, -screenHeight * 0.65)
        case .rightTop:
            return (screenWidth * 0.3, -screenHeight * 0.65)
        case .centerMiddle:
            return (0, -screenHeight * 0.4)
        }
    }
}

// MARK: - Shadow Card View
struct ShadowCardView: View {
    let cardNumber: Int
    let position: CardPosition
    let groupYOffset: CGFloat
    @State private var isFlipped: Bool = false
    @State private var opacity: Double = 0
    var xOffset: CGFloat {
        position.offset.x
    }
    var yOffset: CGFloat {
        position.offset.y + groupYOffset
    }
    
    var body: some View {
        ZStack {
            if isFlipped {
                Image("\(cardNumber)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.30, height: UIScreen.main.bounds.height * 0.18)
                    .scaleEffect(y: -1)
            } else {
                Image("cardCover")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.30, height: UIScreen.main.bounds.height * 0.18)
            }
        }
        .opacity(opacity)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 1, y: 0, z: 0)
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                opacity = 1
            }
            withAnimation(.easeInOut(duration: 0.5)) {
                isFlipped = true
            }
        }
    }
}

// MARK: - Moving Card View
struct MovingCardView: View {
    let card: AzizeCard
    let groupYOffset: CGFloat
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var hasReachedDestination: Bool = false
    let onReachDestination: () -> Void
    
    var body: some View {
        Image("cardCover")
            .resizable()
            .scaledToFit()
            .frame(width: UIScreen.main.bounds.width * 0.30, height: UIScreen.main.bounds.height * 0.18)
            .offset(x: xOffset, y: yOffset)
            .opacity(opacity)
            .onAppear {
                let targetOffset = card.position.offset
                withAnimation(.easeInOut(duration: 0.8)) {
                    xOffset = targetOffset.x
                    yOffset = targetOffset.y + groupYOffset
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    hasReachedDestination = true
                    onReachDestination()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        opacity = 0
                    }
                }
            }
    }
}
// MARK: - Return Card View
struct ReturnCardView: View {
    let card: AzizeCard
    let groupYOffset: CGFloat
    @State private var isFlipped: Bool = false
    @State private var xOffset: CGFloat
    @State private var yOffset: CGFloat
    let onFlipComplete: () -> Void
    
    init(card: AzizeCard, groupYOffset: CGFloat, onFlipComplete: @escaping () -> Void) {
        self.card = card
        self.groupYOffset = groupYOffset
        self.onFlipComplete = onFlipComplete
        
        let position = card.position
        _xOffset = State(initialValue: position.offset.x)
        _yOffset = State(initialValue: position.offset.y + groupYOffset)
    }
    
    var body: some View {
        ZStack {
            if isFlipped {
                Image("cardCover")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.30, height: UIScreen.main.bounds.height * 0.18)
                    .scaleEffect(y:-1)
            } else {
                Image("\(card.number)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.30, height: UIScreen.main.bounds.height * 0.18)
            }
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 1, y: 0, z: 0)
        )
        .offset(x: xOffset, y: yOffset)
        .onAppear {
            // Tüm kartlar aynı anda dönecek
            withAnimation(.easeInOut(duration: 0.5)) {
                isFlipped = true
            }
            
            // Dönme animasyonu bittikten sonra
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onFlipComplete()
                // Desteye dönme animasyonu
                withAnimation(.easeInOut(duration: 0.8)) {
                    xOffset = 0
                    yOffset = 0
                }
            }
        }
    }
    
}
// MARK: - Main Game View
struct AzizeView: View {
    @State private var cards: [AzizeCard] = []
    @State private var stackTopCardIndex: Int = 0
    @State private var drawnCards: [Int: [CardPosition: AzizeCard]] = [:]
    @State private var shadowCards: [UUID: AzizeCard] = [:]
    @State private var azizeFound: Bool = false
    @State private var isGameActive: Bool = true
    @State private var isReturningCards: Bool = false
    @State private var flipCompleteCount: Int = 0
    
    private let maxCards = 12
    private let groupOffsetY: CGFloat = UIScreen.main.bounds.height * 0.02
    
    var body: some View {
           ZStack {
               AppColors.newBackground
                   .scaledToFill()
                   .ignoresSafeArea()
               
               VStack {
                   Spacer()
                   ZStack {
                       // Kart destesini her zaman göster
                       ForEach(Array(cards.indices), id: \.self) { index in
                           if index >= stackTopCardIndex {
                               Image("cardCover")
                                   .resizable()
                                   .scaledToFit()
                                   .frame(width: UIScreen.main.bounds.width * 0.30, height: UIScreen.main.bounds.height * 0.18)
                                   .zIndex(Double(cards.count - index))
                           }
                       }
                       
                       // Returning cards animation
                       if isReturningCards {
                           ForEach(drawnCards.keys.sorted(), id: \.self) { groupIndex in
                               if let group = drawnCards[groupIndex] {
                                   ForEach(Array(group.values), id: \.id) { card in
                                       ReturnCardView(
                                           card: card,
                                           groupYOffset: CGFloat(groupIndex) * groupOffsetY
                                       ) {
                                           flipCompleteCount += 1
                                           if flipCompleteCount == maxCards {
                                               // Reset game when all cards have flipped
                                               DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                                   drawnCards = [:]
                                                   shadowCards = [:]
                                                   stackTopCardIndex = 0
                                                   isReturningCards = false
                                                   flipCompleteCount = 0
                                                   shuffleCards()
                                               }
                                           }
                                       }
                                       .zIndex(Double(cards.count + groupIndex))
                                   }
                               }
                           }
                       }
                       
                       // Normal game view for moving and shadow cards
                       if !isReturningCards {
                           ForEach(drawnCards.keys.sorted(), id: \.self) { groupIndex in
                               if let group = drawnCards[groupIndex] {
                                   ForEach(Array(group.values), id: \.id) { card in
                                       if shadowCards[card.id] != nil {
                                           ShadowCardView(cardNumber: card.number,
                                                        position: card.position,
                                                        groupYOffset: CGFloat(groupIndex))
                                               .offset(x: card.position.offset.x,
                                                       y: card.position.offset.y + CGFloat(groupIndex) * groupOffsetY)
                                               .zIndex(Double(cards.count + groupIndex))
                                       }
                                       
                                       MovingCardView(
                                           card: card,
                                           groupYOffset: CGFloat(groupIndex) * groupOffsetY,
                                           onReachDestination: {
                                               shadowCards[card.id] = card
                                               if card.number == 2 {
                                                   print("Azize bulundu!")
                                                   azizeFound = true
                                                   //isGameActive = false
                                               }
                                               
                                               if stackTopCardIndex == maxCards && !azizeFound {
                                                   DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                       isReturningCards = true }
                                                       DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                           isGameActive = false
                                                       }
                                               }
                                           }
                                       )
                                       .zIndex(Double(cards.count + groupIndex))
                                   }
                               }
                           }
                       }
                   }
                   .onTapGesture {
                       if isGameActive && !isReturningCards {
                           handleCardTap()
                       }
                   }
                   .padding(.bottom, UIScreen.main.bounds.height * 0.02)
               }
           }
           .onAppear {
               shuffleCards()
           }
       }
    
    private func handleCardTap() {
        guard stackTopCardIndex < cards.count && stackTopCardIndex < maxCards else { return }
        
        if cards[stackTopCardIndex].number == 2 {
            isGameActive = false
        }
        
        let groupIndex = stackTopCardIndex / 4
        let positionIndex = stackTopCardIndex % 4
        let newPosition: CardPosition
        
        switch positionIndex {
        case 0: newPosition = .leftTop
        case 1: newPosition = .centerTop
        case 2: newPosition = .rightTop
        case 3: newPosition = .centerMiddle
        default: return
        }
        
        let updatedCard = AzizeCard(
            number: cards[stackTopCardIndex].number,
            position: newPosition
        )
        
        cards[stackTopCardIndex] = updatedCard
        
        if drawnCards[groupIndex] == nil {
            drawnCards[groupIndex] = [:]
        }
        drawnCards[groupIndex]?[newPosition] = updatedCard
        
        stackTopCardIndex += 1
    }
    
    private func shuffleCards() {
        var newCards = (0...77).map { AzizeCard(number: $0, position: .deck) }
        newCards.shuffle()
        cards = newCards
        isGameActive = true
        azizeFound = false
        isReturningCards = false
    }
}

// MARK: - Preview
struct AzizeView_Previews: PreviewProvider {
    static var previews: some View {
        AzizeView()
    }
}
