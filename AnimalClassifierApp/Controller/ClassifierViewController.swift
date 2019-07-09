//
//  ClassifierViewController.swift
//  AnimalClassifierApp
//
//  Created by AHMED on 3/14/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ClassifierViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var classificationlbl: UILabel!
  
  lazy var classificationRequest: VNCoreMLRequest = {
    do{
      let model = try VNCoreMLModel(for: AnimalClassifier().model)
      
      let request = VNCoreMLRequest(model: model, completionHandler: {[weak self]request, error in
        self?.processClassifications(for: request, error: error)
      })
      request.imageCropAndScaleOption = .centerCrop
      return request
    }catch{
      fatalError("Failed to load vision ML model: \(error)")
    }
  }()
  
  func processClassifications(for request: VNRequest, error: Error?) {
    DispatchQueue.main.async {
      guard let classifications = request.results as? [VNClassificationObservation] else {
        self.classificationlbl.text = "Unable to classify image.\n\(error?.localizedDescription ?? "Error")"
        return
      }
      
      if classifications.isEmpty {
        self.classificationlbl.text = "Nothing recognized."
      } else {
        let topClassifications = classifications.prefix(2)
        let descriptions = topClassifications.map { classification in
          return String(format: "%.2f", classification.confidence * 100) + "% – " + classification.identifier
        }
        self.classificationlbl.text = "Classification:\n" + descriptions.joined(separator: "\n")
      }
    }
  }
  
  func updateClassifications(for image: UIImage) {
    classificationlbl.text = "Classifying..."
    
    guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)), let ciImage = CIImage(image: image) else {
      displayError()
      return
    }
    
    DispatchQueue.global(qos: .userInteractive).async {
      let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
      do {
        try handler.perform([self.classificationRequest])
      } catch {
        print("Failed to perform classification.\n\(error.localizedDescription)")
      }
    }
  }
  
  func displayError() {
    classificationlbl.text = "Something went wrong...\n Please try again."
  }
  
  @IBAction func cameraBtnWasPressed(_ sender: Any) {
    guard UIImagePickerController.isSourceTypeAvailable(.camera) else{
      presentPhotoPicker(sourceType: .photoLibrary)
      return
    }
    
    let photoSourcePickre = UIAlertController()
    let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
      self.presentPhotoPicker(sourceType: .camera)
    }
    
    let choosePhotoAction = UIAlertAction(title: "Choose Photo", style: .default) { _ in
      self.presentPhotoPicker(sourceType: .photoLibrary)
    }
    
    photoSourcePickre.addAction(takePhotoAction)
    photoSourcePickre.addAction(choosePhotoAction)
    photoSourcePickre.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    present(photoSourcePickre, animated: true, completion: nil)
  }
  
  func presentPhotoPicker(sourceType: UIImagePickerController.SourceType){
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.sourceType = sourceType
    present(picker, animated: true, completion: nil)
  }
  
}

extension ClassifierViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    
    guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else{
      fatalError("No image required")
    }
    imageView.image = image
    updateClassifications(for: image)
  }
}
