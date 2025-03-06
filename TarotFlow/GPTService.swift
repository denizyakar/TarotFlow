import Foundation

class GPTService {
    private let apiKey = "YOUR GEMINI API KEY HERE"
    private let apiURL: String

    init() {
        self.apiURL = "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=\(apiKey)"
    }

    func sendMessage(cardNames: [String], cardDescriptions: [String], completion: @escaping (String?) -> Void) {
        guard let url = URL(string: apiURL), cardNames.count == cardDescriptions.count else {
            completion(nil)
            return
        }

        var prompt: String

        if cardNames.count == 1 {
            // **Tek kart için prompt**
            prompt = """
            You are a tarot card expert. Explain the fortune of the person who just drew the following tarot card, and give it them in a mystical and poetic but 'not hard to understand' way (Max 6 sentences and around 70 words).
            Start the answer with: You drew: '\(cardNames.first!)'.
            Tarot card meaning: \(cardDescriptions.first!).
            """
        } else if cardNames.count == 3 {
            // **Üçlü kart için prompt**
            prompt = """
            You are a tarot card expert. A person has drawn three tarot cards.

            First card: \(cardNames[0]) - \(cardDescriptions[0])
            Second card: \(cardNames[1]) - \(cardDescriptions[1])
            Third card: \(cardNames[2]) - \(cardDescriptions[2])

            Explain the fortune of the person who just drew these 3 tarot cards in a mystical and poetic but 'not hard to understand' way (Max 6 sentences and around 70 words).
            Start the answer with: You drew: '\(cardNames[0])', '\(cardNames[1])', '\(cardNames[2])'.
            """
        } else {
            // **Kart sayısı desteklenmiyorsa işlem yapma**
            completion(nil)
            return
        }

        let requestBody: [String: Any] = [
            "contents": [["parts": [["text": prompt]]]]
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let candidates = jsonResponse["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first,
               let content = firstCandidate["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let text = parts.first?["text"] as? String {
                completion(text.trimmingCharacters(in: .whitespacesAndNewlines))
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}
