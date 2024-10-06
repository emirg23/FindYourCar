
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProfileInfoView: View {
    @ObservedObject var vM = ProfileInfoViewModel()
    
    var body: some View {
        
        NavigationView {
            
            VStack{
                ZStack{
                    Color(.purple)
                    VStack{
                        Text(vM.displayedText)
                            .font(.system(size: 40, design: .monospaced))
                            .offset(y:55)
                            .fixedSize(horizontal: false, vertical: true)
                            .onAppear {
                                vM.startWritingEffect()
                            }
                            .foregroundStyle(.white)
                            .frame(width: UIScreen.main.bounds.width, height: 140, alignment: .leading)
                            .padding(.leading, 20)
                            .multilineTextAlignment(.leading)
                    }
                    
                }
                .frame(width:UIScreen.main.bounds.width, height: 200, alignment: .top)
                .cornerRadius(10)
                .position(x:UIScreen.main.bounds.width/2, y:0)
                
                if vM.textFullyDisplayed {
                    
                    ChangeEmailView(vM: vM)
                        .opacity(vM.openPasswordChange ? 0 : 1)
                        .offset(y: vM.emailChangeHighlighted ? UIScreen.main.bounds.width * 0.65 : UIScreen.main.bounds.width * 0.4)
                    
                    ChangePasswordView(vM: vM)
                    
                    goListingsView(navigate: $vM.navigate)
                    
                }
                
                NavigationLink(destination: ListingsView(vM: ListingsViewModel(ListingItems: vM.temporaryVm.usersListings), selectedView: .constant(2)).navigationBarBackButtonHidden(true), isActive: $vM.navigate) {
                    EmptyView()
                }
            }
            .onAppear() {
                vM.actualEmail = Auth.auth().currentUser!.email!
                vM.findUsersListings()
            }
            .foregroundColor(.white)
            .background(vM.backgroundColor)
        }
    }
}

#Preview {
    ProfileInfoView()
}

struct goListingsView: View {
    @Binding var navigate: Bool
    var body: some View {
        Button {
            navigate = true
        } label: {
            Text("Go to your listings")
                .foregroundStyle(.black)
                .font(.system(size: 20, design: .monospaced))
        }
        .offset(y: -UIScreen.main.bounds.width * 1.25)
    }
}
