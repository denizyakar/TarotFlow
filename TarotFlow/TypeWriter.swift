import SwiftUI

struct TypewriterOverlay: View {
    @Binding var isVisible: Bool
    @EnvironmentObject var userData: UserData  // Kullanıcı verisini al
    
    @State private var displayedText = ""
    @State private var currentIndex = 0
    @State private var isTyping = false
    private let gptService = GPTService()

    @State private var timer: Timer? = nil

    var body: some View {
        ZStack {
            if isVisible {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        Capsule()
                            .fill(Color.white)
                            .frame(width: 60, height: 6)
                            .padding(.top, 10)
                            .padding(.bottom, 5)

                        ScrollView {
                            VStack {
                                Text(displayedText)
                                    .font(Font.custom("SpaceGrotesk-Medium", size: 18))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(AppColors.customGray)
                                    .cornerRadius(20)
                                    .frame(width: 340)
                                    .id("BOTTOM")
                            }
                        }
                        .onAppear {
                            if userData.chatGPTResponse == nil { // Eğer API yanıtı yoksa, çağrı yap
                                fetchChatGPTResponse()
                            } else {
                                startTyping() // Zaten varsa yazdırmaya devam et
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.9))
                    .cornerRadius(20)
                    .frame(width: 320)
                }
            }
        }
    }

    /// ** API Yanıtını Sakla ve Tekrar Çağırma**
    func fetchChatGPTResponse() {
        if userData.chatGPTResponse != nil {
            startTyping() // Eğer önceki fal varsa, onu kullan
            return
        }

        let selectedCards = userData.flippedCards.compactMap { getCardDetails(for: $0) }

        let cardNames = selectedCards.map { $0.name }
        let cardDescriptions = selectedCards.map { $0.description }

        gptService.sendMessage(cardNames: cardNames, cardDescriptions: cardDescriptions) { response in
            DispatchQueue.main.async {
                userData.chatGPTResponse = response ?? "Could not retrieve interpretation."
                displayedText = ""
                currentIndex = 0
                startTyping()
            }
        }
    }
    
    func startTyping() {
        guard !isTyping else { return }
        isTyping = true
        displayedText = ""

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if let chatGPTResponse = userData.chatGPTResponse, currentIndex < chatGPTResponse.count {
                let index = chatGPTResponse.index(chatGPTResponse.startIndex, offsetBy: currentIndex)
                displayedText += String(chatGPTResponse[index])
                currentIndex += 1
            } else {
                stopTyping()
            }
        }
    }
    
    func stopTyping() {
        isTyping = false
        timer?.invalidate()
        timer = nil
    }
    
    func getCardDetails(for index: Int) -> (name: String, description: String) {
        if index >= 0 && index < TarotCardData.cards.count {
            let card = TarotCardData.cards[index]
            return (name: card.name, description: card.description)
        }
        return ("Unknown Card", "No description available.")
    }
}
