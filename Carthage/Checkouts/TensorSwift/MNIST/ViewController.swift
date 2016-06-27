import UIKit
import TensorSwift

class ViewController: UIViewController {
    @IBOutlet private var canvasView: CanvasView!
    
    private let inputSize = 28
    private let classifier = Classifier(path: NSBundle.mainBundle().resourcePath!)

    @IBAction func onPressClassifyButton(sender: UIButton) {
        let input: Tensor
        do {
            let image = canvasView.image
            
            let cgImage = image.CGImage!
            
            var pixels = [UInt8](count: inputSize * inputSize, repeatedValue: 0)
            
            let context  = CGBitmapContextCreate(&pixels, inputSize, inputSize, 8, inputSize, CGColorSpaceCreateDeviceGray()!, CGBitmapInfo.ByteOrderDefault.rawValue)!
            CGContextClearRect(context, CGRect(x: 0.0, y: 0.0, width: CGFloat(inputSize), height: CGFloat(inputSize)))
            
            let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(inputSize), height: CGFloat(inputSize))
            CGContextDrawImage(context, rect, cgImage)
            
            input = Tensor(shape: [Dimension(inputSize), Dimension(inputSize), 1], elements: pixels.map { -(Float($0) / 255.0 - 0.5) + 0.5 })
        }

        let estimatedLabel = classifier.classify(input)

        let alertController = UIAlertController(title: "\(estimatedLabel)", message: nil, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default) { _ in self.canvasView.clear() })
        presentViewController(alertController, animated: true, completion: nil)
    }
}

