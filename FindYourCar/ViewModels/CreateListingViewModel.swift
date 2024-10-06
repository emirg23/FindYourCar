
import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SDWebImageSwiftUI
import PhotosUI

class CreateListingViewModel: ObservableObject {
    
    @Published var loading = false
    @Published var createdListing = false
    @Published var unableToCreate = false
    @Published var clickedArray = [false, false, false, false, false, false]
    @Published var previousClickedArray = [false, false, false, false, false, false]
    @Published var backgroundColor = Color(red: 200/255, green: 200/255, blue: 200/255)
    @Published var showButton = false
    @Published var displayedText = ""
    @Published var selectedMake: String
    @Published var selectedModel: String
    @Published var selectedYear = "2024"
    @Published var selectedGear = "Automatic"
    @Published var selectedFuelType = "Diesel"
    @Published var selectedCarCondition = "No accident history"
    @Published var yearOptions: [String] = {
    stride(from: 2024, through: 1970, by: -1).map { String($0) }
    }()
    @Published var gearOptions = ["Automatic", "Automanual", "Manual"]
    @Published var fuelTypeOptions = ["Diesel", "Electric", "Hybrid", "Gasoline"]
    @Published var conditionOptions: [String] = ["No accident history", "At least 1 reported accident"]
    
    @Published var verificationID: String?
    @Published var textFullyDisplayed = false
    @Published var kilometerValue = ""
    @Published var price = ""
    @FocusState var focusedField: Field?
    @Published var heightValue = UIScreen.main.bounds.width/12
    @Published var selectedItems: [PhotosPickerItem] = []
    @Published var imageURLs: [URL] = []
    @Published var isPickerPresented: Bool = false
    @Published var uploadText = "Upload photos"
    @Published var userListingNumber: Int = 0
    @Published var makeOptions: [String] = []
    @Published var modelOptions: [String] = ["All model"]

    enum Field: Hashable {
            case kilometer
            case price
    }
    var currentIndex = 0
    var timer: Timer?

    let selectedDisplayText = "MakeYourListing"
    
    init(selectedMake: String = "All makes", selectedModel: String = "All models") {
            self.selectedMake = selectedMake
            self.selectedModel = selectedModel
    }
    func loadImageUrls(from items: [PhotosPickerItem]) {
        imageURLs.removeAll()
        
        for item in items {
            
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
                    try? data.write(to: tempURL)
                    imageURLs.append(tempURL)
                }
            }
        }
    }
    
    func startWritingEffect() {
        let charDelay = Double.random(in: 0.05...0.18)
        
        timer = Timer.scheduledTimer(withTimeInterval: charDelay, repeats: false) { _ in
            if self.currentIndex < self.selectedDisplayText.count {
                let currentCharacter = self.selectedDisplayText[self.selectedDisplayText.index(self.selectedDisplayText.startIndex, offsetBy: self.currentIndex)]
                
                self.displayedText.append(currentCharacter)
                self.currentIndex += 1
                self.startWritingEffect()
            } else {
                self.timer?.invalidate()
                self.timer = nil
                withAnimation(.bouncy(duration: 1)) {
                    self.textFullyDisplayed = true
                }
            }
        }
    }
    
    func findPhoneNumberAndName(completion: @escaping ([String]?) -> Void) {
        let auth = Auth.auth()


            guard let email = auth.currentUser?.email else {
                completion(nil)
                return
            }

            let user = Firestore.firestore().collection("users").document(email)
            user.getDocument { (querySnapshot, error) in
                guard let userSs = querySnapshot, error == nil, let userData = userSs.data(),
                      let phoneNumber = userData["phone number"] as? String else {
                    completion(nil)
                    return
                }
                
                guard let userSs = querySnapshot, error == nil, let userData = userSs.data(),
                      let userName = userData["name"] as? String else {
                    completion(nil)
                    return
                }
                
                completion(["+90" + phoneNumber, userName])
            }
    }
    
    func findListingNumber(makeSelection: String, modelSelection: String) {
        self.loading = true
        userListingNumber = 0

        let auth = Auth.auth()

        guard let email = auth.currentUser?.email else {
            return
        }

        let selectedUserDocument = Firestore.firestore().collection("users").document(email)
            
        selectedUserDocument.getDocument { (querySnapshot, error) in
            
            guard let userSs = querySnapshot, error == nil else {
                return
            }
            guard let data = userSs.data() else {
                return
            }
            
            if let listingNumber = data["listing number"] as? Int {
                self.userListingNumber = listingNumber
            }
            
            if self.userListingNumber < 5 {
                self.userListingNumber += 1
                
                selectedUserDocument.updateData(["listing number": self.userListingNumber])
                
                // making firebase storage folder/data for listing
                let storage = Storage.storage()
                
                for (index, imageData) in self.imageURLs.enumerated() {
                    let storageRef = storage.reference().child("users/\(auth.currentUser!.email!)/listing_\(self.userListingNumber)/image\(index).jpg")
                    
                    if let data = try? Data(contentsOf: imageData) {
                        storageRef.putData(data, metadata: nil)
                    }
                }
                
                let selectedMakeDocument = Firestore.firestore().collection("listed cars").document(makeSelection)
                var usedNumbers = Set<Int>() 
                
                selectedMakeDocument.getDocument { (querySnapshot, error) in
                    guard let selectedMakeSs = querySnapshot, error == nil else {
                        return
                    }
                    
                    guard let data = selectedMakeSs.data() else {
                        return
                    }
                    
                    
                    for alreadyListed in data.keys {
                        if alreadyListed.hasPrefix(modelSelection) {
                            let numberPart = alreadyListed.dropFirst(modelSelection.count + 1)
                            
                            if let number = Int(numberPart) {
                                usedNumbers.insert(number)
                            }
                        }
                    }
                    
                    
                    let sortedNumbers = usedNumbers.sorted()
                    
                    
                    var numberForNewListing = 0
                    while usedNumbers.contains(numberForNewListing) {
                        numberForNewListing += 1
                    }
                    
                    
                    self.makeListing(selectedMake: makeSelection, selectedModel: modelSelection, makeSelection: makeSelection, modelSelection: modelSelection, numberOfListing: numberForNewListing, userListingNumber: self.userListingNumber)
                }
            } else {
                self.unableToCreate = true
                self.loading = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.unableToCreate = false
                    self.createdListing = false
                    self.selectedMake = "All makes"
                    self.selectedModel = "All models"
                    self.kilometerValue = ""
                    self.price = ""
                    self.selectedItems = []
                    self.imageURLs = []
                    self.uploadText = "Upload photos"
                }
            }
        }
    }


    func makeListing(selectedMake: String, selectedModel: String, makeSelection: String, modelSelection: String, numberOfListing: Int, userListingNumber: Int) {
        let phoneNumber = findPhoneNumberAndName { result in
            if let userDetails = result {
                let phoneNumber = userDetails[0]
                let userName = userDetails[1]
                
                let selectedMakeDocument = Firestore.firestore().collection("listed cars").document(makeSelection)
                
                selectedMakeDocument.getDocument { (querySnapshot, error) in
                    guard let selectedMakeSs = querySnapshot, error == nil else {
                        return
                    }
                    
                    guard let data = selectedMakeSs.data() else {
                        return
                    }
                    let key = "\(modelSelection)_\(String(numberOfListing))"
                    selectedMakeDocument.updateData([
                        key: FieldValue.arrayUnion([self.selectedMake, self.selectedModel, self.selectedYear, self.selectedGear, self.selectedFuelType, self.selectedCarCondition, self.kilometerValue, Int(self.price), String(phoneNumber), String(userListingNumber), String(userName)])
                    ])
                    self.createdListing = true
                    self.loading = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.unableToCreate = false
                        self.createdListing = false
                        self.selectedMake = "All makes"
                        self.selectedModel = "All models"
                        self.selectedYear = "2024"
                        self.selectedGear = "Automatic"
                        self.selectedFuelType = "Diesel"
                        self.selectedCarCondition = "No accident history"
                        self.kilometerValue = ""
                        self.price = ""
                        self.selectedItems = []
                        self.imageURLs = []
                        self.uploadText = "Upload photos"
                    }

                }
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



