import Foundation
import FirebaseDatabase
import FirebaseAuth


class UserData: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var prefname: String = ""
    @Published var birthDate: Date = Date()
    @Published var lastLogin: String = ""
    @Published var verified: Bool = false
    @Published var premium: Bool = false
    @Published var isSignUpComplete: Bool = false
    @Published var shouldNavigateToLogin: Bool = false
    
    @Published var activeCardView: String = ""
    
    //auth-loginviewdangelen
    
  //  @Published var isLogInActive = true
    @Published var username: String = ""
  //  @Published var password: String = ""
   // @Published var email: String = ""
    @Published var email2: String = ""
    @Published var passwordRepeat: String = ""
    @Published var signUpErrorMessage: String? = nil
    @Published var loginErrorMessage: String? = nil
    @Published var isLoginSuccessful = false
    @Published var isSignUpSuccessful = false
    
    @Published var chatGPTResponse: String? = nil // Fal yanıtını saklamak için
    @Published var flippedCards: [Int] = [] // Açılan kartları tutmak için
    
    func clearChatGPTResponse() {
           chatGPTResponse = nil
           flippedCards.removeAll()
       }
    
    // Email doğrulama extension'ı
        func isValidEmail(_ email: String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: email)
        }
        
        // Signup fonksiyonu
        func signUp() {
            guard isValidEmail(email) else {
                signUpErrorMessage = "Geçersiz email adresi."
                return
            }
            
            guard password.count >= 6 else {
                signUpErrorMessage = "Password needs to be at least 6 characters long."
                return
            }
            
            guard password == passwordRepeat else {
                signUpErrorMessage = "Passwords do not match."
                return
            }
            
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.signUpErrorMessage = "Signup failed: \(error.localizedDescription)"
                } else {
                    self.signUpErrorMessage = nil
                    self.isSignUpSuccessful = true
                }
            }
        }
        
    private var authStateDidChangeListener: AuthStateDidChangeListenerHandle?

    init() {
        // Uygulama ayarlarını yükle
        loadAppSettings()
        
        // Firebase Auth durumundaki değişiklikleri dinle
        authStateDidChangeListener = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user == nil {
                // Kullanıcı oturumu kapatmış, tüm durumu temizle
                self?.resetAllState()
            }
        }
    }

    // Sınıfı bellekten kaldırmadan önce listener'ı temizlememiz gerekiyor
    deinit {
        if let handle = authStateDidChangeListener {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func resetAllState() {
        // Kimlik bilgilerini sıfırla
        email = ""
        email2 = ""
        password = ""
        passwordRepeat = ""
        prefname = ""
        birthDate = Date()
        lastLogin = ""
        verified = false
        premium = false
        isSignUpComplete = false
        shouldNavigateToLogin = true
        isLoginSuccessful = false
        isSignUpSuccessful = false
        
        // Fal ve kart verilerini sıfırla
        chatGPTResponse = nil
        flippedCards.removeAll()
        activeCardView = ""
        
        // Countdown state'lerini sıfırla ama threshold değerleri sabit kalsın
        singleCardCountdownStartTime = 0
        singleCardRemainingTime = 0
        isSingleCardCountdownActive = false
        
        tripleCardCountdownStartTime = 0
        tripleCardRemainingTime = 0
        isTripleCardCountdownActive = false
        databaseSingleCountdown = 0
        databaseTripleCountdown = 0
        
        // Hata mesajlarını temizle
        signUpErrorMessage = nil
        loginErrorMessage = nil
    }
    
        // Login fonksiyonu
//        func login() {
//            guard isValidEmail(email2) else {
//                loginErrorMessage = "Invalid email address."
//                return
//            }
//            
//            Auth.auth().signIn(withEmail: email2, password: password) { [weak self] authResult, error in
//                guard let self = self else { return }
//                
//                if let error = error as NSError? {
//                    switch AuthErrorCode(rawValue: error.code) {
//                    case .userNotFound:
//                        self.loginErrorMessage = "User not found."
//                    case .wrongPassword:
//                        self.loginErrorMessage = "Wrong password."
//                    default:
//                        self.loginErrorMessage = "An error has occurred: \(error.localizedDescription)"
//                    }
//                    return
//                }
//                
//                guard let user = Auth.auth().currentUser else {
//                    self.loginErrorMessage = "User not found."
//                    return
//                }
//                
//                let db = Database.database().reference()
//                let userRef = db.child("users").child(user.uid)
//                
//                userRef.observeSingleEvent(of: .value) { snapshot in
//                    if let userDataDict = snapshot.value as? [String: Any] {
//                        self.email = userDataDict["email"] as? String ?? ""
//                        self.prefname = userDataDict["prefname"] as? String ?? ""
//                        
//                        if let birthDateString = userDataDict["birthDate"] as? String,
//                           let birthDate = ISO8601DateFormatter().date(from: birthDateString) {
//                            self.birthDate = birthDate
//                        }
//                        
//                        self.loginErrorMessage = nil
//                        self.isLoginSuccessful = true
//                    } else {
//                        self.loginErrorMessage = "User information couldn't be retrieved."
//                    }
//                }
//            }
//        }
    
    func login() {
        guard isValidEmail(email2) else {
            loginErrorMessage = "Invalid email address."
            return
        }
        
        Auth.auth().signIn(withEmail: email2, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .userNotFound:
                    self.loginErrorMessage = "User not found."
                case .wrongPassword:
                    self.loginErrorMessage = "Wrong password."
                default:
                    self.loginErrorMessage = "An error has occurred: \(error.localizedDescription)"
                }
                return
            }
            
            guard let user = Auth.auth().currentUser else {
                self.loginErrorMessage = "User not found."
                return
            }
            
            // Önce mevcut durumu temizle (farklı bir kullanıcıya geçiş durumu için)
            self.resetAllState()
            
            // Sonra yeni kullanıcı verilerini yükle
            self.loadUserData(for: user.uid)
        }
    }
    
    func toFirebaseData() -> [String: Any] {
        return [
            "email": email,
            "prefname": prefname,
            "birthDate": ISO8601DateFormatter().string(from: birthDate),
            "lastLogin": lastLogin,
            "verified": verified,
            "premium": premium
        ]
    }
    func formatBirthDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_EN") // Set locale to Turkish
        formatter.dateFormat = "EEEE, d MMMM" // Format for "Day of week, day Month"
        return formatter.string(from: date) // Returns the formatted string
    }
    
    func loadUserData(for userId: String) {
        let db = Database.database().reference()
        let userRef = db.child("users").child(userId)
        
        userRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let userDataDict = snapshot.value as? [String: Any] {
                self.email = userDataDict["email"] as? String ?? ""
                self.prefname = userDataDict["prefname"] as? String ?? ""
                
                if let birthDateString = userDataDict["birthDate"] as? String,
                   let birthDate = ISO8601DateFormatter().date(from: birthDateString) {
                    self.birthDate = birthDate
                }
                
                // Countdown verilerini de yükle
                self.databaseSingleCountdown = userDataDict["singleCardCountdown"] as? Double ?? 0
                self.databaseTripleCountdown = userDataDict["tripleCardCountdown"] as? Double ?? 0
                
                self.loginErrorMessage = nil
                self.isLoginSuccessful = true
            } else {
                self.loginErrorMessage = "User information couldn't be retrieved."
            }
        }
    }
    
//    func logout() {
//        do {
//            try Auth.auth().signOut()
//            // Mevcut kullanıcı verilerini temizle
//            self.email = ""
//            self.email2 = ""
//            self.password = ""
//            self.prefname = ""
//            self.birthDate = Date()
//            
//            
//            self.shouldNavigateToLogin = true
//            isLoginSuccessful = false
//            
//            print("Succesfully signed out.")
//        } catch let signOutError as NSError {
//            print("An error has occurred while signing out: \(signOutError.localizedDescription)")
//            // Kullanıcıya hata mesajı göster
//            //bos
//        }
//    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            self.shouldNavigateToLogin = true
//            isLoginSuccessful = false
            // State resetleme işini artık listener halledecek
            print("Successfully signed out.")
        } catch let signOutError as NSError {
            print("An error has occurred while signing out: \(signOutError.localizedDescription)")
        }
    }

    func checkAuthStatus() -> Bool {
            return Auth.auth().currentUser == nil
        }
    
    //Countdown threshold'u veritabanından kontrol etmek icin fonksiyonlar
    func loadAppSettings() {
        let db = Database.database().reference()
        let settingsRef = db.child("app_settings")
        
        settingsRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let settingsDict = snapshot.value as? [String: Any] {
                // Threshold değerlerini yükle
                if let singleThreshold = settingsDict["singleCardThreshold"] as? TimeInterval {
                    self.singleCardCountdownThreshold = singleThreshold
                }
                
                if let tripleThreshold = settingsDict["tripleCardThreshold"] as? TimeInterval {
                    self.tripleCardCountdownThreshold = tripleThreshold
                }
                
                print("App settings loaded successfully.")
            } else {
                print("App settings not found, using default values.")
                // Veritabanında ayarlar yoksa, varsayılan değerleri yükle ve kaydet
                self.saveAppSettings()
            }
        }
    }

    // Threshold değerlerini veritabanına kaydet (yönetici/test amaçlı)
    func saveAppSettings() {
        let db = Database.database().reference()
        let settingsRef = db.child("app_settings")
        
        let settings: [String: Any] = [
            "singleCardThreshold": singleCardCountdownThreshold,
            "tripleCardThreshold": tripleCardCountdownThreshold
        ]
        
        settingsRef.updateChildValues(settings) { error, _ in
            if let error = error {
                print("Failed to save app settings: \(error.localizedDescription)")
            } else {
                print("App settings saved successfully.")
            }
        }
    }
    
    //Countdown degiskenleri
        @Published var singleCardCountdownStartTime: TimeInterval = 0
        @Published var singleCardCountdownThreshold: TimeInterval = 1220 // 30 saniye test için
        @Published var singleCardRemainingTime: TimeInterval = 0
        @Published var isSingleCardCountdownActive: Bool = false
        
        @Published var tripleCardCountdownStartTime: TimeInterval = 0
        @Published var tripleCardCountdownThreshold: TimeInterval = 2120 // Örnek farklı bir threshold
        @Published var tripleCardRemainingTime: TimeInterval = 0
        @Published var isTripleCardCountdownActive: Bool = false
    @Published var databaseSingleCountdown: Double = 0
    @Published var databaseTripleCountdown: Double = 0
        
        
    


}
