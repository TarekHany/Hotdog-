//
//  ViewController.swift
//  SeaFood
//
//  Created by Tarek Hany on 10/2/20.
//  Copyright © 2020 Tarek Hany. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
            
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage to CIImage")
            }
            detect(image: ciimage)
            
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    func detect(image: CIImage){    
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Could not load CoreML Model")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                }
            }
            
        }
        guard let cgImg = image.cgImage else {
            fatalError("can't convert image")
        }
        let handler = VNImageRequestHandler(cgImage: cgImg)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

