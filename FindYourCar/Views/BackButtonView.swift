
import SwiftUI

struct BackButtonView: View {
    @State var black: Bool = true
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Button{
            presentationMode.wrappedValue.dismiss()
        } label: {
            HStack{
                Image(systemName: "chevron.left")
                    .font(.system(size:18, design: .monospaced))
                    .foregroundStyle(black ? .black : .white)
                
                Text("Back")
                    .font(.system(size:18, design: .monospaced))
                    .foregroundStyle(black ? .black : .white)
                    .offset(x: -5)
            }
            
        }
        .offset(x: -UIScreen.main.bounds.width/2.5, y: -UIScreen.main.bounds.width*1.91)
    }
}

#Preview {
    BackButtonView()
}
