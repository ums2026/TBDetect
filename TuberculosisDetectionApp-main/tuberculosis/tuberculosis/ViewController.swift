//
//  ViewController.swift
//  tuberculosis
//
//  Created by Aiden Wen on 12/26/22.
//

import CoreML
import UIKit // import package

class ViewController: UIViewController{ // default, viewing on iphone
    
//    @IBOutlet var imageView: UIImageView! // outlet for our image deleted
    @IBOutlet var button: UIButton! // outlet for our button
    
    private let imageView: UIImageView = {  // added
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = { // added
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Select Image"
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    private let instructions: UILabel = {
        let instructions = UILabel()
        instructions.textAlignment = .center
        instructions.text = "Instructions: Upload or take a picture of stained sputum smear for fast tuberculosis diagnosis."
        instructions.numberOfLines = 0
        instructions.textColor = .white
        return instructions
    }()
    
    private let result: UILabel = {
        let result = UILabel()
        result.textAlignment = .center
        result.text = "Tuberculosis Diagnosis: N/A"
        result.numberOfLines = 0
        result.textColor = .white
        return result
    }()

    override func viewDidLoad() { // default
        super.viewDidLoad() // default
        
        imageView.backgroundColor = .secondarySystemBackground // the color of the image background
        
        button.backgroundColor = .systemBlue // what color is the button
        button.setTitle("Take Picture",
                        for: .normal) // what is on the button
        button.setTitleColor(.white,
                        for: .normal) // color of the words
        
        view.addSubview(label)
        view.addSubview(imageView)
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(didTapLabel))
        tap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        
        label.backgroundColor = .systemBlue
        
        view.addSubview(instructions)
        view.addSubview(result)
    }
    
    @objc func didTapLabel(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    override func viewDidLayoutSubviews() { // added
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(x: 20, y: view.safeAreaInsets.top,
                                 width: view.frame.size.width-40,
                                 height: view.frame.size.width-40)
        label.frame = CGRect(x: 30, y: view.safeAreaInsets.top+(view.frame.size.width-40)+300,
                             width: view.frame.size.width-60,
                            height: 52)
        instructions.frame = CGRect(x:20, y: 450, width: view.frame.size.width - 40, height: 52)
        result.frame = CGRect(x:20, y: 600, width: view.frame.size.width - 40, height: 52)
    }
    
    @IBAction func didTapButton() { // function for our button, actually make it work
        let picker = UIImagePickerController() // variable for what will be shown
        picker.sourceType = .camera // what is the displayed going to be
        picker.delegate = self // get the image out of picker
        present(picker, animated: true) // actually show the picker
    }
    
    private func analyzeImage(image: UIImage?){ // sceneImage input, sceneLabelProbs output, sceneLabel output
        guard let buffer = image?.resize(size: CGSize(width: 299, height: 299))?
                .getCVPixelBuffer() else{
            return
        }
        
        do{
            let config = MLModelConfiguration()
            let model = try TBImageClassifierModel1(configuration: config)
            let input = TBImageClassifierModel1Input(image: buffer)
            
            let output = try model.prediction(input: input)
            let text = output.classLabel
            if (text == "infected"){
                result.text = "Tuberculosis Diagnosis: Infected"
                result.textColor = .red
            }
            else{
                result.text = "Tuberculosis Diagnosis: Normal"
                result.textColor = .white
            }
        }
        catch{
            print(error.localizedDescription)
        }
    }

}

extension ViewController: UIImagePickerControllerDelegate, // allow it to assign to self
    UINavigationControllerDelegate {
            
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { // dismiss the picker
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil) // dismiss the picker!
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? // reference what image is, migth be nill
            UIImage else{
            return
        }
        imageView.image = image // view what we just took an image of
        analyzeImage(image: image)
    }
}
