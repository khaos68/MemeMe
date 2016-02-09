//
//  MemeDetailsViewController.swift
//  Meme
//
//  Created by Patrizio Palazzetti on 27/01/16.
//  Copyright © 2016 Patrizio Palazzetti. All rights reserved.
//

import UIKit

class MemeDetailsViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var memeImage: UIImageView!
    
    // MARK: - Variables
    var memeIndex: Int?
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set image for meme image in UIImageView
        setImage()
        
        
        // Add right button for add new meme
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "editMeme")
        
        // add an obsever for image refresh in case meme is edited
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshImage:", name:"memeEdited", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Methods
    
    /// editMeme: present the meme editor with the .
    /// - Returns: Void
    func editMeme() {
        
        let editorController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! EditorViewController
        
        if let memeToEditIndex = memeIndex {
            editorController.memeIndexToEdit = memeToEditIndex
        }
        
        presentViewController(editorController, animated: true, completion: nil)
    }
    
    /// refreshImage: refreses de image shown if the meme is modified in the editor view
    /// - Parameter notification: NSNotification
    /// - Returns: Void
    func refreshImage(notification: NSNotification) {
        
        setImage()
        
    }
    
    /// memeToShow: return a meme object for memeIndex in memes array
    /// - Parameters memeIndex: Int
    /// - Returns: Meme
    func memeToShow(memeIndex: Int) -> Meme {
        
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        
        return appDelegate.memes[memeIndex]
        
    }
    
    /// setImage: sets the image in the imageView of the details view
    /// - Returns: Void
    func setImage() {
        
        if let memeToEditIndex = memeIndex {
            
            memeImage.image = memeToShow(memeToEditIndex).memedImage
            memeImage.contentMode = .ScaleAspectFit
            
        }
    }

}
