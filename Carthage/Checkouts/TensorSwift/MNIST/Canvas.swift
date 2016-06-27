import CoreGraphics

struct Canvas {
    var lines: [Line] = [Line()]
    
    mutating func draw(point: CGPoint) {
        lines[lines.endIndex - 1].points.append(point)
    }
    
    mutating func newLine() {
        lines.append(Line())
    }
}