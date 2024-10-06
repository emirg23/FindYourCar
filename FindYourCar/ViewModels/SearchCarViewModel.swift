
import Foundation
import FirebaseFirestore
import SwiftUI
import FirebaseAuth

class SearchCarViewModel: ObservableObject {
    @Published var displayedText = ""
    @Published var textFullyDisplayed = false
    @Published var currentIndex = 0
    @Published var timer: Timer?
    @Published var selectedDisplayText = ""
    @Published var selectedMake: String = "All makes"
    @Published var selectedModel: String = "All models"
    @Published var username: String = ""
    @Published var makeIsClicked: Bool = false
    @Published var modelIsClicked: Bool = false
    @Published var startedText = false
    @Published var backgroundColor = Color(red: 200/255, green: 200/255, blue: 200/255)
    @Published var listNumber: Int = 0
    @Published var listingLoading = false
    @Published var navigate = false
    @Published var resultList: [[String]] = []
    @Published var makeOptions: [String] = []
    @Published var modelOptions: [String] = ["All model"]
    
    func getViewResults(make: String, model: String, completion: @escaping ([[String]]) -> Void) {
        listingLoading = true
        let db = Firestore.firestore()
        var results: [[String]] = []

        if make != "All makes" {
            let listedCarsRef = db.collection("listed cars").document(make)
            

            listedCarsRef.getDocument { (makeSnapshot, error) in
                if let error = error {
                    self.listingLoading = false
                    completion([])
                    return
                }

                guard let makeSs = makeSnapshot, let makeData = makeSs.data() else {
                    self.listingLoading = false
                    completion([])
                    return
                }

                for (fieldID, resultItem) in makeData {
                    guard let resultItemArray = resultItem as? [Any] else {
                        continue
                    }

                    let resultStringArray = resultItemArray.map { "\($0)" }
                    if model != "All models" {
                        if fieldID.hasPrefix("\(model)_") {
                            results.append(resultStringArray)
                        }
                    } else {
                        results.append(resultStringArray)
                    }
                }
                self.navigate = true
                self.listingLoading = false
                completion(results)
            }
        } else {
            let carMakes = db.collection("listed cars")

            carMakes.getDocuments { (allMakesSnapshot, error) in
                if let error = error {
                    completion([])
                    self.listingLoading = false
                    return
                }

                for document in allMakesSnapshot?.documents ?? [] {
                    let documentData = document.data()

                    for (_, value) in documentData {
                        if let listedModelArray = value as? [Any] {
                            let resultStringArray = listedModelArray.compactMap { "\($0)" }
                            if !resultStringArray.isEmpty {
                                results.append(resultStringArray)
                            }
                        }
                    }
                }
                self.navigate = true
                self.listingLoading = false
                completion(results)
            }
        }
    }

    func getUsernameAndText() {

        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        guard let currentUserEmail = currentUser.email else {
            return
        }
        
        let db = Firestore.firestore()
        var userDataRef = db.collection("users").document(currentUserEmail)
        
        userDataRef.getDocument { (document, error) in
            guard let userDocument = document,
            let userData = userDocument.data(),
            let username = userData["name"] as? String else {
                return
            }
            if !self.startedText{
                var textChances: [String] = []
                if username.count < 9 {
                    textChances = ["Find\(username)sCar"] // you can add bunch of texts for welcome message, which will be random
                } else {
                    textChances = ["FindYourCar"]
                }
                
                self.selectedDisplayText = textChances[Int.random(in: textChances.indices)]
                self.startedText = true
            }
            
            self.startWritingEffect()
        }
        
        
    }
    func getListingAmount(make: String, model: String) -> Void {
        listingLoading = true
        let db = Firestore.firestore()
        var listingNumber = 0
        if make != "All makes" {
            let listedCarsRef = db.collection("listed cars").document(make)
            listedCarsRef.getDocument { (makeSnapshot, error) in
                guard let makeSs = makeSnapshot else {
                    return
                }
                
                guard let makeData = makeSs.data() else {
                    return
                }
                
                for (fieldID, _) in makeData {
                    if model != "All models" {
                        if fieldID.hasPrefix("\(model)_") {
                            listingNumber += 1
                        }
                    } else {
                        listingNumber += 1
                    }
                    
                }
                DispatchQueue.main.async {
                    self.listNumber += listingNumber
                    self.listingLoading = false
                }
            }

        } else {
            let carMakes = db.collection("cars")
            var carMakesArray: [String] = []
            var totalCarListing = 0
            
            carMakes.getDocuments { (allMakesSnapshot, error) in
                guard let allMakesSs = allMakesSnapshot else {
                    return
                }
                
                for document in allMakesSs.documents {
                    carMakesArray.append(document.documentID)
                }
                for make in carMakesArray {
                    self.getListingAmount(make: make, model: "All models")
                }
                if totalCarListing != 0 {
                    self.listingLoading = false
                }
            }
        }
                
    }
    
    func startWritingEffect() {
        let charDelay = Double.random(in: 0.05...0.18) // random between 0.02...0.1 so more realistic
        
        self.timer = Timer.scheduledTimer(withTimeInterval: charDelay, repeats: false) { _ in
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
                return
            }
        }
    }

    func getModelDatas() {
        if self.selectedMake != "All makes" {
            let db = Firestore.firestore()
            let selectedMakeDocumentRef = db.collection("cars").document(selectedMake)

            selectedMakeDocumentRef.getDocument { (querySnapshot, error) in
                guard let querySnapshot else {
                    return
                }
                
                guard let selectedMakeData = querySnapshot.data() else {
                    return
                }
                
                guard let modelsArray: [String] = selectedMakeData["Models"] as? [String] else {
                    return
                }
                self.modelOptions.removeAll()
                
                DispatchQueue.main.async {
                    self.modelOptions = modelsArray
                    self.modelOptions.append("All models")
                    self.modelOptions.sort()
                }
            }
        } else {
            self.modelOptions.removeAll()
            self.modelOptions.append("All models")
        }
        
    }
    func getMakeDatas() {
        let db = Firestore.firestore()
        let makesCollectionRef = db.collection("cars")
        
        makesCollectionRef.getDocuments { (querySnapshot, error) in
            guard let querySnapshot else {
                return
            }
            self.makeOptions.append("All makes")
            for document in querySnapshot.documents {
                self.makeOptions.append(document.documentID)
                self.makeOptions.sort()
            }
        }
    }
}
