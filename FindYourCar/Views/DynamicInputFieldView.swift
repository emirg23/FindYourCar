
import SwiftUI

struct DynamicInputFieldView: View {
    @Binding var inputting: Bool
    @Binding var value: String
    @Binding var animate: Bool
    @State var fieldText = "name"
    @State var widthBackground: CGFloat = 10
    @State var onlyNumber: Bool = false

    var body: some View {
        
        HStack{
            ZStack(alignment: .leading){
                
                Color(inputting ?
                      Color(red: 120/255, green: 120/255, blue: 120/255) :
                        Color(red: 150/255, green: 150/255, blue: 150/255)
                )
                .opacity(animate ? 1 : 0)
                
                TextField(fieldText, text: $value)
                
                    .opacity(animate ? 1 : 0)
                    .foregroundColor(.black)
                    .font(.system(size: 40, design: .monospaced))
                    .frame(width: UIScreen.main.bounds.width)
                    .padding(.horizontal)
                    .autocorrectionDisabled(true)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 4)) {
                            animate = true
                        }
                    }
                    .multilineTextAlignment(.center)
                    .onChange(of: value) { newValue in
                        if newValue.count > 15 {
                            value = String(newValue.prefix(15))
                        }
                        
                        if newValue.last == " " && value.dropLast().last == " " {
                            value = String(newValue.dropLast())
                        }
                        
                        if onlyNumber {
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                value = filtered
                                
                            }
                        }
                        value = value.replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)
                        
                        widthBackground = CGFloat(self.value.count) * 25 + 10
                        
                        withAnimation(.easeInOut(duration: 1)) {
                            inputting = !value.trimmingCharacters(in: .whitespaces).isEmpty
                        }
                        
                    }
            }
        }
        .frame(width: widthBackground == 10 ?
        CGFloat(self.fieldText.count) * 25 + 10 :
        widthBackground,
        height: 50
        )
        .cornerRadius(8)
    }
}

#Preview {
    DynamicInputFieldView(inputting: .constant(false), value: .constant(""), animate: .constant(true))
}
