//
//  MemesCollectionViewController.swift
//  Meme
//
//  Created by Patrizio Palazzetti on 27/01/16.
//  Copyright © 2016 Patrizio Palazzetti. All rights reserved.
//

import UIKit

class MemesCollectionViewController: UICollectionViewController {

    // MARK: Outlets
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
  
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add right button for add new meme
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addMeme")
        
        // add an obsever for collectionView refresh in case meme is edited/saved
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshView:", name:"memeEdited", object: nil)
        
        flowLayoutSettings(self.view.frame.size)

    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        flowLayoutSettings(size)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.hidden = false
        flowLayoutSettings(self.view.frame.size)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    
    /// flowLayoutSettings: change the CollectionView layout
    /// - Parameter size: CGSize
    /// - Returns: Void
    func flowLayoutSettings(size: CGSize) {
        
        let space: CGFloat = 3.0
        var cellsPerRow: CGFloat = 0.0
        var dimension: CGFloat = 0.0
        
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            cellsPerRow = 6.0
        } else {
            cellsPerRow = 3.0
        }
        
        dimension = (size.width - ((cellsPerRow - 1.0) * space)) / cellsPerRow
        
        if let theFlowLayout = flowLayout {
            
            theFlowLayout.minimumInteritemSpacing = space
            theFlowLayout.minimumLineSpacing = space
            theFlowLayout.itemSize = CGSizeMake(dimension, dimension)
            
        }
        
        if let myCollectionView = collectionView {
            
            myCollectionView.collectionViewLayout.invalidateLayout()
            
            myCollectionView.reloadData()
            
            myCollectionView.layoutIfNeeded()
        }
    }

    /// addMeme: used to present the editor view controller
    /// - Returns: Void
    func addMeme() {
        
        let editorController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! EditorViewController
        
        presentViewController(editorController, animated: true, completion: nil)
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        
        return appDelegate.memes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCell", forIndexPath: indexPath) as! MemeCollectionViewCell

        cell.image = getMemeFor(indexPath.row).memedImage!
        

        return cell
    }
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailsView") as! MemeDetailsViewController
        
        detailController.memeIndex = indexPath.row
        
        navigationController!.pushViewController(detailController, animated: true)
        
    }

    
    // MARK: Methods
    
    /// getMemeFor: return the meme for the memeIndex
    /// - Parameter memeIndex: Int
    /// - Returns: Meme
    func getMemeFor(memeIndex: Int) -> Meme {
     
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        
        return appDelegate.memes[memeIndex]
    }
    
    /// refreshView: force the reload of the data. This is because a bug in the CollectionViewController implementation that makes the CollectionView not to refresh properly after a meme is created or edited.
    /// - Parameters notification: NSNotification
    /// - Returns: Void
    func refreshView(notification: NSNotification) {
        
        if let myCollectionView = collectionView {
            myCollectionView.reloadData()
        }
        
    }
}
