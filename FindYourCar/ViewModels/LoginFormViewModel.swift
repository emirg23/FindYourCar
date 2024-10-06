
import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class LoginFormViewModel: ObservableObject {
    @Published var logInStateAnnouncer: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading = false
    @Published var enteredFalseValue = false
    @Published var enteredTrueValue = false
    @Published var directlyLogin = false
    @Published var auth = Auth.auth()
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
    
    func authenticateUser(email: String, password: String) {
        isLoading = true
        
        if !isValidEmail(email) { // doing this because i didn't like auths email validiation check
            logInStateAnnouncer = "This is not a valid email"
            EnteredFalseValue()
            isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        var emailsRegistered: [String] = []
        
        db.collection("users").getDocuments { (querySnapshot, error) in
            
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    let email = document.documentID
                    emailsRegistered.append(email)
                }
            }
            if !emailsRegistered.contains(email) { // doing this because .userNotFound didn't work as i expected
                self.logInStateAnnouncer = "No account found with this email"
                self.EnteredFalseValue()
                self.isLoading = false
                return
            }
            
            
            
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error as NSError? {
                    
                    let errorCode = AuthErrorCode(rawValue: error.code)

                    if errorCode == .invalidCredential { // doing this instead of .wrongPassword
                        self.logInStateAnnouncer = "Incorrect password"
                    } else if errorCode == .networkError {
                        self.logInStateAnnouncer = "Service unavailable."
                    } else {
                        self.logInStateAnnouncer = "Something went wrong. Please try again"
                    }
                    self.EnteredFalseValue()
                }
                
                if let _ = authResult {
                    self.logInStateAnnouncer = "Logged in successfully!"
                    withAnimation(.easeOut(duration: 0.3)) {
                        self.enteredTrueValue = true
                    }
                    
                    
                    let currentUsers = Firestore.firestore().collection("users").document(self.auth.currentUser!.email!)
                    currentUsers.getDocument { (cUSnapshot, errorr) in
                        guard let userSs = cUSnapshot, errorr == nil else {
                            return
                        }
                        
                        guard let userData = userSs.data() else {
                            return
                        }
                        
                        let name = userData["name"] as! String
                        let phoneNumber = userData["phone number"] as! String
                        
                        if name != "" && phoneNumber != "" {
                            self.directlyLogin = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.isLoggedIn = true
                        }
                    }

                    
                    
                    
                    
                    
                }
                self.isLoading = false
            }
        }
    }
    
    func EnteredFalseValue() -> Void {
        withAnimation(.easeOut (duration: 0.2)){
            self.enteredFalseValue = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut (duration: 0.2)){
                self.enteredFalseValue = false
            }
        }
    }

}
