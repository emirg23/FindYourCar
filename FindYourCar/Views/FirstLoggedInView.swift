
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct FirstLoggedInView: View {
    @State private var animateWelcome = false
    @State private var animateNameField = false
    @State private var animateNumField = false
    @State private var nameInputting = false
    @State private var numInputting = false
    @State var userName: String = ""
    @State var number: String = ""
    @State var bothInputted = false
    @State var numAlertTextOpacity: Double = 0
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNumFocused: Bool
    @State var navigate = false
    
    var body: some View {
        VStack{
            
            Text("Let us know your")
                .font(.system(size: 35, design: .monospaced))
                .foregroundStyle(.black)
                .offset(y: -100)
                .opacity(animateWelcome && (!nameInputting && !numInputting) ? 1 : 0)
                .frame(width: UIScreen.main.bounds.width)
                .onAppear {
                    withAnimation(.easeOut(duration: 2)){
                        animateWelcome = true
                    }
                }
            
            Text("phone number length has to be 10")
                .foregroundStyle(Color(red: 90/255, green: 90/255, blue: 90/255))
                .font(.system(size: 20, design: .monospaced))
                .multilineTextAlignment(.center)
                .opacity(numInputting ? 1 : 0)
                .offset(y: -100)
            
            DynamicInputFieldView(inputting: $nameInputting, value: $userName, animate: $animateNameField)
                .offset(y: nameInputting ? -100 : -50)
                .opacity(numInputting ? 0 : 1)
                .focused($isNameFocused)
                .disabled(numInputting)
                .submitLabel(.done)
                .onChange(of: userName) {
                    if userName == "" || number == "" || nameInputting || numInputting {
                        bothInputted = false
                    }
                }
            
            DynamicInputFieldView(inputting: $numInputting, value: $number, animate: $animateNumField, fieldText: "phone number", onlyNumber: true)
                .offset(y: numInputting ? -50 : 0)
                .opacity(nameInputting ? 0 : 1)
                .focused($isNumFocused)
                .disabled(nameInputting)
                .submitLabel(.done)
                .onChange(of: number) {
                    if userName == "" || number == "" || nameInputting || numInputting {
                        bothInputted = false
                    }
                }
            
            ConfirmButtonView(number: $number, userName: $userName, bothInputted: $bothInputted, numInputting: $numInputting, nameInputting: $nameInputting, navigate: $navigate)
            
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(nameInputting || numInputting ? Color(red: 150/255, green: 150/255, blue: 150/255):Color(red: 200/255, green: 200/255, blue: 200/255))
        
        NavigationLink(destination: WelcomeView().navigationBarBackButtonHidden(true), isActive: $navigate){
            EmptyView()
        }
    }
}

#Preview {
    FirstLoggedInView()
}


struct ConfirmButtonView: View {
    @Binding var number: String
    @Binding var userName: String
    @Binding var bothInputted: Bool
    @Binding var numInputting: Bool
    @Binding var nameInputting: Bool
    @Binding var navigate: Bool
    @State var gotInformation = false
    @State var user = Auth.auth().currentUser
    @State var numberBeingUsed = false

    var shouldVerify: Bool {
        return bothInputted && !nameInputting && !numInputting && !userName.isEmpty && !number.isEmpty
    }
    
    var buttonText: String {
        if numberBeingUsed {
            return "Number is already in use"
        } else if shouldVerify {
            return "Confirm details"
        } else if nameInputting {
            return "My first name is \(userName.trimmingCharacters(in: .whitespacesAndNewlines))"
        } else if numInputting {
            return "My phone number is \(number)"
        } else {
            return "Confirm details"
        }
    }
    
    var body: some View {
        Button{
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // closing keyboard
            
            if userName != "" && number != ""{
                bothInputted = true
            }
            if buttonText == "Confirm details" { // confirming details
                
                let db = Firestore.firestore()
                let userCollection = db.collection("users")
                
                userCollection.getDocuments { (querySnapshot, error) in
                    if let error = error {
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        return
                    }
                    
                    for document in documents {
                        
                        if let phoneNumberData = document.data()["phone number"], phoneNumberData as! String == number {
                            withAnimation(.easeInOut(duration: 0.23)) {
                                numberBeingUsed = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.723) {
                                withAnimation(.easeInOut(duration: 0.23)) {
                                    numberBeingUsed = false
                                }
                            }
                        }
                        
                    }
                    if !numberBeingUsed {
                        userCollection.document(user!.email!).updateData([
                            "name": userName.trimmingCharacters(in: .whitespacesAndNewlines).capitalized,
                            "phone number": number
                        ])
                        
                        
                        withAnimation(.easeInOut(duration: 0.23)) {
                            gotInformation = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.723) {
                            navigate = true
                        }
                    }
                }
                
                
                
            }
            withAnimation(.bouncy(duration: 0.5)) {
                if nameInputting {
                    nameInputting = false
                } else {
                    numInputting = false
                }
            }
            
        } label: {
            ZStack {
                Text(buttonText)
                    .font(.system(size: 20, design: .monospaced))
                    .foregroundStyle(Color(red: 200/255, green: 200/255, blue: 200/255))
            }
            .padding(.horizontal)
            .frame(width: 350, height: 50)
            .background(numberBeingUsed ? .red : (bothInputted && !(nameInputting || numInputting) ? .black : .blue))
            .cornerRadius(8)
        }
        .offset(y: 100)
        .opacity( !gotInformation && bothInputted || (nameInputting || numInputting) ? 1 : 0)
        .disabled(number.count != 10  && numInputting ? true : false)
    }
}
