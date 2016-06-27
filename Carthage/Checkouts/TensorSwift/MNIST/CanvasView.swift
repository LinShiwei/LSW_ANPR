import UIKit

class CanvasView: UIView {
    private(set) var canvas: Canvas
    
    required init?(coder: NSCoder) {
        canvas = Canvas()
        super.init(coder: coder)
        
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(CanvasView.onPanGesture(_:))))
    }
    
    var image: UIImage {
        UIGraphicsBeginImageContext(bounds.size)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }

    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        for line in canvas.lines {
            CGContextSetLineWidth(context, 20.0)
            CGContextSetStrokeColorWithColor(context, UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).CGColor)
            CGContextSetLineCap(context, .Round)
            CGContextSetLineJoin(context, .Round)
            for (index, point) in line.points.enumerate() {
                if index == 0 {
                    CGContextMoveToPoint(context, point.x, point.y)
                } else {
                    CGContextAddLineToPoint(context, point.x, point.y)
                }
            }
        }
        CGContextStrokePath(context)
    }
    
    func onPanGesture(gestureRecognizer: UIPanGestureRecognizer) {
        canvas.draw(gestureRecognizer.locationInView(self))
        if gestureRecognizer.state == .Ended {
            canvas.newLine()
        }
        
        setNeedsDisplay()
    }
    
    func clear() {
        canvas = Canvas()
        setNeedsDisplay()
    }
}