
import SwiftUI

struct CircleTopView: View {
    var text: String = "Welcome to\nFindYourCar"
    var backgroundColor: Color = Color(red: 55/255, green: 55/255, blue: 55/255)
    var foregroundColor: Color = Color(red: 200/255, green: 200/255, blue: 200/255)
    var reversed: Bool = false

    var body: some View {
        
        ZStack{
            Text(text)
                .frame(width: UIScreen.main.bounds.width)
                .font(.system(size: 50, design: .monospaced))
                .multilineTextAlignment(.center)
                .offset(y:UIScreen.main.bounds.width/3)
                .foregroundColor(backgroundColor)
            
            ZStack{
                Color(backgroundColor)
                
                Text(text)
                    .frame(width: UIScreen.main.bounds.width * 1.5)
                    .offset(x: reversed ? UIScreen.main.bounds.width/2 : -UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.width / 3)
                    .font(.system(size: 50, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .foregroundColor(foregroundColor)
            }
            .clipShape(partCircle(start: .degrees(reversed ? 0 : -270), end: .degrees(reversed ? 90 : -180)))
            .offset(x: reversed ? -UIScreen.main.bounds.width * 0.5 : UIScreen.main.bounds.width * 0.5)
        }
        .frame(height: UIScreen.main.bounds.width * 1.55)
        .position(x: UIScreen.main.bounds.width/2, y:-60)
    }
}

struct partCircle: Shape {
    var start: Angle
    var end: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: center)
        path.addArc(center: center, radius: rect.midX, startAngle: start, endAngle: end, clockwise: false)
        return path
    }
}


#Preview {
    CircleTopView()
}
