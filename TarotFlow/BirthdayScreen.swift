
import Firebase
import FirebaseAuth
import SwiftUI

struct BirthdayScreen: View{
    @State private var birthDate: Date = Date()
    @EnvironmentObject var userData: UserData
    @State private var errorMessage: String? = nil
    @State private var navigateToHomePageScreen = false
    
    var body: some View{
        NavigationView {
            ZStack{//ZStack for background color
                AppColors.newBackground.ignoresSafeArea()
                //Title
                
                VStack{//VStack general
                    Text("Date of Birth")
                        .foregroundColor(AppColors.customGray)
                        .font(.system(size:Styling.rRheight/5*3))
                        .padding(.horizontal)
                        .padding()
                    Text("Date is important for determining your sun sign, numerology, and compatilibity.")
                        .foregroundColor(AppColors.customGray)
                        .font(.system(size:Styling.rRheight/6*2))
                        .padding(.horizontal)
                    
                    
                    Spacer()
                    
                    DatePicker("",
                               selection: $birthDate,
                               displayedComponents: [.date]
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    
                    if let errorMessage = errorMessage {
                                    Text(errorMessage)
                                        .foregroundColor(.red)
                                }
                    
                    Spacer()
                        
                    ZStack{
                        Button(action: {
                            saveBirthDateAndComplete()
                            
                        }) {
                            
                           
                                Text("Confirm")
                                    .font(.system(size:Styling.rRheight/50*18))
                                    .frame(minWidth:0,maxWidth:.infinity)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(AppColors.customGray)
                                    .cornerRadius(Styling.rRheight/2.3)
                                    .padding(.horizontal)
                           
                         
                                    .padding(.horizontal)
                            NavigationLink(destination: TabViewPage().navigationBarBackButtonHidden(), isActive: $navigateToHomePageScreen) {
                                EmptyView() // Bu NavigationLink sadece login başarılı olursa yönlendirecek
                            }
                        }//Text for button bracket
                        
                    }//ZStack for confirm button bracket
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                }//VStack general bracket
                
            }// ZStack for Background Bracket
        }//NavigationView bracket
    }//Bracket for Body
    func saveBirthDateAndComplete() {
            if birthDate > Date() {
                errorMessage = "Birthday cannot be in the future"
            } else {
                userData.birthDate = birthDate
                completeSignUp()
                print("kayit basarili")
                navigateToHomePageScreen = true
                
            }
        }
    func completeSignUp() {
            guard let user = Auth.auth().currentUser else {
                errorMessage = "No authenticated user found"
                return
            }

            let db = Database.database().reference()
            let userRef = db.child("users").child(user.uid)
            
            userData.lastLogin = ISO8601DateFormatter().string(from: Date())
            userData.verified = false
            userData.premium = false
            
            userRef.setValue(userData.toFirebaseData()) { error, _ in
                if let error = error {
                    errorMessage = "Error saving user data: \(error.localizedDescription)"
                } else {
                    userData.isSignUpComplete = true
                    // Navigate to the main app view or home page
                                   }
            }
        }
    
        

}//Bracket for BirthdayScreen

struct BirthdayScreen_Previews: PreviewProvider {
    static var previews: some View {
        BirthdayScreen()
            .environmentObject(UserData())
    }
}
