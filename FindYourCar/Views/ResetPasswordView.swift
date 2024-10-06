
import SwiftUI

struct ResetPasswordView: View {
    @State var mailSent = false
    var body: some View {
        VStack{
            CircleTopView(text: "Reset your\npassword", backgroundColor: .black, foregroundColor: .white, reversed: true)
            
            ResetPasswordFormView()
                .offset(y: -90)
            
            BackButtonView(black: false)
        }
        .background(.white)
        
    }
}

#Preview {
    ResetPasswordView()
}
