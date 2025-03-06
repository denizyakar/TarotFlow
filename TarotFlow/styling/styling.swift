
import SwiftUI

public struct Styling {
    public static var newHeight : CGFloat = 30
    public static var rRheight : CGFloat = 55
    public static var gradientOpacityHigh: Double = 0.95
    public static var gradientOpacityLow: Double = 0.1
 
    
    
    static func customGradient() -> LinearGradient {
        return LinearGradient(
            gradient: Gradient(colors: [
                Color.gray.opacity(Styling.gradientOpacityHigh),
                Color.gray.opacity(Styling.gradientOpacityLow),
                Color.gray.opacity(Styling.gradientOpacityHigh)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    static func customGradient2() -> LinearGradient {
        return LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.04, green: 0.02, blue: 0.25).opacity(0.8),
                Color(red: 0.09, green: 0.02, blue: 0.25).opacity(0.8),
                Color(red: 0.13, green: 0.02, blue: 0.25).opacity(0.8)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    struct customRectangle: View {
        var cornerRadius: CGFloat
        var lineWidth: CGFloat
        var height: CGFloat
        var highOpacity: Double
        var lowOpacity: Double

        var body: some View {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppColors.customGray.opacity(highOpacity),
                            Color.white.opacity(lowOpacity),
                            AppColors.customGray.opacity(highOpacity)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: lineWidth
                )
                .frame(height: height)
            
        }
    }//customrectangle
    
    struct customRectangle2: View {
        var cornerRadius: CGFloat
        var lineWidth: CGFloat
        var height: CGFloat
        var highOpacity: Double
        var lowOpacity: Double

        var body: some View {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.21, green: 0.07, blue: 0.33),
                            Color(red: 0.07, green: 0.1, blue: 0.33)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: lineWidth
                )
                .frame(height: height)
            
        }
    }//customrectangle2
    
}
