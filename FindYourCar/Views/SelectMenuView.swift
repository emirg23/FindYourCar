
import SwiftUI
import FirebaseFirestore

struct SelectMenuView: View {
    @ObservedObject var vM: SelectMenuViewModel
    @Binding var isClicked: Bool
    @Binding var lastSelected: String
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text(vM.title)
                .font(.system(size: 16, design: .monospaced))
                .foregroundStyle(.black)
            
            VStack(alignment: .leading) {
                
                HStack {
                    Text(vM.displayingText)
                        .font(.system(size: 16, design: .monospaced))
                        .padding()
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isClicked ? -180 : 0))
                        .font(.system(size: 16, design: .monospaced))
                        .foregroundStyle(.black)
                        .padding()
                }
                .frame(width: UIScreen.main.bounds.width / 2.07, height: vM.heightValue)
                .background(Color.gray)
                .cornerRadius(10)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.snappy(duration: 0.4)) {
                        isClicked.toggle()
                    }
                }
                
                ExtractedView(vM: vM, isClicked: $isClicked, lastSelected: $lastSelected)
            }
            .onChange(of: vM.displayingText){
                if !isClicked{
                    lastSelected = vM.displayingText
                }
            }
            .frame(width: UIScreen.main.bounds.width / 2.07, alignment: .leading)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .background(vM.backgroundColor)
    }
}

#Preview {
    SelectMenuView(vM: SelectMenuViewModel(), isClicked: .constant(false), lastSelected: .constant("All makes"))
}

struct ExtractedView: View {
    @ObservedObject var vM: SelectMenuViewModel
    @Binding var isClicked: Bool
    @Binding var lastSelected: String

    var body: some View {
        if isClicked {
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    // last selected option
                    HStack {
                        Text(lastSelected)
                            .foregroundColor(.black)
                            .font(.system(size: 16, design: .monospaced))
                            .frame(height: vM.heightValue, alignment: .leading)
                            .padding()
                            .opacity(0.3)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .font(.subheadline)
                            .padding()
                            .opacity(vM.displayingText == lastSelected ? 1 : 0)
                    }
                    .frame(width: UIScreen.main.bounds.width / 2.07, height: vM.heightValue, alignment: .leading)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .onTapGesture {
                        withAnimation(.bouncy(duration: 0.4)) {
                            isClicked = false
                        }
                    }
                    
                    ForEach(vM.options, id: \.self) { option in
                        
                        if option != lastSelected {
                            HStack {
                                Text(option)
                                    .foregroundColor(.black)
                                    .font(.system(size: 16, design: .monospaced))
                                    .frame(height: vM.heightValue, alignment: .leading)
                                    .padding()
                                    .opacity(0.9)
                            }
                            .frame(width: UIScreen.main.bounds.width / 2.07, height: vM.heightValue, alignment: .leading)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .onTapGesture {
                                vM.displayingText = option
                                lastSelected = vM.displayingText
                                
                                withAnimation(.bouncy(duration: 0.4)) {
                                    isClicked = false
                                }
                            }
                        }
                    }
                }
                .transition(.move(edge: .bottom))
            }
            .frame(height: CGFloat(vM.options.count) * vM.heightValue < vM.heightValue * 4 ? CGFloat(vM.options.count) * (vM.heightValue + 3) : vM.heightValue * 4)
        }
    }
}
