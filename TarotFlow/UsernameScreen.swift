import SwiftUI

struct UsernameScreen: View {
    @EnvironmentObject var userData: UserData
    @State private var prefname:String=""
    @State private var errorMessage: String? = nil
    @State private var navigateToBirthdayView = false
    
    var body: some View {
        NavigationView{
            ZStack {
                AppColors.newBackground.ignoresSafeArea() //Black background
                
                VStack {
                    //Added Preferred Name as a title
                    Text("Preferred Name")
                        .font(Font.custom("SpaceGrotesk-Bold", size:Styling.rRheight / 5 * 4))
                        .foregroundColor(AppColors.customGray)
                        .padding(.horizontal)
                    
                    Text("How would you like us to address you?")
                        .font(Font.custom("SpaceGrotesk-Medium", size:Styling.rRheight / 6 * 2))
                        .foregroundColor(AppColors.customGray)
                        .padding(.horizontal)
                    
                    Text("Please choose or enter the name you'd like us to use when addressing you.")
                        .font(Font.custom("SpaceGrotesk-Light", size:Styling.rRheight / 6 * 2))
                        .foregroundColor(AppColors.customGray)
                        .padding(.horizontal)
                        .padding(.bottom, 50)
                    
                    // ZStack of Preferred Name Button to type the name
                    ZStack {
                        Button("") {
                            // No action
                        }
                        
                        TextField("Preferred Name",text:$prefname)
                            .font(Font.custom("SpaceGrotesk-Bold", size:Styling.rRheight / 50 * 18))
                            .foregroundColor(AppColors.customGray)
                            .padding(.horizontal,30)
                            .textContentType(.none)
                            .autocapitalization(.none)
                        Styling.customRectangle(
                            cornerRadius: Styling.rRheight / 2.3,
                            lineWidth: 2,
                            height: Styling.rRheight,
                            highOpacity: Styling.gradientOpacityHigh,
                            lowOpacity: Styling.gradientOpacityLow
                        )
                        
                            .padding(.horizontal)
                        if let errorMessage = errorMessage {
                                        Text(errorMessage)
                                            .foregroundColor(.red)
                                    }
                    }
                    
                    Spacer()
                    
                    // ZStack of Confirm Button
                    ZStack {
                        Button(action: {
                            savePrefName()
                        }) {
                            NavigationLink(destination: BirthdayScreen().navigationBarBackButtonHidden(), isActive: $navigateToBirthdayView) {EmptyView()}

                           // NavigationLink(destination:BirthdayView().navigationBarBackButtonHidden()){
                                Text("Confirm")
                                    .font(Font.custom("SpaceGrotesk-Bold", size:Styling.rRheight / 50 * 18))
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .foregroundColor(.white) // Beyaz arka plan üzerinde siyah yazı
                                    .padding()
                                    .background(AppColors.customGray) // Beyaz buton
                                    .textContentType(.none)
                                    .autocapitalization(.none)
                                    .cornerRadius(Styling.rRheight / 2.3)
                                                          //  }
                                .padding(.horizontal)
                        }
                    }//ZStack of confirm button bracket
                    
                    
                    
                }//VStack bracket
            }//ZStack for black background bracket
        }//NavigationView bracket
    }//Body bracket
    func savePrefName() {
            if prefname.isEmpty {
                errorMessage = "Preferred name cannot be empty"
            } else {
                userData.prefname = prefname
                navigateToBirthdayView = true
            }
        }
    
    
}//UsernameScreen bracket

struct UsernameScreen_Previews: PreviewProvider {
    static var previews: some View {
        UsernameScreen()
            .environmentObject(UserData())
    }
}
