
import SwiftUI

struct ListingsSelectMenuView: View {
    
    @Binding var displayingText: String
    @State var options: [String] = []
    @Binding var isClicked: Bool
    @State var lastSelected: String
    @State var dataLoaded = false
    @State var backgroundColor = Color(red: 200/255, green: 200/255, blue: 200/255)
    var heightValue: CGFloat = UIScreen.main.bounds.width/20
    
    var body: some View {
        
        VStack(alignment: .leading){
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(displayingText)
                        .font(.system(size: 11, design: .monospaced))
                        .padding(5)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isClicked ? -180 : 0))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.black)
                        .padding(5)
                }
                .frame(width: UIScreen.main.bounds.width / 4, height: heightValue)
                .background(Color.gray)
                
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.snappy(duration: 0.4)) {
                        isClicked.toggle()
                    }
                }
                
                if isClicked {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack{
                                Text(lastSelected)
                                    .foregroundColor(.black)
                                    .font(.system(size: 11, design: .monospaced))
                                    .frame(height: heightValue, alignment: .leading)
                                    .padding(5)
                                    .opacity(0.3)
                                
                                Spacer()
                                
                                Image(systemName: "checkmark")
                                    .font(.system (size: 11))
                                    .font(.subheadline)
                                    .padding(5)
                            }
                                .frame(width: UIScreen.main.bounds.width / 4, height: heightValue, alignment: .leading)
                                .background(Color.gray.opacity(0.2))
                                
                                .onTapGesture {
                                    withAnimation(.bouncy(duration: 0.4)) {
                                        isClicked = false
                                    }
                                }
                            
                            
                            ForEach(options, id: \.self) { option in
                                if option != lastSelected{
                                    HStack {
                                        Text(option)
                                            .foregroundColor(.black)
                                            .font(.system(size: 11, design: .monospaced))
                                            .frame(height: heightValue, alignment: .leading)
                                            .padding(5)
                                            .opacity(0.9)
                                    }
                                    .frame(width: UIScreen.main.bounds.width / 4, height: heightValue, alignment: .leading)
                                    .background(Color.gray.opacity(0.2))
                                    
                                    .onTapGesture {
                                        displayingText = option
                                        withAnimation(.bouncy(duration: 0.4)) {
                                            isClicked = false
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4){
                                                lastSelected = displayingText
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .transition(.move(edge: .bottom))
                    }
                    .frame(height: CGFloat(options.count) <= 2 ? CGFloat(options.count) * (heightValue + 3) : heightValue * 2.6)
                }
            }
            .onChange(of: displayingText){
                if !isClicked{
                    lastSelected = displayingText
                }
            }
            .frame(width: UIScreen.main.bounds.width / 4, alignment: .leading)
            .onChange(of: isClicked) {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // closing keyboard

            }
        }
        .onAppear(){
            if !dataLoaded{
                lastSelected = displayingText
                dataLoaded = true
            }
        }
        .background(backgroundColor)
    }
}

#Preview {
    ListingsSelectMenuView(displayingText: .constant("All makes"), isClicked: .constant(false), lastSelected: "All makes")
}
