### Text Detection

- Detect Text on Image.
- But it's not OCR. It can't extract Text.

### Barcode Detection

- Barcode contains Data(Payload)
- Extracing Payload

### Genereate your barcode

- https://github.com/mickeymouse20/drivers-license-barcode-generator

- https://www.the-qrcode-generator.com/

- https://barcode.tec-it.com/en/UPCA

### Text Detection Code

- It does't not extract text!
- It simply detects text.

```swift
    private func performTextClassification() {
        // CGImagePropertyOrientation.right => rotate 90 degrees
        guard
            let img = self.image,
            let cgImage = img.cgImage,
            let orientation = self.sourceType == .camera ? CGImagePropertyOrientation.right : CGImagePropertyOrientation(rawValue: UInt32(img.imageOrientation.rawValue))
        else {
            print("Invalid Image")
            return
        }
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("No Results")
                return
            }
            DispatchQueue.global().async {
                guard let result = img.drawOnImage(observations: observations) else { return }
                DispatchQueue.main.async {
                    self.image = result
                }
            }
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }

    }
```

```swift
import Foundation
import UIKit
import Vision

extension UIImage {

    func drawOnImage(observations: [VNRecognizedTextObservation]) -> UIImage? {

        UIGraphicsBeginImageContext(self.size)

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))

        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(10.0)


        let transform = CGAffineTransform(scaleX: 1, y: -1)
        .translatedBy(x: 0, y: -self.size.height)

        for observation in observations {

            let rect = observation.boundingBox
            let normalizedRect = VNImageRectForNormalizedRect(rect, Int(self.size.width), Int(self.size.height))
                .applying(transform)

            context.stroke(normalizedRect)
        }

        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return result

    }

}

```

### Barcode Detection Code

```swift
    private func performBarcodeDetection(completion: @escaping ([VNBarcodeObservation]?) -> Void) {
        guard
            let image = UIImage(named: self.photos[self.currentIndex]),
            let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)),
            let cgImage = image.cgImage else {
            print("Not Valid Image")
            return completion(nil)
        }

        let request = VNDetectBarcodesRequest(completionHandler: { request, error in
            let observations = request.results as? [VNBarcodeObservation]
            completion(observations)
        })

        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])

        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
```

```swift
      self.performBarcodeDetection { observvations in
            guard
                let observvations = observvations,
                let observation = observvations.first,
                let payload = observation.payloadStringValue
            else {
                return
            }
            self.classification = payload
        }
```
