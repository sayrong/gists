//
//  CustomTableViewCell.swift
//  gists
//
//  Created by Dmitriy on 05/08/2019.
//  Copyright © 2019 Dmitriy. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    @IBOutlet weak var gistImage: UIImageView!
    @IBOutlet weak var language: UILabel!
    @IBOutlet weak var secretLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        secretLabel.layer.borderColor = UIColor.gray.cgColor
        secretLabel.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
