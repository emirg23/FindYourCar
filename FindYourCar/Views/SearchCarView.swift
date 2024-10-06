
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SearchCarView: View {
    @ObservedObject var vM = SearchCarViewModel()
    @Binding var selectedView: Int
    @Binding var passMake: String
    @Binding var passModel: String

    var body: some View {
        NavigationView {
            
            VStack{
                ZStack{
                    Color(.purple)
                    VStack(alignment: .leading){
                        Text(vM.displayedText)
                            .font(.system(size: 40, design: .monospaced))
                            .offset(y:55)
                            .fixedSize(horizontal: false, vertical: true)
                            .onAppear {
                                vM.getUsernameAndText()
                            }
                            .foregroundStyle(.white)
                            .frame(width: UIScreen.main.bounds.width, height: 140, alignment: .leading)
                            .padding(.leading, 20)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(width:UIScreen.main.bounds.width, height: 200, alignment: .top)
                .cornerRadius(10)
                .position(x:UIScreen.main.bounds.width/2, y:0)
                
                VStack{
                    HStack{
                        SelectMenuView(vM: SelectMenuViewModel(displayingText: vM.selectedMake, options: vM.makeOptions, title: "Makes"), isClicked: $vM.makeIsClicked, lastSelected: $vM.selectedMake) // make

                        SelectMenuView(vM: SelectMenuViewModel(displayingText: vM.selectedModel,  options: vM.modelOptions, title: "Models"), isClicked: $vM.modelIsClicked, lastSelected: $vM.selectedModel) // model
                    }
                    .frame(height: 250)
                    .background(vM.backgroundColor)
                    
                    .onChange(of: vM.makeIsClicked) { newValue in
                        if newValue {
                            withAnimation(.snappy(duration: 0.4)) {
                                vM.modelIsClicked = false
                            }
                        } else {
                            vM.listNumber = 0
                            vM.getListingAmount(make: vM.selectedMake, model: vM.selectedModel)
                        }
                    }
                    .onChange(of: vM.modelIsClicked) { newValue in
                        if newValue {
                            withAnimation(.snappy(duration: 0.4)) {
                                vM.makeIsClicked = false
                            }
                        } else {
                            vM.listNumber = 0
                            vM.getListingAmount(make: vM.selectedMake, model: vM.selectedModel)
                        }
                    }
                    .onChange(of: vM.selectedMake) {
                        vM.selectedModel = "All models"
                        vM.getModelDatas()
                    }

                    Button {
                        if vM.listNumber != 0 {
                            vM.getViewResults(make: vM.selectedMake, model: vM.selectedModel) { results in
                                vM.resultList = results
                                vM.navigate = true
                            }
                        }
                        
                        
                    } label: {
                        ZStack{
                            if vM.listingLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("View \(vM.listNumber) listings")
                            }
                        }
                        .frame(width:400, height: 50)
                        .background(.purple)
                        .foregroundColor(.white)
                        .font(.system(size: 20, design: .monospaced))
                        .onChange(of: vM.textFullyDisplayed){
                            vM.getListingAmount(make: vM.selectedMake, model: vM.selectedModel)
                        }
                    }
                    .cornerRadius(10)
                    
                    Button {
                        passMake = vM.selectedMake
                        passModel = vM.selectedModel
                        selectedView = 1
                    } label: {
                        HStack{
                            Text("Or add listing")
                                .foregroundStyle(.blue)
                                .padding(.horizontal, 5)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width, alignment: .trailing)
                    
                }
                .opacity(vM.textFullyDisplayed ? 1 : 0)
                .position(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/23)
                .background(vM.backgroundColor)
            }
            .onAppear() {
                if vM.makeOptions.isEmpty {
                    vM.getMakeDatas()
                }
            }
            .background(
                NavigationLink(
                    destination: ListingsView(vM: ListingsViewModel(ListingItems: vM.resultList), selectedView: $selectedView)
                        .navigationBarBackButtonHidden(true),
                    isActive: $vM.navigate
                ) {
                    EmptyView()
                }
            )
            .background(vM.backgroundColor)
        }
    }
}

#Preview {
    SearchCarView(selectedView: .constant(0), passMake: .constant(""), passModel: .constant(""))
}
