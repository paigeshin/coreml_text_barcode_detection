//
//  ContentView.swift
//  ImageClassificationCustomDSCamera
//
//  Created by Mohammad Azam on 2/6/20.
//  Copyright © 2020 Mohammad Azam. All rights reserved.
//

import SwiftUI
import CoreML
import Vision

struct ContentView: View {
    
    @State private var showSheet: Bool = false
    @State private var showPhotoOptions: Bool = false
    @State private var image: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
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
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                Spacer()
                Image(uiImage: image ?? UIImage(named: "placeholder")!)
                    .resizable()
                    .frame(width: 300, height: 300)
                
                Button("Choose Picture") {
                    // open action sheet
                    self.showSheet = true
                    
                }.padding()
                    .foregroundColor(Color.white)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .actionSheet(isPresented: $showSheet) {
                        ActionSheet(title: Text("Select Photo"), message: Text("Choose"), buttons: [
                            .default(Text("Photo Library")) {
                                // open photo library
                                self.showPhotoOptions = true
                                self.sourceType = .photoLibrary
                            },
                            .default(Text("Camera")) {
                                // open camera
                                self.showPhotoOptions = true
                                self.sourceType = .camera
                            },
                            .cancel()
                        ])
                        
                    }
                
                Spacer()
                
                Button("Classify") {
                    
                    // perform image classification
                    self.performTextClassification()
                    
                }.padding()
                    .foregroundColor(Color.white)
                    .background(Color.green)
                    .cornerRadius(10)
                
            }
            .navigationBarTitle("Text Recognition")
        }.sheet(isPresented: $showPhotoOptions) {
            ImagePicker(image: self.$image, isShown: self.$showPhotoOptions, sourceType: self.sourceType)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
