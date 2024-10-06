
import Foundation
import SwiftUI
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class ListingViewModel: ObservableObject {
    @Published var jpgFiles: [StorageReference] = []
    @Published var photoWidth = UIScreen.main.bounds.width
    @Published var photoHeight = UIScreen.main.bounds.width * 3/4
    @Published var images: [UIImage?] = []
    @Published var usersListings: [[String]] = []
    @Published var navigate = false
    @Published var phoneNumber: String
    @Published var name: String
    @Published var listingNumber: Int
    @Published var makeName: String
    @Published var modelName: String
    @Published var priceValue: String
    @Published var yearValue: String
    @Published var fuelText: String
    @Published var gearText: String
    @Published var kmValue: String
    @Published var accidentText: String
    @Published var userEmail: String
    @Published var currentUserPhoneNumber: String = ""
    @Published var navigateWithRemove = false
    @Published var settingViewOne = false
    @Binding var selectedView: Int
    
    init(jpgFiles: [StorageReference] = [], photoWidth: CGFloat = UIScreen.main.bounds.width, photoHeight: CGFloat = UIScreen.main.bounds.width * 3/4, images: [UIImage?] = [], usersListings: [[String]] = [], navigate: Bool = false, phoneNumber: String = "", name: String = "", listingNumber: Int = 0, makeName: String = "", modelName: String = "", priceValue: String = "", yearValue: String = "", fuelText: String = "", gearText: String = "", kmValue: String = "", accidentText: String = "", userEmail: String = "", selectedView: Binding<Int>) {
        self.jpgFiles = jpgFiles
        self.photoWidth = photoWidth
        self.photoHeight = photoHeight
        self.images = images
        self.usersListings = usersListings
        self.navigate = navigate
        self.phoneNumber = phoneNumber
        self.name = name
        self.listingNumber = listingNumber
        self.makeName = makeName
        self.modelName = modelName
        self.priceValue = priceValue
        self.yearValue = yearValue
        self.fuelText = fuelText
        self.gearText = gearText
        self.kmValue = kmValue
        self.accidentText = accidentText
        self.userEmail = userEmail
        _selectedView = selectedView
    }
    
    func downloadImage() {
        
        let storage = Storage.storage()
        let storageFolderRef = storage.reference().child("users/\(userEmail)/listing_\(listingNumber)")
        
        storageFolderRef.listAll { (result, error) in
            if let error = error {
                return
            }
            
            self.jpgFiles = result!.items
            self.loadImage(from: self.jpgFiles)
        }
    }
    
    private func cropImage(_ image: UIImage) -> UIImage? {
        let width = image.size.width
        let height = image.size.height
        
        let targetAspectRatio: CGFloat = 1.0 / (3.0 / 4.0)
        
        let newWidth = width
        let newHeight = newWidth * (3.0 / 4.0)
        
        let cropX = (width - newWidth) / 2
        let cropY = (height - newHeight) / 2
        
        let cropRect = CGRect(x: cropX, y: cropY, width: newWidth, height: newHeight)
        
        if let cgImage = image.cgImage?.cropping(to: cropRect) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
    func getCurrentPhoneNumber() {
        let document = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.email!)
        
        document.getDocument { (querySnapshot, error) in
            if let error = error {
                return
            }
            
            guard let data = querySnapshot?.data() else {
                return
            }
            
            self.currentUserPhoneNumber = data["phone number"] as! String
        }
    }
    
    func removeListing() {

        let document = Firestore.firestore().collection("listed cars").document(self.makeName)
        
        document.getDocument { (QuerySnapshot, error) in
            if let error = error {
                return
            }

            let data = QuerySnapshot?.data()
            
            for (key, value) in data ?? [:] {

                if let stringArray = value as? [Any] {

                    if (stringArray[8] as! String).dropFirst(3) == self.currentUserPhoneNumber, (stringArray[9] as! String) == String(self.listingNumber) {

                        document.updateData([key: FieldValue.delete()]) { error in
                            if let error = error {
                                return
                            }
                            
                            let userDocument = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.email!)
                            
                            userDocument.getDocument { (QuerySnapshot, error) in
                                if let error = error {
                                    return
                                }
                                
                                userDocument.updateData(["listing number": FieldValue.increment(Int64(-1))]) { error in
                                    if let error = error {
                                        return
                                    }
                                    
                                    let storageRef = Storage.storage().reference().child("users/\(Auth.auth().currentUser!.email!)/listing_\(self.listingNumber)")
                                    
                                    storageRef.listAll { (result, error) in
                                        if let error = error {
                                            return
                                        }
                                        
                                        for item in result!.items {
                                            
                                            item.delete { error in
                                                if let error = error {
                                                    return
                                                }
                                            }
                                        }
                                        self.navigateWithRemove = true
                                        
                                        self.selectedView = 2
                                        
                                        self.navigate = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func loadImage(from storageReference: [StorageReference]) {
        images = Array(repeating: nil, count: storageReference.count)
        
        let maxSize: Int64 = 5 * 1024 * 1024
        
        for (index, reference) in storageReference.enumerated() {
            reference.getData(maxSize: maxSize) { data, error in
                if let error = error {
                    return
                }
                
                guard let data = data, let loadedImage = UIImage(data: data) else {
                    return
                }
                
                DispatchQueue.main.async {
                    if index < self.images.count {
                        self.images[index] = self.cropImage(loadedImage)
                    }
                }
            }
        }
    }
    
    func getUsersListings(phoneNumber: String) {
        let db = Firestore.firestore().collection("listed cars")
        var listings: [[String]] = []
        
        db.getDocuments { (querySnapshot, error) in
            if let error = error {
                return
            }
            
            guard let querySnapshot = querySnapshot else {
                return
            }
            
            for document in querySnapshot.documents {
                let data = document.data()
                
                for (key, value) in data {
                    
                    if let modelsArray = value as? [Any], modelsArray.count > 8, modelsArray[8] as? String == phoneNumber {
                        let stringArray = modelsArray.map { element in
                                if let number = element as? NSNumber {
                                    return number.stringValue
                                } else if let string = element as? String {
                                    return string
                                } else {
                                    return "\(element)"
                                }
                            }
                            listings.append(stringArray)
                    }
                }
            }
            
            self.usersListings = listings
            self.navigate = true
        }
    }

}
