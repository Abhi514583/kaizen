import SwiftUI

struct Sparkline: Shape {
    let data: [Double]
    var completion: Double
    
    var animatableData: Double {
        get { completion }
        set { completion = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard data.count > 1 else { return path }
        
        let step = rect.width / CGFloat(data.count - 1)
        var points: [CGPoint] = []
        
        for (index, value) in data.enumerated() {
            let x = CGFloat(index) * step
            let y = rect.height - (CGFloat(value) * rect.height)
            points.append(CGPoint(x: x, y: y))
        }
        
        // Animated path
        path.move(to: points[0])
        let totalPoints = Int(Double(points.count - 1) * completion)
        
        if totalPoints >= 1 {
            for i in 1...totalPoints {
                path.addLine(to: points[i])
            }
            
            // Draw the partial segment
            if totalPoints < points.count - 1 {
                let remainder = (Double(points.count - 1) * completion).truncatingRemainder(dividingBy: 1)
                let p1 = points[totalPoints]
                let p2 = points[totalPoints + 1]
                let dx = p2.x - p1.x
                let dy = p2.y - p1.y
                path.addLine(to: CGPoint(x: p1.x + dx * CGFloat(remainder), y: p1.y + dy * CGFloat(remainder)))
            }
        }
        
        return path
    }
}
