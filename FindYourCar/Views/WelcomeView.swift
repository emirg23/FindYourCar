import SwiftUI

struct WelcomeView: View {
    @State var selectedView = 0
    @State var passMake = "All makes"
    @State var passModel = "All models"
    
    @State var searchCarViewID = UUID()
    @State var createListingViewID = UUID()
    @State var profileInfoViewID = UUID()
    
    var body: some View {
        TabView(selection: $selectedView){
            SearchCarView(vM: SearchCarViewModel(), selectedView: $selectedView, passMake: $passMake, passModel: $passModel)
                .id(searchCarViewID)
                .tabItem() {
                    VStack{
                        Image(systemName: "car")
                        Text("FindYourCar")
                    }
                }
                .tag(0)
                .onTapGesture {
                    if selectedView == 0 {
                    }
                }
            
            CreateListingView(vM: CreateListingViewModel(selectedMake: passMake, selectedModel: passModel))
                .tabItem(){
                    VStack{
                        Image(systemName: "plus.circle.fill")
                        Text("Create")
                    }
                }
                .tag(1)
                .onTapGesture {
                    if selectedView == 1 {
                    }
                }

            ProfileInfoView()
                .tabItem() {
                    VStack{
                        Image(systemName: "person")
                        Text("Profile")
                    }
                }
                .tag(2)
                .onTapGesture {
                    if selectedView == 2 {
                    }
                }
        }
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color(red: 50/255, green: 50/255, blue: 50/255))

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            UITabBar.appearance().unselectedItemTintColor = UIColor.gray
        }
        .accentColor(.white)
    }
}

#Preview {
    WelcomeView()
}
