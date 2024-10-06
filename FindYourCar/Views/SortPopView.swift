
import SwiftUI

struct SortPopView: View {
    @ObservedObject var vM: ListingsViewModel
    var body: some View {
        ZStack {
            
            Color.white
            Color(vM.theChanging == "+" ? .green.opacity(0.05) : .red.opacity(0.05))
            
            VStack{
                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // closing keyboard
                    
                    withAnimation(.bouncy(duration: 0.5)) {
                        vM.rotationDegree += vM.rotationDegree == -90 ? 90 : -90
                        vM.theChanging = vM.theChanging == "+" ? "–" : "+"
                        vM.higherToLower = vM.theChanging == "+"
                    }
                } label: {
                    Text(vM.theChanging == "+" ? "From higher" : "From lower")
                        .foregroundStyle(.black)
                        .font(.system(size: 23, design: .monospaced))
                        .offset(x: 20, y: 7.3)
                }
                Spacer()
            }
            
            HStack{ // + -
                Spacer()
                VStack{
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // closing keyboard
                        
                        withAnimation(.bouncy(duration: 0.5)) {
                            vM.rotationDegree += vM.rotationDegree == -90 ? 90 : -90
                            vM.theChanging = vM.theChanging == "+" ? "–" : "+"
                            vM.higherToLower = vM.theChanging == "+"
                        }
                    } label: {
                        Text(vM.theChanging)
                            .font(.system(size: 40, design: .monospaced))
                            .foregroundStyle(.black)
                            .frame(width: 30, height: 30)
                            .multilineTextAlignment(.center)
                            .background(Color.clear)
                    }
                    .rotationEffect(.degrees(vM.rotationDegree))
                    .frame(width: 30, height: 30)
                    .padding(5)
                    Spacer()
                }
            }
            
            VStack(alignment: .leading) {
                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // closing keyboard
                    
                    vM.sortByPrice()
                    withAnimation(.easeOut(duration: 0.15)){
                        vM.sortClicked = false
                    }
                } label: {
                    Text("Sort by price")
                        .padding(30)
                }
                
                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // closing keyboard
                    
                    vM.sortByKM()
                    withAnimation(.easeOut(duration: 0.15)){
                        vM.sortClicked = false
                    }
                } label: {
                    Text("Sort by KM")
                        .padding(30)
                }
                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // closing keyboard
                    
                    vM.sortByYear()
                    withAnimation(.easeOut(duration: 0.15)){
                        vM.sortClicked = false
                    }
                } label: {
                    Text("Sort by year")
                        .padding(30)
                    
                }
            }
            
            .font(.system(size: 23, design: .monospaced))
            .frame(width: UIScreen.main.bounds.width / 1.5, alignment: .leading)
            .foregroundColor(.black)
        }
        .shadow(radius: 5)
        .frame(width: UIScreen.main.bounds.width / 1.5, height: UIScreen.main.bounds.width * 1.1)
        .opacity(vM.sortClicked ? 1 : 0)
    }
}

#Preview {
    SortPopView(vM: ListingsViewModel(ListingItems: [["Dodge", "Charger", "2020", "Automatic", "Gasoline", "No accident history", "300", String(43), "+905346663618", "1", "Haha"], ["Dodge", "Charger", "2000", "Automatic", "Diesel", "No accident history", "2", String(42), "+905346663618", "2", "Demir"], ["Dodge", "Charger", "1998", "Automatic", "Gasoline", "At least 1 reported accident", "400", String(44), "+905346663618", "3", "keke"], ["Dodge", "Charger", "1999", "Automatic", "Diesel", "No accident history", "1", String(43), "+905346663618", "4", "Emir"]]))
}
