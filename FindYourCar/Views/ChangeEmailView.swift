
import SwiftUI
import FirebaseAuth

struct ChangeEmailView: View {
    @ObservedObject var vM: ProfileInfoViewModel

    var body: some View {
        VStack{
            VStack(alignment: .leading, spacing: 0){
                HStack{
                    Button {
                        vM.inputtedEmail = vM.actualEmail
                    } label: {
                        Text("Your email:")
                            .padding(5)
                            .padding(.vertical, 3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .background(vM.blackTone)
                
                HStack{
                    TextField("Email", text: $vM.inputtedEmail)
                        .padding(5)
                        .padding(.vertical, 3)
                        .textInputAutocapitalization(.none)
                        .onChange(of: vM.inputtedEmail) {
                            withAnimation(.snappy(duration: 0.5)) {
                                vM.verificationSent = false
                                vM.revealButton = vM.actualEmail.lowercased() != vM.inputtedEmail.lowercased() &&
                                vM.inputtedEmail.contains("@") &&
                                vM.inputtedEmail.contains(".") &&
                                !vM.inputtedEmail.contains(" ")
                                vM.enterPassword = false
                            }
                            withAnimation(.snappy(duration: 1)) {
                                vM.emailChangeHighlighted = vM.revealButton && (vM.inputtedEmail != vM.actualEmail)
                            }
                        }

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.gray.opacity(0.6))
                .opacity(vM.revealButton || vM.verificationSent || vM.enterPassword ? 1 : 0.5)
                if vM.verificationSent {
                    HStack{
                        Button {
                            vM.checkEmailVerification()
                        } label: {
                            if vM.loading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(vM.wrongValueArray[2] ? "✕" : (vM.changedEmail ? "✔" : "I've verified my email"))
                                    .font(.system (size: vM.wrongValueArray[2] || vM.changedEmail ? 25 : 15, design: .monospaced))
                                
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .frame(height: 30)
                        .frame(maxWidth: .infinity)
                        .padding(5)
                        .padding(.vertical, 3)
                        .background(vM.wrongValueArray[2] ? .red : (vM.changedEmail ? .green : vM.blackTone))
                    }
                }
                if vM.enterPassword {
                    VStack(spacing: 0){
                        HStack{
                            SecureField("Password", text: $vM.password)
                                .padding(5)
                                .padding(.vertical, 3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.gray.opacity(0.6))
                        }
                        HStack{
                            Button {
                                vM.reauthenticateUser()
                            } label: {
                                if vM.loading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(vM.wrongValueArray[0] ? "✕" : (vM.rightPassword ? "✔" : "Confirm password"))
                                        .font(.system (size: vM.wrongValueArray[0] || vM.rightPassword ? 25 : 15, design: .monospaced))
                                    
                                }
                            }
                            .frame(height: 30)
                            .frame(maxWidth: .infinity)
                            .padding(5)
                            .padding(.vertical, 3)
                            .background(vM.wrongValueArray[0] ? .red : (vM.rightPassword ? .green : vM.blackTone))
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                if vM.revealButton {
                    HStack{
                        Button {
                            vM.checkEmail()
                        } label: {
                            if vM.loading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(vM.connectionProblem ? "Network problem" : (vM.wrongValueArray[1] ? "Already in use" : "Change email"))
                                    .font(.system (size: 15, design: .monospaced))
                                
                            }
                        }
                        .frame(height: 30)
                        .frame(maxWidth: .infinity)
                        .padding(5)
                        .padding(.vertical, 3)
                        .background(vM.wrongValueArray[1] ? .red : vM.blackTone)
                    }
                    
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                }
            }
            .font(.system(size: 15, design:.monospaced))
            .frame(width: UIScreen.main.bounds.width * 0.6, alignment: .topLeading)
            .cornerRadius(10)
        }
        .opacity(vM.openPasswordChange ? 0 : 1)
        .onAppear() {
            vM.actualEmail = Auth.auth().currentUser!.email!
            vM.inputtedEmail = vM.actualEmail
        }
        .offset(y: -UIScreen.main.bounds.width)
        .frame(height: 85, alignment: .top)
    }
}

#Preview {
    ChangeEmailView(vM: ProfileInfoViewModel())
}
