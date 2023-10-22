//
//  ContentView.swift
//  ImageClassificationSwiftUI
//
//  Created by Mohammad Azam on 2/3/20.
//  Copyright © 2020 Mohammad Azam. All rights reserved.
//

import SwiftUI
import Vision

struct ContentView: View {
    
    let photos = ["qrcode", "upc", "dl"]
    @State private var currentIndex: Int = 0
    @State private var classification: String = ""
    
    private func performBarcodeDetection(completion: @escaping ([VNBarcodeObservation]?) -> Void) {
        
        guard let image = UIImage(named: photos[currentIndex]),
              let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)),
            let cgImage = image.cgImage else {
                return completion(nil)
        }
        
        let request = VNDetectBarcodesRequest { (request, error) in
            
            let observations = request.results as? [VNBarcodeObservation]
            completion(observations)
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    var body: some View {
        VStack {
            Image(photos[currentIndex])
            .resizable()
                .aspectRatio(contentMode: .fit)
                
            HStack {
                Button("Previous") {
                    
                    if self.currentIndex >= self.photos.count {
                        self.currentIndex = self.currentIndex - 1
                    } else {
                        self.currentIndex = 0
                    }
                    
                    }.padding()
                    .foregroundColor(Color.white)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .frame(width: 100)
                
                Button("Next") {
                    if self.currentIndex < self.photos.count - 1 {
                        self.currentIndex = self.currentIndex + 1
                    } else {
                        self.currentIndex = 0
                    }
                }
                .padding()
                .foregroundColor(Color.white)
                .frame(width: 100)
                .background(Color.gray)
                .cornerRadius(10)
            
                
                
            }.padding()
            
            Button("Classify") {
                
                self.performBarcodeDetection { observations in
                    
                    guard let observations = observations,
                        let observation = observations.first else {
                            return
                    }
                    
                    if let payload = observation.payloadStringValue {
                        self.classification = payload
                    }
                    
                }
                
            }.padding()
            .foregroundColor(Color.white)
            .background(Color.green)
            .cornerRadius(8)
            
            Text(self.classification)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
