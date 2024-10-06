
import Foundation
import FirebaseAuth
import SwiftUI
import FirebaseFirestore

class ProfileInfoViewModel: ObservableObject {
    @Published var textFullyDisplayed = false
    @Published var timer: Timer?
    @Published var currentIndex = 0
    @Published var displayedText = ""
    @Published var usersNumber = ""
    @Published var backgroundColor = Color(red: 200/255, green: 200/255, blue: 200/255)
    @Published var blackTone = Color(red: 50/255, green: 50/255, blue: 50/255)
    @Published var temporaryVm = ListingViewModel( selectedView: .constant(2))
    @Published var navigate = false
    @Published var actualEmail = ""
    @Published var inputtedEmail = ""
    @Published var emailChangeHighlighted = false
    @Published var successfulPasswordChange = false
    @Published var openPasswordChange = false
    @Published var revealButton = false
    @Published var enterPassword = false
    @Published var password = ""
    @Published var verificationSent = false
    @Published var loading = false
    @Published var wrongValueArray = [false, false, false]
    @Published var changedEmail = false
    @Published var rightPassword = false
    @Published var connectionProblem = false
    @Published var passwordArray: [String] = ["", "", ""]
    @Published var passwordButton = false
    @Published var passwordChangeText = "Confirm change"
    var selectedDisplayText = "EditYourProfile"
    
    func findUsersListings() {
        let auth = Auth.auth()
        
        let db = Firestore.firestore().collection("users").document(auth.currentUser!.email!)
        
        db.getDocument { (querySnapshot, error) in
            if let error = error {
                return
            }
            guard let qs = querySnapshot, let data = qs.data() else {
                return
            }
            
            self.usersNumber = "+90" + (data["phone number"] as! String)
            self.temporaryVm.getUsersListings(phoneNumber: self.usersNumber)
        }
        
    }
    
    func startWritingEffect() {
        let charDelay = Double.random(in: 0.05...0.18) // random between 0.02...0.1 so more realistic

        timer = Timer.scheduledTimer(withTimeInterval: charDelay, repeats: false) { _ in
            if self.currentIndex < self.selectedDisplayText.count {
                let currentCharacter = self.selectedDisplayText[self.selectedDisplayText.index(self.selectedDisplayText.startIndex, offsetBy: self.currentIndex)]
                
                self.displayedText.append(currentCharacter)
                
                self.currentIndex += 1
                
                self.startWritingEffect()
            } else {
                self.timer?.invalidate()
                self.timer = nil // to break out of the timer loop even if it do not execute anything
                withAnimation(.bouncy(duration: 1)) {
                    self.textFullyDisplayed = true
                }
            }
        }
    }
    
    func checkEmail() {
        loading = true
        let docRef = Firestore.firestore().collection("users").document(inputtedEmail.lowercased())
        docRef.getDocument { (document, error) in
            if let error = error {
                withAnimation(.snappy(duration: 0.2)) {
                    self.connectionProblem = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.snappy(duration: 0.2)) {
                        self.connectionProblem = false
                    }
                }
                self.wrongValue(wrong: 1)
                return
            }
            
            if let document = document, document.exists {
                self.wrongValue(wrong: 1)
                return
            } else {
                withAnimation(.snappy(duration: 0.5)) {
                    self.enterPassword = true
                    self.revealButton = false
                }
                self.loading = false
            }
            
        }
    }
    
    func checkEmailVerification() {
        loading = true
        guard let user = Auth.auth().currentUser else { return }
        
        user.reload { error in
            if let error = error {
                self.wrongValue(wrong: 2)
            } else {
                if user.isEmailVerified {
                    self.changeEmail()
                } else {
                    self.wrongValue(wrong: 2)
                }
            }
        }
    }
    
    func reauthenticateUser() {
        loading = true
        guard let user = Auth.auth().currentUser else { return }
        
        let credential = EmailAuthProvider.credential(withEmail: actualEmail, password: password)
        
        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                self.wrongValue(wrong: 0)
                return
                
            } else {
                withAnimation(.snappy(duration: 0.5)) {
                    self.loading = false
                    self.rightPassword = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.snappy(duration: 0.5)) {
                        self.enterPassword = false
                    }
                    self.sendVerificationEmail()
                    self.rightPassword = false
                }
            }
        }
    }
        
    func sendVerificationEmail() {
        withAnimation(.snappy(duration: 0.5)) {
            self.verificationSent = true
        }
        self.loading = true
        guard let user = Auth.auth().currentUser else { return }
        
        user.sendEmailVerification { error in
            if let error = error {
                self.wrongValue(wrong: 2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    withAnimation(.snappy(duration: 0.5)) {
                        self.verificationSent = false
                        self.inputtedEmail = self.actualEmail
                    }
                }
                
                return
            }
            
            withAnimation(.snappy(duration: 0.5)) {
                self.loading = false
            }
        }
    }

    
    func changeEmail() {
        let auth = Auth.auth()
        guard let user = auth.currentUser else { return }
        let oldEmail = auth.currentUser!.email!
        let newEmail = inputtedEmail.lowercased()
        let db = Firestore.firestore()
        let oldDocumentRef = db.collection("users").document(oldEmail)
        
        oldDocumentRef.getDocument { (querySnapshot, error) in
            if let error = error {
                self.wrongValue(wrong: 2)
                return
            }
            
            guard let data = querySnapshot?.data() else {
                self.wrongValue(wrong: 2)
                return
            }
            self.successfulChange()
            db.collection("users").document(newEmail).setData(data) { error in
                if let error = error {
                    self.wrongValue(wrong: 2)
                    return
                }

                oldDocumentRef.delete { error in
                    if let error = error {
                        self.wrongValue(wrong: 2)
                    }
                }
            }
        }
        
        auth.currentUser!.delete()

        auth.createUser(withEmail: newEmail, password: password)
        
        auth.signIn(withEmail: newEmail, password: password)
        
        
    }
    
    func wrongValue(wrong: Int) {

        withAnimation(.snappy(duration: 0.2)) {
            self.wrongValueArray[wrong] = true
        }
        self.loading = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.snappy(duration: 0.2)) {
                self.wrongValueArray[wrong] = false
            }
        }
    }
    
    func successfulChange() {
        self.actualEmail = Auth.auth().currentUser!.email!
        withAnimation(.snappy(duration: 0.5)) {
            self.loading = false
            self.changedEmail = true
        }
        withAnimation(.snappy(duration: 1)) {
            self.emailChangeHighlighted = self.revealButton && (self.inputtedEmail != self.actualEmail)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.snappy(duration: 0.5)) {
                self.verificationSent = false
                self.revealButton = false
                self.enterPassword = false
                self.changedEmail = false
            }
        }
    }
    
    
    func changePassword() {
        if self.passwordArray[1] == self.passwordArray[2] {
            if self.passwordArray[1].count > 5 {
                self.loading = true
                guard let user = Auth.auth().currentUser else { return }
                
                let credential = EmailAuthProvider.credential(withEmail: actualEmail, password: passwordArray[0])
                
                user.reauthenticate(with: credential) { result, error in
                    if let error = error {
                        self.textChange(text: "Wrong password")
                        return
                        
                    } else {
                        user.updatePassword(to: self.passwordArray[1]) { error in
                            if let error = error {
                                self.textChange(text: "✕")
                                return
                            } else {
                                self.textChange(text: "Password changed")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                    withAnimation(.snappy(duration: 0.2)) {
                                        self.openPasswordChange = false
                                    }
                                    for (index, item) in self.passwordArray.enumerated() {
                                        self.passwordArray[index] = ""
                                    }
                                    self.passwordButton = false
                                }
                            }
                        }
                        
                    }
                }
            } else {
                self.textChange(text: "At least 6 characters")
            }
        } else {
            self.textChange(text: "New passwords not matching")
        }
    }
    
    func textChange(text: String) {
        withAnimation(.snappy(duration: 0.2)) {
            self.passwordChangeText = text
            self.loading = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.snappy(duration: 0.2)) {
                self.passwordChangeText = "Confirm change"
            }
        }
    }
    
}
