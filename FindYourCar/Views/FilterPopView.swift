
import SwiftUI

struct FilterPopView: View {
    @ObservedObject var vM: ListingsViewModel
    var body: some View {
        ZStack{
            vM.backgroundColor
            ScrollView {
                VStack(alignment: .leading){
                    Text(Int(vM.filterResultNumber)! > 1 ? "\(vM.filterResultNumber) results" : "\(vM.filterResultNumber) result" )
                        .frame(width: UIScreen.main.bounds.width / 1.5)
                        .font(.system(size: 20, design: .monospaced))
                        .foregroundColor(.gray)
                        .onAppear(){
                            vM.filterResultNumber = String(vM.listingSample.count)
                        }
                        .onChange(of: FilterValues(priceMaximumValue: vM.priceMaximumValue, priceMinimumValue: vM.priceMinimumValue, KMmaximumValue: vM.KMmaximumValue,
                                                   KMminimumValue: vM.KMminimumValue, yearMaximumValue: vM.yearMaximumValue, yearMinimumValue: vM.yearMinimumValue,
                                                   fuelFilter: vM.fuelFilter, gearFilter: vM.gearFilter, accidentFilter: vM.accidentFilter)){
                            vM.updateFilterResult()
                        }
                    
                    HStack{
                        Text("Filter by fuel")
                        
                        Spacer()
                        
                        ListingsSelectMenuView(displayingText: $vM.fuelFilter, options: ["Any", "Diesel", "Electric", "Hybrid", "Gasoline"], isClicked: $vM.clickedArray[0], lastSelected: "Any")
                    }
                    .frame(height: UIScreen.main.bounds.width/20 * 3)
                    .padding(3)
                    
                    HStack{
                        Text("Filter by gear")
                        
                        Spacer()
                        
                        ListingsSelectMenuView(displayingText: $vM.gearFilter, options: ["Any", "Automatic", "Automanual", "Manual"], isClicked: $vM.clickedArray[1], lastSelected: "Any")
                    }
                    .frame(height: UIScreen.main.bounds.width/20 * 3)
                    .padding(3)
                    
                    HStack{
                        Text("Filter by accident")
                        
                        Spacer()
                        
                        ListingsSelectMenuView(displayingText: $vM.accidentFilter, options: ["Any", "No accident history"], isClicked: $vM.clickedArray[2], lastSelected: "Any")
                    }
                    .frame(height: UIScreen.main.bounds.width/20 * 3)
                    .padding(3)
                    
                    
                    FilterTextFieldView(type: "price", dataMin: $vM.priceMinimumValue, dataMax: $vM.priceMaximumValue)
                    
                    FilterTextFieldView(type: "KM", dataMin: $vM.KMminimumValue, dataMax: $vM.KMmaximumValue)
                    
                    FilterTextFieldView(type: "year", dataMin: $vM.yearMinimumValue, dataMax: $vM.yearMaximumValue)
                    
                }
                .offset(y: UIScreen.main.bounds.width * 0.05)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.black)
                .frame(width: UIScreen.main.bounds.width / 1.5, height: UIScreen.main.bounds.height / 2, alignment: .leading)
            }
            .offset(y: -UIScreen.main.bounds.width * 0.05)
            .frame(width: UIScreen.main.bounds.width / 1.5, height: UIScreen.main.bounds.width * 1, alignment: .leading)
            
            HStack{
                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // closing keyboard
                    
                    vM.listingSample = vM.ListingItems
                    
                    vM.filterResult  = vM.applyAllFilter(filterTarget: vM.listingSample)
                    
                    withAnimation(.easeIn(duration: 0.15)){
                        vM.filterClicked = false
                        vM.listingSample = vM.filterResult
                    }
                    vM.filterResult = []
                } label: {
                    ZStack{
                        Color.green
                        Text("Filter")
                            .foregroundStyle(.white)
                            .font(.system(size: 10, design: .monospaced))
                    }
                    .frame(width: 60, height:20)
                    .cornerRadius(10)
                }
                .frame(width: 60, height:20)
                
                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // closing keyboard
                    
                    vM.KMmaximumValue = ""
                    vM.KMminimumValue = ""
                    vM.priceMaximumValue = ""
                    vM.priceMinimumValue = ""
                    vM.yearMaximumValue = ""
                    vM.yearMinimumValue = ""
                    vM.fuelFilter = "Any"
                    vM.gearFilter = "Any"
                    vM.accidentFilter = "Any"
                    vM.filterResult = []
                    withAnimation(.easeIn(duration: 0.15)){
                        vM.listingSample = vM.ListingItems
                        vM.filterClicked = false
                    }
                } label: {
                    ZStack{
                        Color.red
                        Text("Reset")
                            .foregroundStyle(.white)
                            .font(.system(size: 10, design: .monospaced))
                    }
                    .frame(width: 50, height:20)
                    .cornerRadius(10)
                }
                .frame(width: 50, height:20)
            }
            .offset(y: UIScreen.main.bounds.width * 0.51)
        }
        .shadow(radius: 5)
        .opacity(vM.filterClicked ? 1 : 0)
    }
}

#Preview {
    FilterPopView(vM: ListingsViewModel(ListingItems: [["Dodge", "Charger", "2020", "Automatic", "Gasoline", "No accident history", "300", String(43), "+905346663618", "1", "Haha"], ["Dodge", "Charger", "2000", "Automatic", "Diesel", "No accident history", "2", String(42), "+905346663618", "2", "Demir"], ["Dodge", "Charger", "1998", "Automatic", "Gasoline", "At least 1 reported accident", "400", String(44), "+905346663618", "3", "keke"], ["Dodge", "Charger", "1999", "Automatic", "Diesel", "No accident history", "1", String(43), "+905346663618", "4", "Emir"]]))
}
