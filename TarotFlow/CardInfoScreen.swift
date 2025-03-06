import SwiftUI

struct CardInfoScreen: View {
    
    @State private var selectedCard: Card? = nil
    @State private var isExpanded: Bool = false
    @Namespace private var cardAnimation
    
    let cards = TarotCardData.cards
    
    var body: some View {
        ZStack {
            AppColors.newBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 40) {
                    ForEach(cards) { card in
                        CardsView(card: card, namespace: cardAnimation)
                    }
                }
            }
            
            VStack {
                Spacer()
            }
        }
    }
}

struct Card: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let imageName: String
    let description: String
}

struct CardsView: View {
    let card: Card
    var namespace: Namespace.ID
    
    var body: some View {
        HStack(alignment: .top) {
            ZStack {
                Image(card.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 130, height: 180)
            }
            .frame(width: 150)
            
            VStack(alignment: .leading) {
                Text(card.name)
                    .font(.headline)
                    .foregroundColor(AppColors.customGray)
                
                Text(card.description)
                    .font(.subheadline)
                    .foregroundColor(AppColors.customGray)
            }
            
            Spacer()
        }
        .padding()
        .padding(.top, 20)
    }
}

struct CardInfoScreen_Previews: PreviewProvider {
    static var previews: some View {
        @State var previewInHomePage = false
        @State var previewCurrentView = "cardInfo"
        @State var previewShouldNavigate = false
        
        return CardInfoScreen()
    }
}
