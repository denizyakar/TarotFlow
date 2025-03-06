import Foundation
import FirebaseDatabase
import FirebaseAuth

extension UserData {
    
    //Countdown fonksiyonları
    // Single Card Countdown Metotları
    func startSingleCardCountdown() {
        singleCardCountdownStartTime = Date().timeIntervalSince1970
        singleCardRemainingTime = singleCardCountdownThreshold
        isSingleCardCountdownActive = true
        
        //database'e sabit kaydetmek icin
        databaseSingleCountdown = singleCardCountdownStartTime
        saveCountdownStartTime()
    }
    
    func updateSingleCardCountdownTime() {
        guard isSingleCardCountdownActive else { return }
        
        let currentTime = Date().timeIntervalSince1970
        let elapsedTime = currentTime - singleCardCountdownStartTime
        
        if elapsedTime >= singleCardCountdownThreshold {
            resetSingleCardCountdown()
        } else {
            singleCardRemainingTime = singleCardCountdownThreshold - elapsedTime
        }
    }
    
    func resetSingleCardCountdown() {
        singleCardCountdownStartTime = 0
        singleCardRemainingTime = 0
        isSingleCardCountdownActive = false
        
    }
    
    func formatSingleCardCountdownTime() -> String {
        let minutes = Int(singleCardRemainingTime) / 60
        let seconds = Int(singleCardRemainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Triple Card Countdown Metotları
    func startTripleCardCountdown() {
        tripleCardCountdownStartTime = Date().timeIntervalSince1970
        tripleCardRemainingTime = tripleCardCountdownThreshold
        isTripleCardCountdownActive = true
        
        //database'e sabit kaydetmek icin
        databaseTripleCountdown = tripleCardCountdownStartTime
        
        saveCountdownStartTime()
    }
    
    func updateTripleCardCountdownTime() {
        guard isTripleCardCountdownActive else { return }
        
        let currentTime = Date().timeIntervalSince1970
        let elapsedTime = currentTime - tripleCardCountdownStartTime
        
        if elapsedTime >= tripleCardCountdownThreshold {
            resetTripleCardCountdown()
        } else {
            tripleCardRemainingTime = tripleCardCountdownThreshold - elapsedTime
        }
    }
    
    func resetTripleCardCountdown() {
        tripleCardCountdownStartTime = 0
        tripleCardRemainingTime = 0
        isTripleCardCountdownActive = false
        
    }
    
    func formatTripleCardCountdownTime() -> String {
        let minutes = Int(tripleCardRemainingTime) / 60
        let seconds = Int(tripleCardRemainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    //////////////////////////////////////////////////////////////////////////////////
    
    
    
    // Countdown veritabanı fonksiyonları
    func saveCountdownStartTime() {
        guard let currentUser = Auth.auth().currentUser else {
            print("Kullanıcı oturumu açık değil")
            return
        }
        
        let db = Database.database().reference()
        let userCountdownRef = db.child("users").child(currentUser.uid).child("countdowns")
        
        let countdownData: [String: Any] = [
            "singleCardCountdown": databaseSingleCountdown,
//            "singleCardCountdownThreshold": singleCardCountdownThreshold,
            "tripleCardCountdown": databaseTripleCountdown,
//            "tripleCardCountdownThreshold": tripleCardCountdownThreshold
        ]
        
        userCountdownRef.setValue(countdownData) { error, _ in
            if let error = error {
                print("Countdown başlangıç zamanı kaydedilemedi: \(error.localizedDescription)")
            } else {
                print("Countdown başlangıç zamanı başarıyla kaydedildi")
            }
        }
    }
    
    // Önceki kayıtlı countdown bilgilerini yükleme metodu
    func loadCountdownStartTime() {
        guard let currentUser = Auth.auth().currentUser else {
            print("Kullanıcı oturumu açık değil")
            return
        }

        let db = Database.database().reference()
        let userCountdownRef = db.child("users").child(currentUser.uid).child("countdowns")

        userCountdownRef.observeSingleEvent(of: .value) { snapshot in
            guard let countdownData = snapshot.value as? [String: Any] else {
                print("Kayıtlı countdown bilgisi bulunamadı")
                return
            }

            let currentTime = Date().timeIntervalSince1970

            // Single Card Countdown Yükleme
            if let singleStartTime = countdownData["singleCardCountdown"] as? TimeInterval {
                self.singleCardCountdownStartTime = singleStartTime
                self.isSingleCardCountdownActive = (currentTime - singleStartTime) < self.singleCardCountdownThreshold
            }

            // Triple Card Countdown Yükleme
            if let tripleStartTime = countdownData["tripleCardCountdown"] as? TimeInterval {
                self.tripleCardCountdownStartTime = tripleStartTime
                self.isTripleCardCountdownActive = (currentTime - tripleStartTime) < self.tripleCardCountdownThreshold
            }
        }
    }
    
    
    
}
