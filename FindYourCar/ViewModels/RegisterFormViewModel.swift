
import Foundation
import FirebaseAuth
import SwiftUI
import FirebaseFirestore

class RegisterFormViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password1: String = ""
    @Published var password2: String = ""
    @Published var registerStateAnnouncer: String = ""
    @Published var registered: Bool
    @Published var isLoading = false
    @Published var enteredInvalidValue = false
    @Published var enteredTrueValue = false
    
    init(email: String = "", password1: String
         = "", password2: String = "", registerStateAnnouncer: String = "", registered: Bool = false, isLoading: Bool = false, enteredInvalidValue: Bool = false, enteredTrueValue: Bool = false) {
        self.email = email
        self.password1 = password1
        self.password2 = password2
        self.registerStateAnnouncer = registerStateAnnouncer
        self.registered = registered
        self.isLoading = isLoading
        self.enteredInvalidValue = enteredInvalidValue
        self.enteredTrueValue = enteredTrueValue
    }
    
    func registerUser(email: String, password: String) -> Void {
        isLoading = true
        
        let db = Firestore.firestore()
        let userCollection = db.collection("users")
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                let errorCode = AuthErrorCode(rawValue: error.code)
                
                if errorCode == .emailAlreadyInUse {
                    self.registerStateAnnouncer = "This email is already registered"
                } else if errorCode == .networkError {
                    self.registerStateAnnouncer = "Service unavailable"
                } else if errorCode == .invalidEmail {
                    self.registerStateAnnouncer = "This is not a valid email"
                } else {
                    self.registerStateAnnouncer = "Something went wrong. Please try again"
                }
                self.EnteredInvalidValue()
                
            } else {
                
                self.registerStateAnnouncer = "Registered successfully!"
                
                userCollection.document(email).setData(["name": "", "phone number": "", "listing number": 0])
                
                
                withAnimation(.easeOut(duration: 0.3)) {
                    self.enteredTrueValue = true
                }
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.registered = self.registerStateAnnouncer == "Registered successfully!"
            }
            self.isLoading = false
        }
    }
    
    
    func EnteredInvalidValue() -> Void {
        withAnimation(.easeOut (duration: 0.2)){
            self.enteredInvalidValue = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut (duration: 0.2)){
                self.enteredInvalidValue = false
            }
        }
    }
}
