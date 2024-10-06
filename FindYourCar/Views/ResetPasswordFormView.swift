
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ResetPasswordFormView: View {
    
    @State var email: String = ""
    @State var resetStateAnnouncer: String = ""
    @State var isLoading = false
    @State var enteredInvalidValue = false
    @State var enteredTrueValue = false
    @State var mailSent = false
    @State var emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    var body: some View {
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        VStack {
            Spacer()
            Text(resetStateAnnouncer)
                .font(.system(size: 18, design: .monospaced))
                .foregroundStyle(resetStateAnnouncer == "Recovery email has been sent" ? .green : .red)
                .multilineTextAlignment(.center)
                .frame(height: 48)
            
            Form {
                Text("Your email:")
                    .padding(5)
                    .font(.system(size: 20, design: .monospaced))
                    .foregroundStyle(.black)
                
                TextField("email", text: $email)
                    .padding(7)
                    .font(.system(size: 20, design: .monospaced))
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .background(Color(red: 190/255, green: 190/255, blue: 190/255))
                    .foregroundStyle(.black)
                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // closing keyboard

                    if email.trimmingCharacters(in: .whitespaces) == "" {
                        resetStateAnnouncer = "Please fill in all fields"
                        EnteredInvalidValue()
                        return
                    }
                    
                    guard emailPredicate.evaluate(with: email) else {
                        resetStateAnnouncer = "Invalid email format"
                        EnteredInvalidValue()
                        return
                    }
                    
                    isLoading = true
                    
                    let db = Firestore.firestore()
                    let userCollection = db.collection("users")
                    
                    var emailsRegistered: [String] = []
                    
                    userCollection.getDocuments { querySnapshot, error in

                    for document in querySnapshot!.documents {
                        emailsRegistered.append(document.documentID)
                    }
                                                    

                        if emailsRegistered.contains(email.lowercased()) {
                            Auth.auth().sendPasswordReset(withEmail: email) { error in
                                if let error = error {
                                    resetStateAnnouncer = "Failed to send recovery email: \(error.localizedDescription)"
                                    EnteredInvalidValue()
                                    
                                } else {
                                    resetStateAnnouncer = "Recovery email has been sent"
                                    
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        enteredTrueValue = true
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        mailSent = true
                                    }
                                    isLoading = false
                                }
                            }
                        } else {
                            EnteredInvalidValue()
                            resetStateAnnouncer = "No account found with this email"
                        }
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .font(.system(size: 20, design: .monospaced))
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(width: UIScreen.main.bounds.width, height: 50)
                            .background(.black)
                    } else {
                        Text(enteredInvalidValue ? "✕" : (enteredTrueValue ? "✔" : "Send Recovery Email"))
                            .font(.system(size: (enteredInvalidValue || enteredTrueValue) ? 40 : 20, design: .monospaced))
                            .foregroundStyle(.white)
                            .frame(width: UIScreen.main.bounds.width, height: 50)
                            .background(enteredInvalidValue ? Color(.red) : (enteredTrueValue ? Color(.green) : Color(.black)))
                    }
                }
                .offset(y: -8)
                .disabled(isLoading)
            }
            .frame(height: 125)
            .cornerRadius(15)
            .formStyle(ColumnsFormStyle())
            Spacer()
        }
        NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true), isActive: $mailSent) {
            EmptyView()
        }
    }
    
    func EnteredInvalidValue() -> Void {
        withAnimation(.easeOut (duration: 0.2)){
            enteredInvalidValue = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut (duration: 0.2)){
                enteredInvalidValue = false
            }
        }
        isLoading = false
    }
}

#Preview {
    ResetPasswordFormView()
}
