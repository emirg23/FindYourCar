
import SwiftUI

struct LeadToRegisterView: View {

    
    var body: some View {
        
        VStack{
            Spacer()
            
            Text("Don't have an account?")
                .foregroundStyle(.black)
                .font(.system (size: 20,design: .monospaced))
            
            NavigationLink(destination: RegisterView()){
                Text("Create one")
                    .font(.system (size: 25,design: .monospaced))
                    .foregroundStyle(.blue)
            }
            Spacer()
        }
    }
}

#Preview {
    LeadToRegisterView()
}
