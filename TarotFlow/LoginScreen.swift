
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Lottie

struct AppColors {
    //static let customGray = Color(red: 49/255, green: 55/255, blue: 61/255) //orj
    static let backgroundGray = Color(red: 211/255, green: 210/255, blue: 210/255)
    static let customGray = Color(red: 60/255, green: 62/255, blue: 64/255)
    static let newBackground = Color(red: 212/255, green: 206/255, blue: 201/255)
}

struct LoginScreen: View {
    @StateObject private var userData = UserData()
    
    @State private var isLogInActive = true // Buton geçiş durumunu kontrol eder
//    @State private var username: String = ""
//    @State private var password: String = ""
//    @State private var email: String = ""
//    @State private var email2: String = ""
//    @State private var passwordRepeat: String = ""
//    @State private var signUpErrorMessage: String? = nil
//    @State private var loginErrorMessage: String? = nil
//    @State private var isLoginSuccessful = false
//    @State private var isSignUpSuccessful = false
    
    let animationSpeed: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            ZStack {
                
                
                LottieView(animation: .named("shootingStarWn"))
                    .playing(loopMode: .loop)
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    
                    Text("TarotFlow")
                        .foregroundColor(AppColors.customGray)
                        .bold()
                        .font(.system(size: Styling.rRheight / 5 * 3, weight: .heavy))
                        .padding(.horizontal)
                    
                    ZStack {
                        Styling.customRectangle(
                            cornerRadius: Styling.rRheight / 55 * 40,
                            lineWidth: 1.5,
                            height: Styling.rRheight / 5 * 6,
                            highOpacity: Styling.gradientOpacityHigh,
                            lowOpacity: Styling.gradientOpacityLow
                        )
                        
                        HStack(spacing: 0) {
                            Button(action: {
                                withAnimation {
                                    isLogInActive = true
                                    userData.signUpErrorMessage = nil
                                    userData.email = ""
                                    userData.password = ""
                                    userData.passwordRepeat = ""
                                }
                            }) {
                                Text("Log In")
                                    .font(.system(size: Styling.rRheight / 5 * 2))
                                    .foregroundColor(isLogInActive ? .white : AppColors.customGray)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight:0,maxHeight:Styling.rRheight/5*3)
                                    .padding(.vertical, Styling.rRheight / 50 * 10)
                            }
                            .background(isLogInActive ? AppColors.customGray : Color.clear)
                            .cornerRadius(Styling.rRheight / 55 * 40)
                            .padding(.horizontal, 5)
                            
                            Button(action: {
                                withAnimation {
                                    isLogInActive = false
                                    userData.loginErrorMessage = nil
                                    userData.email2 = ""
                                    userData.password = ""
                                }
                            }) {
                                Text("Sign Up")
                                    .font(.system(size: Styling.rRheight / 5 * 2))
                                    .foregroundColor(isLogInActive ? AppColors.customGray : .white)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight:0,maxHeight:Styling.rRheight/5*3)
                                    .padding(.vertical, Styling.rRheight / 50 * 10)
                            }
                            .background(isLogInActive ? Color.clear : AppColors.customGray)
                            .cornerRadius(Styling.rRheight / 5 * 4)
                            .padding(.horizontal, 5)
                        }
                    }
                    .padding(.horizontal,Styling.rRheight/50*20)
                    
                    VStack(spacing: 20) {
                        if isLogInActive{
                            Spacer()
                        }
                        else{
                            Spacer()
                        }
                        
                        if isLogInActive { //loginScreen
                            ZStack{
                                Styling.customRectangle(
                                    cornerRadius: Styling.rRheight / 2.3,
                                    lineWidth: 2,
                                    height: Styling.rRheight,
                                    highOpacity: Styling.gradientOpacityHigh,
                                    lowOpacity: Styling.gradientOpacityLow
                                        
                                ).padding(.horizontal,Styling.rRheight/50*10)
                                
                                TextField("E-mail", text: $userData.email2)
                                    .font(.system(size: Styling.rRheight / 50 * 18))
                                    .padding(.horizontal, 20)
                                    .foregroundColor(AppColors.customGray)
                                    .textContentType(.none)
                                    .autocapitalization(.none)
                            }
                            ZStack{
                                Styling.customRectangle(
                                    cornerRadius: Styling.rRheight / 2.3,
                                    lineWidth: 2,
                                    height: Styling.rRheight,
                                    highOpacity: Styling.gradientOpacityHigh,
                                    lowOpacity: Styling.gradientOpacityLow
                                ).padding(.horizontal,Styling.rRheight/50*10)
                                SecureField("Password", text: $userData.password)
                                    .font(.system(size: Styling.rRheight / 50 * 18))
                                    .padding(.horizontal, 20)
                                    .foregroundColor(AppColors.customGray)
                                    .textContentType(.none)
                                    .autocapitalization(.none)
                            }
//                            // Log In ekranındaki or separator ve diğer alanlar
//                            HStack {
//                                Rectangle()
//                                    .stroke(LinearGradient(
//                                        gradient: Gradient(colors: [
//                                            Color.gray.opacity(Styling.gradientOpacityHigh),
//                                            Color.gray.opacity(0.1)
//                                        ]),
//                                        startPoint: .topLeading,
//                                        endPoint: .bottomTrailing
//                                    ), lineWidth: 1)
//                                    .frame(height: 1)
//                                Text("or")
//                                    .foregroundColor(.gray)
//                                    .padding(.horizontal, 8)
//                                Rectangle()
//                                    .stroke(LinearGradient(
//                                        gradient: Gradient(colors: [
//                                            Color.gray.opacity(0.1),
//                                            Color.gray.opacity(Styling.gradientOpacityHigh)
//                                        ]),
//                                        startPoint: .topLeading,
//                                        endPoint: .bottomTrailing
//                                    ), lineWidth: 1)
//                                    .frame(height: 1)
//                            }
//                            .padding(.horizontal)
                            
//                            ZStack {
//                                
//                                    Button(action:{
//                                        //Signing with apple eylemi
//                                    }){
//                                        Styling.customRectangle(
//                                            cornerRadius: Styling.rRheight / 5,
//                                            lineWidth: 1,
//                                            height: Styling.rRheight,
//                                            highOpacity: Styling.gradientOpacityHigh,
//                                            lowOpacity: Styling.gradientOpacityLow
//                                        )
//                                        .overlay(
//                                            HStack {
//                                                //sign in with apple
//                                                Text("Sign in with Apple").font(Font.custom("SpaceGrotesk-Bold",size:Styling.rRheight/50*18))
//                                                    .foregroundColor(.white)
//                                                Image(systemName: "applelogo")
//                                                    .resizable(resizingMode: .stretch)
//                                                    .foregroundColor(.white)
//                                                    .frame(width: 28.0, height: 28.0)
//                                            } ) } }
                            
                            
//                            ZStack {
//                               
//                                    Button(action:{
//                                        //Signing with google eylemi
//                                    }){
//                                        Styling.customRectangle(
//                                            cornerRadius: Styling.rRheight / 5,
//                                            lineWidth: 1,
//                                            height: Styling.rRheight,
//                                            highOpacity: Styling.gradientOpacityHigh,
//                                            lowOpacity: Styling.gradientOpacityLow
//                                        )
//                                        .overlay(
//                                            HStack {
//                                                Text("Sign in with Google").font(Font.custom("SpaceGrotesk-Bold",size:Styling.rRheight/50*18))
//                                                
//                                                    .foregroundColor(.white)
//                                                Image("ios_light_rd_na")
//                                                    .resizable()
//                                                    .scaledToFit()
//                                                    .frame(width:35,height:40)
//                                            } ) }  }
                            Spacer()
                                Button(action: {
                                    userData.login()
                                }) {
                                    Text("Next")
                                        .font(.system(size: Styling.rRheight / 50 * 18))
                                        .foregroundColor(.white)
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .padding()
                                        .background(AppColors.customGray)
                                        .cornerRadius(Styling.rRheight / 2.3)
                                }
                                .padding(.horizontal)
                                
                            NavigationLink(destination: TabViewPage().navigationBarBackButtonHidden(), isActive: $userData.isLoginSuccessful) {
                                    EmptyView() // Bu NavigationLink sadece login başarılı olursa yönlendirecek
                                }
                            
                        
                            
                        } // loginScreen
                        
                        else { //signUpScreen
                            ZStack{
                                Styling.customRectangle(
                                    cornerRadius: Styling.rRheight / 2.3,
                                    lineWidth: 2,
                                    height: Styling.rRheight,
                                    highOpacity: Styling.gradientOpacityHigh,
                                    lowOpacity: Styling.gradientOpacityLow
                                ).padding(.horizontal,Styling.rRheight/50*10)
                                TextField("E-mail", text: $userData.email)
                                    .font(.system(size: Styling.rRheight / 50 * 18))
                                    .padding(.horizontal, 20)
                                    .foregroundColor(AppColors.customGray)
                                    .textContentType(.none)
                                    .autocapitalization(.none)
                            }
                            ZStack{
                                Styling.customRectangle(
                                    cornerRadius: Styling.rRheight / 2.3,
                                    lineWidth: 2,
                                    height: Styling.rRheight,
                                    highOpacity: Styling.gradientOpacityHigh,
                                    lowOpacity: Styling.gradientOpacityLow
                                ).padding(.horizontal,Styling.rRheight/50*10)
                                SecureField("Password", text: $userData.password)
                                    .font(.system(size: Styling.rRheight / 50 * 18))
                                    .padding(.horizontal, 20)
                                    .foregroundColor(AppColors.customGray)
                                    .textContentType(.none)
                                    .autocapitalization(.none)
                            }
                            ZStack{
                                Styling.customRectangle(
                                    cornerRadius: Styling.rRheight / 2.3,
                                    lineWidth: 2,
                                    height: Styling.rRheight,
                                    highOpacity: Styling.gradientOpacityHigh,
                                    lowOpacity: Styling.gradientOpacityLow
                                ).padding(.horizontal,Styling.rRheight/50*10)
                                SecureField("Repeat Password", text: $userData.passwordRepeat)
                                    .font(.system(size: Styling.rRheight / 50 * 18))
                                    .padding(.horizontal, 20)
                                    .foregroundColor(AppColors.customGray)
                                    .textContentType(.none)
                                    .autocapitalization(.none)
                            }
                            Spacer()
                            Button(action: {
                                userData.signUp()
                            }) {
                                Text("Sign Up")
                                    .font(.system(size: Styling.rRheight / 50 * 18))
                                    .foregroundColor(.white)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .padding()
                                    .background(AppColors.customGray)
                                    .cornerRadius(Styling.rRheight / 2.3)
                            }
                            
                            .padding(.horizontal)
                            NavigationLink(destination: UsernameScreen().navigationBarBackButtonHidden(), isActive: $userData.isSignUpSuccessful) {
                                EmptyView() // Bu NavigationLink sadece sign-up başarılı olursa yönlendirecek
                            }
                        } //signUpScreen
                        
                    } //VStack
                    .padding(.horizontal)
                    
                    
                    
                    if isLogInActive {
                        if let loginErrorMessage = userData.loginErrorMessage {
                            Text(loginErrorMessage)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                    } else {
                        if let signUpErrorMessage = userData.signUpErrorMessage {
                            Text(signUpErrorMessage)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    
                    }//General VStack
            }
        }//Navigation
        .environmentObject(userData)
    }//body
    
    
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
            .environmentObject(UserData())
    }
}
