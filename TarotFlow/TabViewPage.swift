
import SwiftUI

struct TabViewPage: View{
    
    @EnvironmentObject var userData: UserData
    @State var Tab = 1
    @Binding var selectedTab: Int
    
    init(selectedTab: Binding<Int> = .constant(0)) {
        self._selectedTab = selectedTab
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColors.customGray)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    
    var body: some View{
        ZStack{
            HStack{
                TabView (selection: $Tab){
                    CardInfoScreen() // HomeView bileşenine yönlendirilir
                        .tabItem {
                            Label("Info", systemImage: "info")
                        }.tag(0)
                    
                    HomepageScreen(Tab: $Tab) // ProfileView bileşenine yönlendirilir
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }.tag(1)
                    
                    dynamicCardView()
                        .tabItem {
                            Label("Fortune", systemImage: "book")
                        }.tag(2) // 3. sekmenin benzersiz tag'
                }
                .tint(Color.white)
                .onChange(of: Tab) { newTab in
                    if newTab != 2 {
                    // Eğer kart sekmesinden başka bir sekmeye geçiliyorsa, kartları temizle
                        userData.flippedCards.removeAll()
                        userData.chatGPTResponse = nil
                                   }
                                   }
            }.environmentObject(userData)
        }
    }

    @ViewBuilder
    private func dynamicCardView() -> some View {
        
        if userData.activeCardView == "single" {
            SingleCardScreen()
                .onChange(of: Tab) { _ in
                  userData.activeCardView = ""
                }
        } else if userData.activeCardView == "triple" {
            TripleCardScreen()
                .onChange(of: Tab) { _ in
                  userData.activeCardView = ""
                }
        } else {
            // Varsayılan görünüm
           EmptyView()
        }
    }
}

struct TabViewPage_Previews: PreviewProvider{
    static var previews: some View {
          //  @State var previewSelectedTab = 0 // Preview için bir @State oluştur
            return TabViewPage()
                .environmentObject(UserData())
    }
}
