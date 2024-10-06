
import Foundation
import SwiftUI
import FirebaseFirestore

class SelectMenuViewModel: ObservableObject {
    @Published var displayingText: String = "All makes"
    @Published var options: [String] = []
    @Published var dataLoaded = false
    @Published var backgroundColor = Color(red: 200/255, green: 200/255, blue: 200/255)
    @Published var title: String = "Makes"
    var heightValue: CGFloat = UIScreen.main.bounds.width/12
    
    init(displayingText: String = "All makes",
             options: [String] = [],
             isClicked: Bool = false,
             lastSelected: String = "All makes",
             dataLoaded: Bool = false,
             backgroundColor: SwiftUI.Color = Color(red: 200/255, green: 200/255, blue: 200/255),
             title: String = "Makes",
         heightValue: CGFloat = UIScreen.main.bounds.width / 12) {
        
        self.displayingText = displayingText
        self.options = options
        self.dataLoaded = dataLoaded
        self.backgroundColor = backgroundColor
        self.title = title
        self.heightValue = heightValue
    }
    
    
    
}
