//
//  ViewController.swift
//  Meme
//
//  Created by Marina Aguiar on 3/9/22.
//
import UIKit
import Photos
import LinkPresentation

class ViewController: UIViewController {
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var memeView: UIView!
        
    var activeTextField : UITextField? = nil
            
    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.delegate = self
        bottomTextField.delegate = self
        setupPlaceHolder()
        setupFont()
        enableCamera()
        shareButton.isEnabled = false
        
        
        // call the 'keyboardWillShow' function when the view controller receive the notification that a keyboard is going to be shown
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
      
          // call the 'keyboardWillHide' function when the view controller receive notification that keyboard is going to be hidden
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: - Methods
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        
        guard let memedImage = generateMemedImage() else {
            let alert = UIAlertController(
                title: "Failed to generate meme image",
                message: "Please try again.",
                preferredStyle: .alert
            )
            
            alert.addAction(.init(title: "OK", style: .default, handler: { _ in
                        alert.dismiss(animated: true)}))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let items = [memedImage]
        let activityController = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        activityController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed:
        Bool, arrayReturnedItems: [Any]?, error: Error?) in
            if completed {
                print("share completed")
                self.saveImage()
                return
            } else {
                print("cancel")
            }
        }
        present(activityController, animated: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imagePickerView.image = nil
        shareButton.isEnabled = false
    }
    
    @IBAction func pickAnImageFromCameraPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        shareButton.isEnabled = true
    }
    
    @IBAction func pickAnImageFromAlbumPressed(_ sender: Any) {
        let imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
        shareButton.isEnabled = true
    }

    func saveImage() {
        
        let memeImage = generateMemedImage()
        guard let memeImage = memeImage else { return }
        PHPhotoLibrary.shared().performChanges {
            _ = PHAssetChangeRequest.creationRequestForAsset(from: memeImage)
        } completionHandler: { (success, error) in
            
        }
        print("image saved")
    }
    
    func generateMemedImage() -> UIImage? {

        let renderer = UIGraphicsImageRenderer(bounds: memeView.bounds)
        
        return renderer.image { context in
            memeView.layer.render(in: context.cgContext)
            memeView.draw(memeView.layer, in: context.cgContext)
        }
    }
    
    func enableCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            cameraButton.isEnabled = true
        } else {
            cameraButton.isEnabled = false
        }
    }
        
    func setupFont() {
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 55)!,
            NSAttributedString.Key.strokeWidth: -5
        ]
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
    }
    
    func setupPlaceHolder() {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
    }
        
    func activityViewController(activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: String!, suggestedSize size: CGSize) -> UIImage! {
        return UIImage(named: "AppIcon")
    }
}

    
//MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.init(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            imagePickerView.contentMode = .scaleAspectFit
            imagePickerView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancel")
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.activeTextField = textField

        if topTextField.text == "TOP" {
            textField.text = ""
        } else if bottomTextField.text == "BOTTOM" {
            textField.text = ""
        }
        setupFont()
    }
        
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.activeTextField = nil

        if topTextField.text == "" {
            textField.text = "TOP"
        } else if bottomTextField.text == "" {
            textField.text = "BOTTOM"
        }
        setupFont()
    }

        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           // if keyboard size is not available for some reason, dont do anything
           return
        }
        
        var shouldMoveViewUp = false

        // if active text field is not nil
        if let activeTextField = activeTextField {

          let bottomTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
          
          let topOfKeyboard = self.view.frame.height - keyboardSize.height

          // if the bottom of Textfield is below the top of keyboard, move up
          if bottomTextField > topOfKeyboard {
            shouldMoveViewUp = true
          }
        }

        if(shouldMoveViewUp) {
          self.view.frame.origin.y = 0 - keyboardSize.height
        }
      }
    
    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
      self.view.frame.origin.y = 0
    }
}
