
import SwiftUI

struct RegisterView: View {
    @State var registered: Bool = false
    var body: some View {
        
            VStack{

                CircleTopView(text:"Your\nInformation", backgroundColor: Color(red: 200/255, green: 95/255, blue: 0), reversed: true)
                    
                
                RegisterFormView(vM: RegisterFormViewModel(registered: registered))
                    .offset(y: -UIScreen.main.bounds.width/4.5)
                    .padding()
                
                BackButtonView()
                    
            }
            .navigationBarBackButtonHidden(true)
            .background(Color(red: 200/255, green: 200/255, blue: 200/255))
    }
    
}

#Preview {
    RegisterView()
}


