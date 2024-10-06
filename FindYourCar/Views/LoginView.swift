
import SwiftUI

struct LoginView: View {
    @State var isLoggedIn: Bool = false
    
    var body: some View {
        NavigationView{
            VStack {
                CircleTopView()
                
                LoginFormView()
                
                NavigationLink("Forgot your password?", destination: ResetPasswordView().navigationBarBackButtonHidden(true))
                    .font(.system(size: 20, design: .monospaced))
                    .offset(y: 23)
                
                LeadToRegisterView()
                    .offset(y: 37)
            }
            .background(Color(red: 200/255, green: 200/255, blue: 200/255))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
