
import SwiftUI
import FirebaseAuth

struct ChangePasswordView: View {
    @ObservedObject var vM: ProfileInfoViewModel
    
    var body: some View {
        if vM.openPasswordChange {
            VStack(alignment: .leading, spacing: 0){
                HStack{
                    Button {
                        vM.passwordArray[0] = ""
                        vM.passwordArray[1] = ""
                        vM.passwordArray[2] = ""
                        withAnimation(.snappy(duration: 0.75)) {
                            vM.openPasswordChange = false
                        }
                    } label: {
                        Text("Change password")
                            .padding(5)
                            .padding(.vertical, 3)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                }
                .background(vM.blackTone)
                
                HStack{
                    SecureField("Current Password", text: $vM.passwordArray[0])
                        .padding(5)
                        .padding(.vertical, 3)
                        .foregroundColor(.black)
                        .onChange(of: vM.passwordArray[0]) {
                            if !vM.passwordArray.contains("") {
                                withAnimation(.snappy(duration: 0.5)) {
                                    vM.passwordButton = true
                                }
                            } else {
                                withAnimation(.snappy(duration: 0.5)) {
                                    vM.passwordButton = false
                                }
                            }
                            if vM.passwordArray.allSatisfy({ $0 == "" }) {
                                withAnimation(.snappy(duration: 0.75)) {
                                    vM.openPasswordChange = false
                                }
                            }
                        }
                }
                
                HStack{
                    SecureField("New Password", text: $vM.passwordArray[1])
                        .padding(5)
                        .padding(.vertical, 3)
                        .foregroundColor(.black)
                        .onChange(of: vM.passwordArray[1]) {
                            if !vM.passwordArray.contains("") {
                                withAnimation(.snappy(duration: 0.5)) {
                                    vM.passwordButton = true
                                }
                            } else {
                                withAnimation(.snappy(duration: 0.5)) {
                                    vM.passwordButton = false
                                }
                            }
                            if vM.passwordArray.allSatisfy({ $0 == "" }) {
                                withAnimation(.snappy(duration: 0.75)) {
                                    vM.openPasswordChange = false
                                }
                            }
                        }
                }
                HStack{
                    SecureField("New Password again", text: $vM.passwordArray[2])
                        .padding(5)
                        .padding(.vertical, 3)
                        .foregroundColor(.black)
                        .onChange(of: vM.passwordArray[2]) {
                            if !vM.passwordArray.contains("") {
                                withAnimation(.snappy(duration: 0.5)) {
                                    vM.passwordButton = true
                                }
                            } else {
                                withAnimation(.snappy(duration: 0.5)) {
                                    vM.passwordButton = false
                                }
                            }
                            
                            if vM.passwordArray.allSatisfy({ $0 == "" }) {
                                withAnimation(.snappy(duration: 0.75)) {
                                    vM.openPasswordChange = false
                                }
                            }
                            
                        }
                }
                if vM.passwordButton {
                    Button {
                        vM.changePassword()
                    } label: {
                        if vM.loading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                        } else {
                            Text(vM.passwordChangeText)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .frame(height: 30)
                    .background(vM.passwordChangeText == "Confirm change" ? vM.blackTone : (vM.passwordChangeText == "Password changed" ? .green : .red))
                }
                    
                    
            }
            .opacity(vM.emailChangeHighlighted ? 0 : 1)
            .font(.system(size: 15, design: .monospaced))
            .background(.gray.opacity(0.6))
            .cornerRadius(10)
            .frame(width: UIScreen.main.bounds.width * 0.6, height: 100)
            .offset(y: vM.openPasswordChange ? -UIScreen.main.bounds.width * 0.6 : -UIScreen.main.bounds.width * 0.3)

            
        } else {
            Button {
                withAnimation(.snappy(duration: 0.75)) {
                    vM.openPasswordChange = true
                }
            } label: {
                    Text("Change your password?")
                        .foregroundStyle(.black)
                        .font(.system(size: 20, design: .monospaced))
                        .frame(width: 260)
            }
            .opacity(vM.emailChangeHighlighted ? 0 : 1)
            .frame(width: UIScreen.main.bounds.width * 0.6, height: 100)
            .offset(y: vM.openPasswordChange ? -UIScreen.main.bounds.width * 0.65 : -UIScreen.main.bounds.width * 0.35)
            .onAppear() {
                vM.actualEmail = Auth.auth().currentUser!.email!
            }
        }
    }

}

#Preview {
    ChangePasswordView(vM: ProfileInfoViewModel())
}
