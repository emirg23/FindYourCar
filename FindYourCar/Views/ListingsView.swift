
import SwiftUI
import FirebaseStorage
import FirebaseAuth

struct ListingsView: View {
    @StateObject var vM = ListingsViewModel(ListingItems: [["Dodge", "Charger", "2020", "Automatic", "Gasoline", "No accident history", "300", String(43), "+905346663618", "1", "Haha"], ["Dodge", "Charger", "2000", "Automatic", "Diesel", "No accident history", "2", String(42), "+905346663618", "2", "Demir"], ["Dodge", "Charger", "1998", "Automatic", "Gasoline", "At least 1 reported accident", "400", String(44), "+905346663618", "3", "keke"], ["Dodge", "Charger", "1999", "Automatic", "Diesel", "No accident history", "1", String(43), "+905346663618", "4", "Emir"]])
    @Binding var selectedView: Int
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                ZStack {
                    Color(.purple)
                    VStack {
                        Text(vM.displayedText)
                            .font(.system(size: 38, design: .monospaced))
                            .offset(y: 55)
                            .fixedSize(horizontal: false, vertical: true)
                            .onAppear {
                                vM.startWritingEffect()
                            }
                            .foregroundStyle(.white)
                            .frame(width: UIScreen.main.bounds.width, height: 140, alignment: .leading)
                            .padding(.leading, 20)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: 200, alignment: .top)
                
                HStack(spacing: 0) {
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // closing keyboard
                        
                        if vM.sortClicked {
                            withAnimation(.easeIn(duration: 0.15)){
                                vM.filterClicked.toggle()
                            }
                            withAnimation(.linear(duration: 0.15)) {
                                vM.sortClicked.toggle()
                            }
                            
                        } else {
                            withAnimation(.easeOut(duration: 0.15)){
                                vM.filterClicked.toggle()
                            }
                        }
                    } label: {
                        HStack {
                            Text("Filter")
                                .foregroundStyle(.black)
                        }
                        .frame(width: UIScreen.main.bounds.width / 2, height: 35)
                    }
                    
                    ZStack {
                        Color.black
                    }
                    .frame(width: 0.5, height: 70)
                    
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // closing keyboard
                        
                        if vM.filterClicked {
                            withAnimation(.easeIn(duration: 0.15)){
                                vM.sortClicked.toggle()
                            }
                            withAnimation(.linear(duration: 0.15)) {
                                vM.filterClicked.toggle()
                            }
                        } else {
                            withAnimation(.easeOut(duration: 0.15)){
                                vM.sortClicked.toggle()
                            }
                        }
                    } label: {
                        HStack {
                            Text("Sort")
                                .foregroundStyle(.black)
                            
                        }
                        .frame(width: UIScreen.main.bounds.width / 2, height: 35)
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: 60)
                .background(Color.gray)
                .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                
                ScrollView {
                    ForEach(vM.listingSample, id: \.self) { item in
                        if item.count > 9{
                            ListItemView(makeText: item[0], modelText: item[1], kilometerText: item[6], priceText: item[7], yearText: item[2], phoneNumber: item[8], fuelText: item[4], gearText: item[3], accidentText: item[5], listingNumberForUser: Int(item[9])!, name: item[10], selectedView: $selectedView)
                        }
                    }
                    .padding(10)
                }
                .frame(height: UIScreen.main.bounds.height - 301)
            }
            .background(.white)
            
            ZStack{
                Color.white
                FilterPopView(vM: vM)
                
                SortPopView(vM: vM)
            }
            .opacity(vM.filterClicked || vM.sortClicked ? 1 : 0)
            .frame(width: UIScreen.main.bounds.width / 1.5, height: UIScreen.main.bounds.width * 1.1)
            .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2 + 50)
            
            
            BackButtonView(black: false)
                .offset(y: UIScreen.main.bounds.width * 2.15)
            
        }
        .offset(y: -UIScreen.main.bounds.height * 0.06)
        .onChange(of: vM.clickedArray) { newValue in
            if newValue.filter({ $0 }).count == 2 {
                var oldTrueIndex: Int?
                for (index, (value1, value2)) in zip(vM.previousClickedArray, newValue).enumerated() {
                    if value1 == value2 && value2 {
                        oldTrueIndex = index
                        break
                    }
                }
                
                if let oldTrueIndex = oldTrueIndex {
                    withAnimation(.snappy(duration: 0.4)) {
                        vM.clickedArray[oldTrueIndex] = false
                    }
                }
            }
            vM.previousClickedArray = newValue
        }
        .onAppear() {
            if !vM.loaded{
                vM.listingSample = vM.ListingItems
            }
            vM.loaded = true
        }
    }
}

#Preview {
    ListingsView(selectedView: .constant(1))
}

struct FilterValues: Equatable {
    var priceMaximumValue: String
    var priceMinimumValue: String
    var KMmaximumValue: String
    var KMminimumValue: String
    var yearMaximumValue: String
    var yearMinimumValue: String
    var fuelFilter: String
    var gearFilter: String
    var accidentFilter: String
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct FilterTextFieldView: View {
    var type: String
    @Binding var dataMin: String
    @Binding var dataMax: String
    var body: some View {
        HStack(spacing: 4){
            Text("Filter by \(type)")

            Spacer()
            
            TextField("minimum", text: $dataMin)
                .foregroundColor(.black.opacity(0.7))
                .background(.gray.opacity(0.5))
                .font(.system(size: 10.5))
                .frame(width: 59)
                .multilineTextAlignment(.center)
                .shadow(radius: 1)
                .keyboardType(.numberPad)
                .onChange(of: dataMin) { newValue in
                    dataMin = newValue.filter { $0.isNumber }
                }
            
            Text("–")
            TextField("maximum", text: $dataMax)
                .foregroundColor(.black.opacity(0.7))
                .background(.gray.opacity(0.5))
                .font(.system(size: 10.5))
                .frame(width: 59)
                .shadow(radius: 1)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .onChange(of: dataMax) { newValue in
                    dataMax = newValue.filter { $0.isNumber }
                }
        }
        .padding(3)
    }
}
