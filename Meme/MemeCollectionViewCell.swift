//
//  MemeCollectionViewCell.swift
//  Meme
//
//  Created by Patrizio Palazzetti on 27/01/16.
//  Copyright © 2016 Patrizio Palazzetti. All rights reserved.
//

import UIKit

class MemeCollectionViewCell: UICollectionViewCell {
    
    // Property for accesing the UIImageView of the cell 
    @IBOutlet weak var memeImage: UIImageView!
    
    var image: UIImage {
        set(newImage) {
            memeImage.image = newImage
            memeImage.contentMode = .ScaleAspectFit
        }
        get {
            return memeImage.image!
        }
    }
}
