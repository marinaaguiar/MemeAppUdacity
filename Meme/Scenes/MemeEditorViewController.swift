import UIKit
import Photos
import LinkPresentation

// MARK: - UIViewController

class MemeEditorViewController: UIViewController {

    // MARK: Properties

    var activeTextField: UITextField? = nil
    var meme: Meme?
    let id: UUID = UUID.init()

    // MARK: Outlets

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var memeView: UIView!

    // MARK: Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupTextField(textField: topTextField)
        setupTextField(textField: bottomTextField)
        enableCamera()
        enableShareButton()

        // call the 'keyboardWillShow' function when the view controller receive the notification that a keyboard is going to be shown
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        // call the 'keyboardWillHide' function when the view controller receive notification that keyboard is going to be hidden
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }


    //MARK: - Interaction Methods
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        
        guard let memedImage = generateMemedImage() else {
            let alert = UIAlertController(title: "Failed to generate meme image", message: "Please try again.", preferredStyle: .alert)

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
        
        activityController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, arrayReturnedItems: [Any]?, error: Error?) in

            if completed {
                debugPrint("share completed")
                self.saveMeme()
                self.dismiss()
                return
            } else {
                debugPrint("cancel")
                return
            }
        }
        present(activityController, animated: true, completion: nil)
    }


    @IBAction func cancelButtonPressed(_ sender: Any) {

        if self.meme != nil {
            // Declare Alert message
            let alert = UIAlertController(title: "Save Edit Meme", message: "Would you like to save the edited meme?", preferredStyle: .alert)

            // Create Save button with action handler
            let save = UIAlertAction(title: "Save", style: .default) { (action) -> Void in
                DispatchQueue.global(qos: .userInitiated).async {
                    self.saveMeme()
                }
                self.dismiss()
            }

            // Create Cancel button with action handler
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
                alert.dismiss(animated: true)
                debugPrint("cancel button tapped")
            })

            // Create Discard button with action handler
            let discard = UIAlertAction(title: "Discard Changes", style: .destructive, handler: { (action) -> Void in
                alert.dismiss(animated: true)
                self.dismiss()
                debugPrint("discard button tapped")
            })


            //Add Cancel and Discard button to dialog message
            alert.addAction(save)
            alert.addAction(cancel)
            alert.addAction(discard)

            // Present dialog message to user
            self.present(alert, animated: true, completion: nil)

        } else {
            // Declare Alert message
            let alert = UIAlertController(title: "Discard Meme?", message: "You will lose the meme you created", preferredStyle: .alert)

            // Create Cancel button with action handler
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
                alert.dismiss(animated: true)
                debugPrint("cancel button tapped")
            })

            // Create Discard button with action handler
            let discard = UIAlertAction(title: "Discard", style: .destructive) { (action) -> Void in
                alert.dismiss(animated: true)
                self.dismiss()
            }
            //Add Cancel and Discard button to dialog message
            alert.addAction(cancel)
            alert.addAction(discard)

            // Present dialog message to user
            self.present(alert, animated: true, completion: nil)
        }
        debugPrint("create alert")
    }

    @IBAction func pickAnImageFromCameraPressed(_ sender: Any) {
        pickImage(source: .camera)
    }
    
    @IBAction func pickAnImageFromAlbumPressed(_ sender: Any) {
        pickImage(source: .photoLibrary)
    }

    @IBAction func scaleImage(_ sender: UIPinchGestureRecognizer) {
        guard let imagePickerView = imagePickerView else {
          return
        }
        let scale = sender.scale
        imagePickerView.transform = imagePickerView.transform.scaledBy(x: scale, y: scale)
        sender.scale = 1
        debugPrint("gesture scale")

    }

    @IBAction func rotateImage(_ sender: UIRotationGestureRecognizer) {
        guard let imagePickerView = imagePickerView else {
          return
        }
        let rotation = sender.rotation
        imagePickerView.transform = imagePickerView.transform.rotated(by: rotation)
        sender.rotation = 0
        debugPrint("gesture rotate")
    }

    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        stackView.isUserInteractionEnabled = true
        debugPrint("touch")
    }


    //MARK: - Methods

    func enableShareButton() {
        if imagePickerView.image == nil {
            shareButton.isEnabled = false
        } else {
            shareButton.isEnabled = true
        }
    }

    func saveMeme() {

        let generateID = UUID.init()

        guard let topText = topTextField.text,
              let bottomText = bottomTextField.text,
              let image = imagePickerView.image,
              let memeImage = generateMemedImage() else { return }

        if let existingMeme = self.meme {
            let meme = Meme(id: existingMeme.id, createdDate: Date.now, topTexField: topText, bottomTextField: bottomText, originalImage: image, memedImage: memeImage)

            // Add it to the memes array on the application delegate
            let object = UIApplication.shared.delegate
            let appDelegate = object as! AppDelegate
            appDelegate.memes[existingMeme.id] = meme
            debugPrint(meme)
        } else {
            let meme = Meme(id: generateID, createdDate: Date.now, topTexField: topText, bottomTextField: bottomText, originalImage: image, memedImage: memeImage)

            // Add it to the memes array on the application delegate
            let object = UIApplication.shared.delegate
            let appDelegate = object as! AppDelegate
            appDelegate.memes[meme.id] = meme
            debugPrint(meme)
        }

        PHPhotoLibrary.shared().performChanges {
            _ = PHAssetChangeRequest.creationRequestForAsset(from: memeImage)
        } completionHandler: { (success, error) in
            
        }

        debugPrint("image saved")
    }

    func generateMemedImage() -> UIImage? {

        let renderer = UIGraphicsImageRenderer(bounds: memeView.bounds)
        
        return renderer.image { context in
            memeView.layer.render(in: context.cgContext)
            memeView.draw(memeView.layer, in: context.cgContext)
        }
    }
    
    func enableCamera() {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func setupTextField(textField: UITextField) {

        textField.delegate = self

        let textAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 55)!,
            NSAttributedString.Key.strokeWidth: -5
        ]
        textField.defaultTextAttributes = textAttributes
        textField.textAlignment = .center
    }

    func setup() {

        if let existingMeme = self.meme {
            navigationItem.title = "Edit Meme"
            topTextField.text = existingMeme.topTexField
            bottomTextField.text = existingMeme.bottomTextField
            imagePickerView.image = existingMeme.originalImage
        } else {
            navigationItem.title = "Create Meme"
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"
            imagePickerView.image = nil
        }
    }

    func dismiss() {
        if self.meme != nil {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }

    func activityViewController(activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: String!, suggestedSize size: CGSize) -> UIImage! {
        return UIImage(named: "AppIcon")
    }
}

    //MARK: - UIImagePickerControllerDelegate

extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let pickedImage = info[UIImagePickerController.InfoKey.init(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            imagePickerView.contentMode = .scaleAspectFit
            imagePickerView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        debugPrint("cancel")
        picker.dismiss(animated: true, completion: nil)
    }

    func pickImage(source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
        shareButton.isEnabled = true
    }
}

    //MARK: - UITextFieldDelegate

extension MemeEditorViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.activeTextField = textField

        if topTextField.text == "TOP" {
            textField.text = ""
        } else if bottomTextField.text == "BOTTOM" {
            textField.text = ""
        }
        setupTextField(textField: textField)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        
        activeTextField = nil

        if topTextField.text == "" {
            textField.text = "TOP"
        } else if bottomTextField.text == "" {
            textField.text = "BOTTOM"
        }
        setupTextField(textField: textField)
        stackView.isUserInteractionEnabled = false
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
            self.view.frame.origin.y = -keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        // move back the root view origin to zero
        self.view.frame.origin.y = 0
    }
}

    //MARK: - UIGestureRecognizerDelegate

extension MemeEditorViewController: UIGestureRecognizerDelegate {

    func applyGestureRecognizer() {
        
        let rotation = UIRotationGestureRecognizer(target: self , action: #selector(rotateImage(_:)))
        rotation.delegate = self
        imagePickerView.addGestureRecognizer(rotation)

        let zoomGesture = UIPinchGestureRecognizer(target: self , action: #selector(scaleImage(_:)))
        zoomGesture.delegate = self
        imagePickerView.addGestureRecognizer(zoomGesture)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
//             shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//       // Don't recognize a single tap until a double-tap fails.
//       if gestureRecognizer == tapGesture &&
//              otherGestureRecognizer == scaleImage(UIPinchGestureRecognizer) {
//          return true
//       }
//       return false
//    }
}
