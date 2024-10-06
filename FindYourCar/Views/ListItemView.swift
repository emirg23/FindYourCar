
import SwiftUI
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

struct ListItemView: View {
    
    var makeText: String
    var modelText: String
    var kilometerText: String
    var priceText: String
    var yearText: String
    var phoneNumber: String
    var fuelText: String
    var gearText: String
    var accidentText: String
    var listingNumberForUser: Int
    var name: String
    @State var email: String = ""
    @State var navigate = false
    @State var image: UIImage?
    @Binding var selectedView: Int
    
    var body: some View {
        NavigationLink("", destination: ListingView(vM: ListingViewModel(phoneNumber: phoneNumber, name: name, listingNumber: listingNumberForUser, makeName: makeText, modelName: modelText, priceValue: priceText, yearValue: yearText, fuelText: fuelText, gearText: gearText, kmValue: kilometerText, accidentText: accidentText, userEmail: email, selectedView: $selectedView)).navigationBarBackButtonHidden(true), isActive: $navigate)
        Button {
            navigate = true
        } label: {
            
            VStack{
                HStack{
                    ZStack{
                        if let image = image {
                            if let croppedImage = cropToSquare(image: image) {
                                Image(uiImage: croppedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: (UIScreen.main.bounds.height - 200) / 10, height: (UIScreen.main.bounds.height - 200) / 10)
                            }
                        } else {
                            ProgressView()
                                .tint(.black)
                        }
                    }
                    .background(.white)
                    .frame(width: (UIScreen.main.bounds.height - 200) / 10, height: (UIScreen.main.bounds.height - 200) / 10)

                    
                    
                    VStack{
                        HStack{
                            Text("\(makeText) - \(modelText)")
                            Spacer()
                        }
                        Spacer()
                        HStack{
                            Text("\(yearText)")
                            Spacer()
                        }
                        
                    }
                    .frame(width: UIScreen.main.bounds.width * 1/2)
                    Spacer()
                    
                    VStack{
                        HStack{
                            Spacer()
                            Text("\(kilometerText)KM")
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.55/2)
                        Spacer()
                        
                        HStack{
                            Spacer()
                            Text("\(priceText)TL")
                                .foregroundStyle(.purple)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.55/2)
                    }
                    
                }
                .onAppear() {
                    getImage()
                }
                .offset(y: 1.5)
                .frame(width: UIScreen.main.bounds.width * 8/9, height: (UIScreen.main.bounds.height - 200) / 10)
                
                ZStack{ // horizontal line
                    Color.gray
                }
                .frame(width: UIScreen.main.bounds.width, height: 1)
                .cornerRadius(10)
                
            }
            .foregroundColor(.black)
            .font(.system(size: 15, design:.monospaced))
            .offset(y: 5)
            .frame(height: (UIScreen.main.bounds.height - 200) / 10)
        }
    }
    
    func cropToSquare(image: UIImage) -> UIImage? {
        let originalWidth = image.size.width
        let originalHeight = image.size.height

        let squareSize = min(originalWidth, originalHeight)
        let xOffset = (originalWidth - squareSize) / 2
        let yOffset = (originalHeight - squareSize) / 2

        let cropRect = CGRect(x: xOffset, y: yOffset, width: squareSize, height: squareSize)
        
        if let cgImage = image.cgImage?.cropping(to: cropRect) {
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        }

        return nil
    }
    
    func getImage() {
        let db = Firestore.firestore().collection("users")
        
        db.getDocuments { (querySnapshot, error) in
            if let error = error {
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                return
            }
            
            for document in documents {
                let data = document.data()
                
                if data["phone number"] as! String == phoneNumber.dropFirst(3) {
                    email = document.documentID
                    let storage = Storage.storage()
                    let storageRef = storage.reference().child("users/\(email)/listing_\(listingNumberForUser)/image0.jpg")
                    
                    storageRef.getData(maxSize: Int64(5 * 1024 * 1024)) { data, error in
                        if let data = data {
                            image = UIImage(data: data)
                        }
                    }
                }
            }
        }
    }
}


#Preview {
    ListItemView(makeText: "BMW", modelText: "M4", kilometerText: "123000", priceText: "40000", yearText: "2020", phoneNumber: "1231231232", fuelText: "Gasoline", gearText: "Automatic", accidentText: "No accident reported", listingNumberForUser: 0, name: "Emir", selectedView: .constant(1))
}
