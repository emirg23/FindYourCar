
import SwiftUI
import FirebaseStorage
import SDWebImageSwiftUI
import FirebaseAuth

struct ListingView: View {
    @StateObject var vM: ListingViewModel

    var body: some View {
        VStack(spacing: 0) {
            
            ZStack {
                Color.purple
                VStack {
                    Spacer()
                    Text("\(vM.makeName) - \(vM.modelName)")
                        .foregroundStyle(.white)
                        .font(.system(size: 35, design: .monospaced))
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .edgesIgnoringSafeArea(.top)
            .frame(height: UIScreen.main.bounds.width * 0.35)
            
            ZStack {
                SlidableImagesView(vM: vM)
            }
            .frame(width:vM.photoWidth, height: vM.photoHeight)
            .onAppear() {
                vM.getCurrentPhoneNumber()
                vM.downloadImage()
            }
            
            ScrollView {
                
                VStack(spacing: 0){
                    if vM.currentUserPhoneNumber == vM.phoneNumber.dropFirst(3) && vM.selectedView == 2 {
                        Button {
                            vM.removeListing()
                        } label: {
                            ZStack {
                                Color.red
                                Text("Remove this listing")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 19, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.13)
                    }
                    Button {
                        vM.getUsersListings(phoneNumber: vM.phoneNumber)
                    } label: {
                        ZStack {
                            Color.purple
                            Text("All listings by \(vM.name)")
                                .multilineTextAlignment(.center)
                                .font(.system(size: 19, design: .monospaced))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.13)
                    .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                }
                
                
                CarInfoView(infoType: "Price", infoValue: vM.priceValue.appending(" TL"))
                CarInfoView(infoType: "Year", infoValue: vM.yearValue)
                CarInfoView(infoType: "Fuel", infoValue: vM.fuelText)
                CarInfoView(infoType: "Gear", infoValue: vM.gearText)
                CarInfoView(infoType: "Kilometer", infoValue: vM.kmValue)
                CarInfoView(infoType: "Accident", infoValue: vM.accidentText)

                ZStack{
                    Color.white
                }
                .frame(height: UIScreen.main.bounds.width * 0.15)
            }
            .background(.white)
            .padding(.bottom, UIScreen.main.bounds.width * 0.0)
            
            CallButton(phoneNumber: vM.phoneNumber, name: vM.name)
                .offset(y: -UIScreen.main.bounds.width * 0.135)
            BackButtonView(black: false)
                .offset(y: -UIScreen.main.bounds.width * 0.07)
        }
        .onAppear(){
            vM.listingNumber = vM.listingNumber
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(.white)
        
        if vM.navigateWithRemove {
            NavigationLink(
                destination: SearchCarView(selectedView: .constant(1), passMake: .constant(""), passModel: .constant(""))
                    .navigationBarBackButtonHidden(true),
                isActive: $vM.settingViewOne
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: ProfileInfoView()
                    .navigationBarBackButtonHidden(true),
                isActive: $vM.navigate
            ) {
                EmptyView()
            }
        } else {  
            
            NavigationLink(
                destination: ListingsView(vM: ListingsViewModel(ListingItems: vM.usersListings), selectedView: $vM.selectedView)
                    .navigationBarBackButtonHidden(true),
                isActive: $vM.navigate
            ) {
                EmptyView()
            }
        }
        
        
    }
}
 
#Preview {
    ListingView(vM: ListingViewModel(selectedView: .constant(2)))
}

struct SlidableImagesView: View {
    @StateObject var vM: ListingViewModel
    @State private var selectedImageIndex = 0
    
    @State private var scales: [CGFloat] = []
    @State private var offsets: [CGSize] = []
    @State private var lastOffsets: [CGSize] = []
    
    var body: some View {
        VStack(spacing: 0) {
            if !vM.images.isEmpty{
                TabView(selection: $selectedImageIndex) {
                    ForEach (Array(vM.images.enumerated()), id: \.offset) { index, image in
                        if let image = image {
                            ScrollView(.horizontal){
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width,
                                           height: UIScreen.main.bounds.width * 3/4)
                                    .onAppear() {
                                        withAnimation(.snappy(duration: 0.5)) {
                                            vM.photoHeight = image.size.height * (vM.photoWidth / image.size.width)
                                        }
                                    }
                                    .onChange(of: selectedImageIndex) {
                                        withAnimation(.snappy(duration: 0.5)) {
                                            vM.photoHeight = image.size.height * (vM.photoWidth / image.size.width)
                                        }
                                    }
                                    .tag(index)
                            }
                            .frame(height: vM.photoHeight)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            } else {
                ProgressView()
                    .tint(.black)
            }
        }
    }
    private func initializeGestureArraysIfNeeded(index: Int) {
            if scales.count <= index {
                scales.append(1.0)
            }
            if offsets.count <= index {
                offsets.append(.zero)
                lastOffsets.append(.zero)
            }
        }
}

struct CallButton: View {
    @State var phoneNumber: String
    @State var name: String
    @State var text: String = ""

    var body: some View {
        Button {
            makePhoneCall(phoneNumber: phoneNumber)
        } label: {
            ZStack {
                Color.purple
                Text(text)
                    .font(.system(size: 17, design: .monospaced))
            }
            .frame(width: UIScreen.main.bounds.width * 2/3, height: 50)
            .cornerRadius(10)
            .foregroundColor(.white)
        }
        .onAppear() {
            text = "Call \(name)"
        }
    }

    func makePhoneCall(phoneNumber: String) {
        if let url = URL(string: "tel://\(phoneNumber)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            text = "Phone call not possible."
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeIn(duration: 0.18)) {
                    text = "\(name), \(phoneNumber)"
                }
            }
        }
    }
}

struct CarInfoView: View {
    var infoType: String
    var infoValue: String
    
    var body: some View {
        VStack{
            HStack {
                Text(infoType)
                
                
                Spacer()
                
                Text(infoValue)
                    .bold()
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
            .cornerRadius(8)
            .foregroundColor(.black)
            
            
            ZStack{ // horizontal line
                Color.gray
            }
            .frame(width: UIScreen.main.bounds.width * 0.95, height: 1)
            .cornerRadius(10)
            
        }
    }
}
