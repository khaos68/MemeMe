//
//  ViewController.swift
//  Meme
//
//  Created by Patrizio Palazzetti on 4/01/16.
//  Copyright © 2016 Patrizio Palazzetti. All rights reserved.
//

import UIKit
import Photos

class EditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    
    // MARK: - Oulets
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var actionBarButton: UIBarButtonItem!
    
    // MARK: - Variables
    
    private var keyboardVisible: Bool = false // Just to know if the keyboard is already showed to avoid rotation bug
    private var viewYPosition: CGFloat = 0.0 // Used to store original frame's origins' y value

    // variable to store the index of the meme to edit
    var memeIndexToEdit: Int?
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        //Add Tap gesture recognizer
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)

    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Enable camera button if camera is available
        cameraBarButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        setTextFieldsAttributesFor(topTextField, strokeColor: UIColor.blackColor(), foregroundColor: UIColor.whiteColor(), strokeWidth: -3.0, placeHolderText: "TOP")
        
        setTextFieldsAttributesFor(bottomTextField, strokeColor: UIColor.blackColor(), foregroundColor: UIColor.whiteColor(), strokeWidth: -3.0, placeHolderText: "BOTTOM")
        
        // Suscribe to Keyboard notifications
        subscribeToKeyboardNotifications()
        
        // Record view original Y position
        viewYPosition = view.frame.origin.y
        
        if let memeIndex = memeIndexToEdit {
            
            // TODO: code to review and encapsulate
            
            let meme = getDelegate().memes[memeIndex]
            
            topTextField.text = meme.topString
            bottomTextField.text = meme.bottomString
            imagePickerView.image = meme.originalImage
            
            actionBarButton.enabled = true
            
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        // Unsuscribe from keyboard notifications
        unsubscribeFromKeyboardNotifications()
    }
    
    // Needed for hidding the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func pickAnImageFromCamera(sender: UIBarButtonItem) {
        
        let authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        
        switch authorizationStatus {
        case .NotDetermined:
            // permission dialog not yet presented, request authorization
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo,
                completionHandler: { (granted:Bool) -> Void in
                    if granted {
                        self.getImageFromCamera()
                    }
                    else {
                        print("access denied", terminator: "")
                    }
            })
        case .Authorized:
            getImageFromCamera()
        case .Denied, .Restricted:
            alertToEncourageCameraAccess()
        }
        
        enableActionButtonIfWeHaveImage()
    }

    @IBAction func pickAnImageFromAlbum(sender: UIBarButtonItem) {
    
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(pickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func resetView(sender: UIBarButtonItem) {
        
        topTextField.text = ""
        bottomTextField.text = ""
        dismissKeyboard()
        imagePickerView.image = nil
        actionBarButton.enabled = false
        
        memeIndexToEdit = nil
        
        NSNotificationCenter.defaultCenter().postNotificationName("memeEdited", object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        
        let generatedImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [generatedImage], applicationActivities: nil)
        
        // let handler: UIActivityViewControllerCompletionWithItemsHandler = UIActivityViewControllerCompletionWithItemsHandler()
        
        // controller.completionWithItemsHandler = {self.dismissViewControllerAnimated(true, completion: nil)}
        
        presentViewController(controller, animated: true, completion: {
            self.saveMeme(generatedImage)
        })
        
    }
    
    // MARK: - Delegates

    // MARK: ImagePickerController Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            imagePickerView.image = image
            imagePickerView.contentMode = .ScaleAspectFit
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        enableActionButtonIfWeHaveImage()
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        dismissViewControllerAnimated(true, completion: nil)
        enableActionButtonIfWeHaveImage()
        
    }
    
    // MARK: Textfield delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Methods
    
    // MARK: Keyboard visibility related methods
    
    /// dismissKeyboard: Calls this function when the tap is recognized to dismiss the keyboard.
    /// - Returns: Void
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    /// subscribeToKeyboardNotifications: suscribe to keyboard notifications.
    /// - Returns: Void
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /// unsubscribeFromKeyboardNotifications: unsuscribe to keyboard notifications.
    /// - Returns: Void
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    /// keyboardWillShow: called before keyboard is shown. It will move the view to make space for the keyboard.
    /// - Parameter notification: NSNotification
    /// - Returns: Void
    func keyboardWillShow(notification: NSNotification) {
        
        if keyboardVisible == true {
            // hide first, this is triggered by device rotation
            view.frame.origin.y = viewYPosition
        }
        
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y -= getKeyboardHeight(notification)
            keyboardVisible = true
        }
        
    }
    
    /// keyboardWillHide: called before keyboard is hidden. It will move the view to its original position.
    /// - Parameter notification: NSNotification
    /// - Returns: Void
    func keyboardWillHide(notification: NSNotification) {
        
        if bottomTextField.isFirstResponder() && keyboardVisible == true {
            view.frame.origin.y += getKeyboardHeight(notification)
            keyboardVisible = false
        }
        
        enableActionButtonIfWeHaveImage()
        
    }
    
    /// getKeyboardHeight: calculates the keyboard height.
    /// - Parameter notification: NSNotification
    /// - Returns: CGFloat
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // MARK: Meme creation related methods
    
    /// saveMeme: create a meme object and init it with meme info.
    /// - Parameter: memeImage: UIImage (used to avoid regenerating the UIImage)
    /// - Returns: Void
    func saveMeme(memeImage: UIImage) {
        
        // TODO: Code to review and encapsulate
        
        let appDelegate = getDelegate()
        
        if let memeIndex = memeIndexToEdit {
            
            appDelegate.memes[memeIndex].bottomString = bottomTextField.text!
            appDelegate.memes[memeIndex].topString = topTextField.text!
            appDelegate.memes[memeIndex].originalImage = imagePickerView.image!
            appDelegate.memes[memeIndex].memedImage = memeImage
            
        } else {
            
            var myMeme: Meme = Meme()
            
            myMeme.bottomString = bottomTextField.text!
            myMeme.topString = topTextField.text!
            myMeme.originalImage = imagePickerView.image!
            myMeme.memedImage = memeImage
            
            appDelegate.memes.append(myMeme)
        }
        
    }
    
    /// generateMemedImage: returns a meme image similar to what is shown in the device.
    /// - Returns: UIImage
    func generateMemedImage() -> UIImage
    {
        // hide toolbars
        toolbarsHidden(true)
        
        // Hide textfields if text is empty
        topTextField.hidden = (topTextField.text == "")
        bottomTextField.hidden = (bottomTextField.text == "")
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // restore textfields
        topTextField.hidden = false
        bottomTextField.hidden = false
        
        // restore toolbars
        toolbarsHidden(false)
        
        return memedImage
    }
    
    /// toolbarsHidden: used to set the hidden condition of both toolbars.
    /// - Parameter hide: Bool
    /// - Returns: Void
    func toolbarsHidden(hide: Bool) {
        
        topToolbar.hidden = hide
        bottomToolbar.hidden = hide
    }

    
    // MARK: Camera access check related methods
    
    /// getImageFromCamera: used to get an image using the device's camera.
    /// - Returns: Void
    func getImageFromCamera() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    /// alertToEncourageCameraAccess: used to get autorithation for the camera. Snipped by Alvin George ( http://stackoverflow.com/questions/26595343/determine-if-the-access-to-photo-library-is-set-or-not-ios-8 )
    /// - Returns: Void
    func alertToEncourageCameraAccess()
    {
        //Camera not available - Alert
        let internetUnavailableAlertController = UIAlertController (title: "Camera Unavailable", message: "Please check to see if it is disconnected or in use by another application", preferredStyle: .Alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .Destructive) { (_) -> Void in
            let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                dispatch_async(dispatch_get_main_queue()) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        internetUnavailableAlertController .addAction(settingsAction)
        internetUnavailableAlertController .addAction(cancelAction)
        presentViewController(internetUnavailableAlertController , animated: true, completion: nil)
    }
    
    // MARK: - Other Methods
    
    /// enableActionButtonIfWeHaveImage: used to enable/disable action button.
    /// - Returns: Void
    func enableActionButtonIfWeHaveImage() {
    
        if (imagePickerView.image != nil) && (topTextField.text != "" || bottomTextField.text != "") {
            actionBarButton.enabled = true
        } else {
            actionBarButton.enabled = false
        }
    }
    
    
    /// setTextFieldsAttributesFor: set textfield parameters.
    /// - Parameter field: UITextField
    /// - Parameter strokeColor: UIColor
    /// - Parameter foregroundColor: UIColor
    /// - Parameter strokeWidth: Float
    /// - Parameter placeHolderText: String
    /// - Returns: Void
    func setTextFieldsAttributesFor(field: UITextField, strokeColor: UIColor, foregroundColor: UIColor, strokeWidth: Float, placeHolderText: String) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName : strokeColor,
            NSForegroundColorAttributeName : foregroundColor,
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : NSNumber(float: strokeWidth),
            NSParagraphStyleAttributeName : paragraphStyle
        ]
        
        let memePlaceholderTextAttributes = [
            NSStrokeColorAttributeName : UIColor.darkGrayColor(),
            NSForegroundColorAttributeName : UIColor.lightGrayColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : NSNumber(float: -1.0),
            NSParagraphStyleAttributeName : paragraphStyle
        ]
        
        field.defaultTextAttributes = memeTextAttributes
        field.attributedPlaceholder = NSAttributedString(string: placeHolderText, attributes: memePlaceholderTextAttributes)
        
    }
    
    /// getMemes: Obtain the Memes array
    /// - Returns: [Memes] An array with memes objects
    func getDelegate() -> AppDelegate {
        
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        
        return appDelegate
        
    }
}

