
import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct LoginFormView: View {
    @ObservedObject var vM = LoginFormViewModel()

    var body: some View {

        Text(vM.logInStateAnnouncer)
            .foregroundStyle(vM.logInStateAnnouncer == "Logged in successfully!" ? .green : .red)
            .font(.system (size: 20, design: .monospaced))
            .multilineTextAlignment(.center)
            .frame(height: 48)
        
        Form {
            Spacer()
            TextField("Email", text: $vM.email)
                .padding(10)
                .font(.system (size: 20, design: .monospaced))
                .autocapitalization(.none)
                .autocorrectionDisabled(true)
                .frame(width: UIScreen.main.bounds.width, height: 70)
                .foregroundStyle(.black)
                .background(Color(red: 160/255, green: 160/255, blue: 160/255))
                .offset(y: 8)
            
            SecureField("Password", text: $vM.password)
                .padding(10)
                .font(.system (size: 20, design: .monospaced))
                .frame(width: UIScreen.main.bounds.width, height: 70)
                .foregroundStyle(.black)
                .background(Color(red: 160/255, green: 160/255, blue: 160/255))
            
            Spacer()
            
            Button{
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // closing keyboard
                
                if vM.email.trimmingCharacters(in: .whitespaces) != "" &&
                    vM.password != "" {
                    vM.authenticateUser(email: vM.email.lowercased(), password: vM.password)
                    
                } else {
                    vM.EnteredFalseValue()
                    vM.logInStateAnnouncer = "Please fill in all fields"
                }
            } label: {
                ZStack {
                    if vM.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        
                        Text(vM.enteredFalseValue ? "✕" : (vM.enteredTrueValue ? "✔" : "Log in"))
                            .font(.system (size: (vM.enteredFalseValue || vM.enteredTrueValue) ? 40 : 20, design: .monospaced))
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: 20)
                .padding()
                .background(vM.enteredFalseValue ? Color(.red) :
                                (vM.enteredTrueValue ? Color(.green) :
                                    Color(red: 0, green: 0, blue: 150/255))
                )
                .foregroundColor(.white)
            }
            .cornerRadius(10)
            .frame(width: UIScreen.main.bounds.width, height: 20)
            .offset(y: 0)
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width, height:230)
        .cornerRadius(10)
        .formStyle(ColumnsFormStyle())
        
        if vM.directlyLogin{
            NavigationLink("", destination: WelcomeView().navigationBarBackButtonHidden(true), isActive: $vM.isLoggedIn)
        } else {
            NavigationLink("", destination: FirstLoggedInView().navigationBarBackButtonHidden(true), isActive: $vM.isLoggedIn)
        }
    }
}

#Preview {
    LoginFormView()

}
