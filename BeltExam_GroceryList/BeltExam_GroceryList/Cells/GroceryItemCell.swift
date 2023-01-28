//
//  GroceryItemCell.swift
//  BeltExam_GroceryList
//
//  Created by Nuha Alharbi on 08/01/2023.
//

import UIKit

class GroceryItemCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var checkmarkView: UIView!
    @IBOutlet weak var priorityEmoji: UILabel!
    
    // MARK: - App lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        itemName.attributedText = nil
    }
    
}


