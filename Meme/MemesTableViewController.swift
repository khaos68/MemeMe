//
//  MemesTableViewController.swift
//  Meme
//
//  Created by Patrizio Palazzetti on 27/01/16.
//  Copyright © 2016 Patrizio Palazzetti. All rights reserved.
//

import UIKit

class MemesTableViewController: UITableViewController {

    private var deleteMemeIndexPath: NSIndexPath? = nil
    private var appDelegate: AppDelegate!
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let object = UIApplication.sharedApplication().delegate
        appDelegate = object as! AppDelegate

        // Add right button for add new meme
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addMeme")
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return appDelegate.memes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableCell", forIndexPath: indexPath)
        
        cell.textLabel!.text = "\(appDelegate.memes[indexPath.row].topString!) ... \(appDelegate.memes[indexPath.row].bottomString!)"
        cell.imageView?.image = appDelegate.memes[indexPath.row].memedImage

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailsView") as! MemeDetailsViewController
        
        detailController.memeIndex = indexPath.row
            
        navigationController!.pushViewController(detailController, animated: true)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            deleteMemeIndexPath = indexPath
            let memeToDelete = appDelegate.memes[indexPath.row]
            confirmMemeToDelete("\(memeToDelete.topString!)...\(memeToDelete.bottomString!)")
        }
    }
    
    // MARK: - Methods
    
    /// addMeme: used to present the editor view controller
    /// - Returns: Void
    func addMeme() {
        
        let editorController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! EditorViewController

        presentViewController(editorController, animated: true, completion: nil)
    }
    
    // Notification workflow by http://stackoverflow.com/users/4085910/dharmesh-kheni from http://stackoverflow.com/questions/30274017/calling-a-parent-uiviewcontroller-method-from-a-child-uiviewcontroller
    
    /// confirmMemeToDelete: 
    /// - Parameter meme: String
    /// - Returns: Void
    func confirmMemeToDelete(meme: String) {
        let alert = UIAlertController(title: "Delete Meme", message: "Are you sure you want to permanently delete \(meme)?", preferredStyle: .ActionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: handleDeleteMeme)
        let CancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: cancelDeleteMeme)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    /// handleDeleteMeme:
    /// - Parameter alertAction: UIAlertAction
    /// - Returns: Void
    func handleDeleteMeme(alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteMemeIndexPath {
            tableView.beginUpdates()
            
            appDelegate.memes.removeAtIndex(indexPath.row)
            
            // Note that indexPath is wrapped in an array:  [indexPath]
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            deleteMemeIndexPath = nil
            
            tableView.endUpdates()
        }
    }
    
    /// cancelDeleteMeme
    /// - Parameter alertAction: UIAlertAction
    /// - Returns: Void
    func cancelDeleteMeme(alertAction: UIAlertAction!) {
        deleteMemeIndexPath = nil
    }

}
