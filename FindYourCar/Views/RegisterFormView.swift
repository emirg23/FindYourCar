
import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct RegisterFormView: View {
    @ObservedObject var vM: RegisterFormViewModel
    var body: some View {
        
        VStack{
            Spacer()
            
            Text(vM.registerStateAnnouncer)
                .font(.system(size: 18, design: .monospaced))
                .foregroundStyle(vM.registerStateAnnouncer == "Registered successfully!" ? .green : .red)
                .multilineTextAlignment(.center)
                .frame(height: 48)
            
            Form{
                Text("Your email:")
                    .padding(5)
                    .font(.system(size: 20, design: .monospaced))
                    .foregroundStyle(.black)
                
                TextField("email", text: $vM.email)
                    .padding(7)
                    .font(.system(size: 17, design: .monospaced))
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .background(Color(red: 190/255, green: 190/255, blue: 190/255))
                    .foregroundStyle(.black)
                    .frame(width: UIScreen.main.bounds.width)
                
                Text("Your password:")
                    .padding(5)
                    .font(.system(size: 20, design: .monospaced))
                    .foregroundStyle(.black)

                
                SecureField("password", text: $vM.password1)
                    .padding(7)
                    .font(.system(size: 17, design: .monospaced))
                    .textContentType(.none)
                    .background(Color(red: 190/255, green: 190/255, blue: 190/255))
                    .foregroundStyle(.black)
                    .frame(width: UIScreen.main.bounds.width)

                Text("Password again:")
                    .padding(5)
                    .font(.system(size: 20, design: .monospaced))
                    .foregroundStyle(.black)

                SecureField("password again", text: $vM.password2)
                    .padding(7)
                    .font(.system(size: 17, design: .monospaced))
                    .textContentType(.none)
                    .background(Color(red: 190/255, green: 190/255, blue: 190/255))
                    .foregroundStyle(.black)
                    .frame(width: UIScreen.main.bounds.width)

                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // closing keyboard
                    if vM.email.trimmingCharacters(in: .whitespaces) != "" &&
                        vM.password1 != "" &&
                        vM.password2 != "" {
                        if vM.password1 == vM.password2 {
                            if vM.password1.trimmingCharacters(in: .whitespaces).count >= 5 {
                                
                                vM.registerUser(email: vM.email.lowercased(), password: vM.password1)
                                
                            } else {
                                vM.EnteredInvalidValue()
                                vM.registerStateAnnouncer = "Your password must be at least 6 characters long"
                            }
                        } else {
                            vM.EnteredInvalidValue()
                            vM.registerStateAnnouncer = "Passwords are different"
                        }
                    } else {
                        vM.EnteredInvalidValue()
                        vM.registerStateAnnouncer = "Please fill in all fields"
                    }
                    

                } label: {
                    if vM.isLoading {
                        ProgressView()
                            .font(.system(size: 20, design: .monospaced))
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(width: UIScreen.main.bounds.width, height: 50)
                            .background(Color(red: 230/255, green: 125/255, blue: 0))
                    } else {
                        Text(vM.enteredInvalidValue ? "✕" : (vM.enteredTrueValue ? "✔" : "Register"))
                            .font(.system (size: (vM.enteredInvalidValue || vM.enteredTrueValue) ? 40 : 20, design: .monospaced))
                            .foregroundStyle(Color(red: 200/255, green: 200/255, blue: 200/255))
                            .frame(width: UIScreen.main.bounds.width, height: 50)
                            .background(vM.enteredInvalidValue ? Color(.red) :
                                            (vM.enteredTrueValue ? Color(.green) :
                                Color(red: 200/255, green: 95/255, blue: 0))
                            )
                    }
                }
                .offset(y: -8)
                .disabled(vM.isLoading)
                
                NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true), isActive: $vM.registered) {
                    EmptyView()
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: 291)
            .cornerRadius(15)
            .formStyle(ColumnsFormStyle())
                Spacer()
        }
    }
}

#Preview {
    RegisterFormView(vM: RegisterFormViewModel())
}
