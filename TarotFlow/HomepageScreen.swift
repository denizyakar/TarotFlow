
import SwiftUI
import Lottie
import FirebaseAuth
struct HomepageScreen: View {
    @EnvironmentObject var userData: UserData
    @State private var selectedTab = 0
    @State private var showMenu = false
    @State private var isAnimating = false
    @State private var playInitialAnimation = true
    @State private var shouldNavigate = false
    @State private var isLoggedOut = false // State to track logout status
    @State private var navigateToLogin = false
    @Binding var Tab: Int
    
    let animationSpeed: CGFloat = 1.0
    
    let singleCardTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let tripleCardTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        
    var body: some View {
            ZStack { // Use ZStack to layer the background
                //Centik vb. siyah yapmak icin
                AppColors.newBackground.ignoresSafeArea()
                
                    .onAppear {
                               // Eğer kullanıcı giriş yapmışsa countdown bilgilerini yükle
                               if userData.isLoginSuccessful {
                                   userData.loadCountdownStartTime()
                                   
                                
                               }
                           }
//                LottieView(animation: .named("shootingStarWn"))
//                    .playing(loopMode: .loop)
//                    .scaledToFill()
//                    .ignoresSafeArea()
                
                
                VStack {
                    
                    UserInfoView(navigateToLogin: $navigateToLogin)
                    
                    NavigationLink(
                                        destination: LoginScreen()
                                            .navigationBarBackButtonHidden()
                                            .navigationBarHidden(true),
                                        isActive: $navigateToLogin
                                    ) {
                                        EmptyView()
                                    }
                    
                    // TabView in the middle for different pages
                    CustomSegmentedPicker(selectedTab: $selectedTab)
                        .padding(.horizontal,Styling.rRheight/11*2)
                    
                    
                    Spacer()
                    
                    
                    // Content changes based on selected tab
                    ZStack{
                        Image("fingerprintgray2")
                            .resizable()
                            .frame(width:Styling.rRheight*3, height:Styling.rRheight*3,alignment:.center)
                            .foregroundColor(.gray)
                            .gesture(
                                LongPressGesture(minimumDuration:0.03)
                                    .onEnded { _ in
                                        // Countdown kontrolü
                                            if selectedTab == 0 && !userData.isSingleCardCountdownActive {
                                            isAnimating = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                            if isAnimating {
                                            Tab = 2
                                            userData.startSingleCardCountdown()
                                            userData.activeCardView = "single"
                                                            }
                                                            }
                                        } else if selectedTab == 1 && !userData.isTripleCardCountdownActive {
                                           isAnimating = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        if isAnimating {
                                        Tab = 2
                                        userData.startTripleCardCountdown()
                                        userData.activeCardView = "triple"
                                            }
                                                }
                                                }
                                                }
                                        .simultaneously(with: DragGesture(minimumDistance:0)
                                        .onEnded { _ in
                                        isAnimating = false
                                                                        })
                                                            )
                  
                        if isAnimating &&
                                               ((selectedTab == 0 && !userData.isSingleCardCountdownActive) ||
                                                (selectedTab == 1 && !userData.isTripleCardCountdownActive)) {
                                               LottieViewUI(animationName: "lottieFingerprint", loopMode: .playOnce, speed: animationSpeed)
                                .frame(width: Styling.rRheight*5, height: Styling.rRheight*5)
                                                   .padding(.top,20)
                                           }
                                       }
                                       .frame(maxWidth: Styling.rRheight*3, maxHeight: Styling.rRheight*3)
                                       
                                       // Dinamik countdown metni
                                       if selectedTab == 0 && userData.isSingleCardCountdownActive {
                                           Text(userData.formatSingleCardCountdownTime())
                                               .font(.system( size: Styling.rRheight/50*16))
                                               .foregroundColor(.white)
                                       } else if selectedTab == 1 && userData.isTripleCardCountdownActive {
                                           Text(userData.formatTripleCardCountdownTime())
                                               .font(.system( size: Styling.rRheight/50*16))
                                               .foregroundColor(.white)
                                       } else {
                                           Text("Press and Hold")
                                               .font(.system( size: Styling.rRheight/50*16))
                                               .opacity(0.8)
                                               .foregroundColor(AppColors.customGray)
                                       }
                                       
                                       Spacer()
                                   }
                                   .padding(.horizontal)
                                   .onReceive(singleCardTimer) { _ in
                                       userData.updateSingleCardCountdownTime()
                                   }
                                   .onReceive(tripleCardTimer) { _ in
                                       userData.updateTripleCardCountdownTime()
                                   }
                               
            }//ZStack
            .onAppear {
                userData.clearChatGPTResponse() // Yeni ekrana geçince falı temizle
            }
    } // body
    
}//HomepageScreen

struct CustomSegmentedPicker: View {
    @Binding var selectedTab: Int

    private let tabs = ["Single Card", "Triple Card"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                Text(tabs[index])
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Styling.rRheight/55*11)
                    .background(self.selectedTab == index ? AppColors.customGray : Color.gray.opacity(0.0))
                    .foregroundColor(self.selectedTab == index ? Color.white : AppColors.customGray)
                    .cornerRadius(Styling.rRheight/11*10)
                    .font(.system(size: Styling.rRheight/50*16))
                    .contentShape(Rectangle()) // Tüm alanın tıklanabilir olmasını sağlar
                    .onTapGesture {
                        withAnimation {
                            selectedTab = index
                        }
                    }
            }
        }
        .padding(7)
        .background(Color.black.opacity(0.0))
        .overlay(
            Styling.customRectangle(
                cornerRadius: Styling.rRheight/11*10,
                lineWidth: 2,
                height: Styling.rRheight,
                highOpacity: Styling.gradientOpacityHigh,
                lowOpacity: Styling.gradientOpacityLow
            ))
        .onChange(of: selectedTab) { newValue in
            print("Selected Tab Changed to: \(newValue)")
        }
    }
}

struct UserInfoView: View {
    @EnvironmentObject var userData: UserData
    @Binding var navigateToLogin: Bool
    
    var body: some View {
        HStack {
            ZStack {
               
                Circle()
                    .fill(getZodiacColor(from: userData.birthDate)) // Burç rengine göre arkaplan
                    .frame(width: Styling.rRheight / 16 * 8, height: Styling.rRheight / 16 * 8)

                
                Circle()
                    .stroke(Styling.customGradient(), lineWidth: 2) // Çerçeve rengi
                    .frame(width: Styling.rRheight / 11 * 8, height: Styling.rRheight / 11 * 8) .foregroundColor(AppColors.customGray)

               
                Image(getZodiacSign(from: userData.birthDate))
                    .resizable()
                    .scaledToFit()
                    .frame(width: Styling.rRheight / 20 * 8, height: Styling.rRheight / 20 * 8) //
            }
            
            VStack(alignment: .leading) {
                    Text("Hey, \(userData.prefname)!")
                        .font(.system( size: Styling.rRheight / 50 * 16))
                        .foregroundColor(AppColors.customGray)
                HStack{
                    Text("You are a")
                        .font(.system( size: Styling.rRheight / 50 * 16))
                        .foregroundColor(AppColors.customGray)
                    Text("\(getZodiacName(from: userData.birthDate))!")
                        .font(.system( size: Styling.rRheight / 50 * 16))
                        .foregroundColor(getZodiacColor(from: userData.birthDate))
                }
                
                Text(userData.formatBirthDate(userData.birthDate))
                    .foregroundColor(AppColors.customGray)
                    .font(.system( size: Styling.rRheight / 50 * 16))
            }
            Spacer()
            MenuButtonView(navigateToLogin: $navigateToLogin)
        }
        .padding()
        .environmentObject(userData)
    }
    
    // Doğum tarihine göre burç simgesini belirleme
    func getZodiacSign(from birthDate: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month], from: birthDate)
        let day = components.day ?? 0
        let month = components.month ?? 0
        
        switch (month, day) {
        case (1, 20...31), (2, 1...18):
            return "aquarius" // Kova
        case (2, 19...29), (3, 1...20):
            return "pisces" // Balık
        case (3, 21...31), (4, 1...19):
            return "aries" // Koç
        case (4, 20...30), (5, 1...20):
            return "taurus" // Boğa
        case (5, 21...31), (6, 1...20):
            return "gemini" // İkizler
        case (6, 21...30), (7, 1...22):
            return "cancer" // Yengeç
        case (7, 23...31), (8, 1...22):
            return "leo" // Aslan
        case (8, 23...31), (9, 1...22):
            return "virgo" // Başak
        case (9, 23...30), (10, 1...22):
            return "libra" // Terazi
        case (10, 23...31), (11, 1...21):
            return "scorpion" // Akrep
        case (11, 22...30), (12, 1...21):
            return "sagittarius" // Yay
        case (12, 22...31), (1, 1...19):
            return "capricorn" // Oğlak
        default:
            return "defaultSign" // Varsayılan bir simge, hata durumunda
        }
    }
    
    // Doğum tarihine göre burç rengi belirleme
    func getZodiacColor(from birthDate: Date) -> Color {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month], from: birthDate)
        let day = components.day ?? 0
        let month = components.month ?? 0
        
        switch (month, day) {
        case (1, 20...31), (2, 1...18):
            return Color.blue // Kova
        case (2, 19...29), (3, 1...20):
            return Color.purple // Balık
        case (3, 21...31), (4, 1...19):
            return Color.red // Koç
        case (4, 20...30), (5, 1...20):
            return Color.green // Boğa
        case (5, 21...31), (6, 1...20):
            return Color.yellow // İkizler
        case (6, 21...30), (7, 1...22):
            return Color.gray // Yengeç
        case (7, 23...31), (8, 1...22):
            return Color.orange // Aslan
        case (8, 23...31), (9, 1...22):
            return Color.brown // Başak
        case (9, 23...30), (10, 1...22):
            return Color.pink // Terazi
        case (10, 23...31), (11, 1...21):
            return Color.red // Akrep
        case (11, 22...30), (12, 1...21):
            return Color.purple // Yay
        case (12, 22...31), (1, 1...19):
            return Color.black // Oğlak
        default:
            return Color.gray // Varsayılan renk, hata durumunda
        }
    }
    
    func getZodiacName(from birthDate: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month], from: birthDate)
        let day = components.day ?? 0
        let month = components.month ?? 0
        //ram koç
//        taurus boğa
//        gemini ikizler
//        cancer yengeç
//        leo aslan
//        virgo başak
//        libra terazi
//        scorpio akrep
//        sagittarius yay
//        capricornus oğlak
//        aquarius kova
//        pisces balık
        switch (month, day) {
        case (1, 20...31), (2, 1...18):
            return "Aquarius" // Kova
        case (2, 19...29), (3, 1...20):
            return "Pisces" // Balık
        case (3, 21...31), (4, 1...19):
            return "Ram" // Koç
        case (4, 20...30), (5, 1...20):
            return "Taurus" // Boğa
        case (5, 21...31), (6, 1...20):
            return "Gemini" // İkizler
        case (6, 21...30), (7, 1...22):
            return "Cancer"// Yengeç
        case (7, 23...31), (8, 1...22):
            return "Leo" // Aslan
        case (8, 23...31), (9, 1...22):
            return "Virgo" // Başak
        case (9, 23...30), (10, 1...22):
            return "Libra"// Terazi
        case (10, 23...31), (11, 1...21):
            return "Scorpius" // Akrep
        case (11, 22...30), (12, 1...21):
            return "Sagittarius" // Yay
        case (12, 22...31), (1, 1...19):
            return "Capricornus" // Oğlak
        default:
            return "Your Zodiac" // Varsayılan renk, hata durumunda
        }
    }
    
}

struct MenuButtonView: View {
    @State private var showMenu = false
    @Binding var navigateToLogin: Bool
    
    var body: some View {
        Button(action: {
            showMenu.toggle()
        }) {
            HStack {
                Image(systemName: "line.horizontal.3")
                    .frame(width:Styling.rRheight/11*8, height:Styling.rRheight/11*8)
                    //.clipShape(Circle())
                    .overlay(Circle().stroke(
                        Styling.customGradient()
                        ))
            }
            .background(AppColors.customGray)
            .foregroundColor(.white)
            .cornerRadius(Styling.rRheight/11*4)
        }
        .sheet(isPresented: $showMenu) {
            MenuView(closeAction:{
                showMenu = false}, navigateToLogin: $navigateToLogin)
                    
            
                    
               
            
        }
    }
    
    
    
}

struct MenuView: View {
    var closeAction: () -> Void
    @Binding var navigateToLogin: Bool
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        ZStack {
            AppColors.newBackground.ignoresSafeArea()
            
            let helper = UserInfoView(navigateToLogin: $navigateToLogin)
            
            // Arkaplandaki burç fotoğrafı ve ismi
            ZStack {
                VStack{
                    Image(helper.getZodiacSign(from: userData.birthDate))
                        .resizable()
                        .frame(width: Styling.rRheight * 3, height: Styling.rRheight * 3)
                        .opacity(0.2) // Arkada daha belirgin ama rahatsız etmeyen bir görünüm sağlar
                    
                    Text(helper.getZodiacName(from: userData.birthDate))
                        .font(.system(size: Styling.rRheight / 2))
                        .opacity(0.2) // Yazının da arka planda kalmasını sağlamak için şeffaflık verdik
                }
            }
            
            
            // Menü ve butonlar
            VStack {
                Text("Menu")
                    .font(.system(size: Styling.rRheight / 1.5))
                    .foregroundColor(AppColors.customGray)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    userData.logout()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        navigateToLogin = true
                    }
                    closeAction()
                }) {
                    Text("Logout")
                        .foregroundColor(AppColors.customGray)
                        .font(.system(size: Styling.rRheight / 1.8))
                        .padding()
                }
                
                //Close Button
                
//                Button(action: {
//                    closeAction()
//                }) {
//                    Text("Close")
//                        .foregroundColor(AppColors.customGray)
//                        .font(.system(size: Styling.rRheight / 1.8))
//                        .padding()
//                }
            }
            
        }
    }
}



struct HomepageScreen_Previews: PreviewProvider {
    static var previews: some View {
        @State var previewTab = 1
       return HomepageScreen(Tab:$previewTab)
            .environmentObject(UserData())
    }
}
