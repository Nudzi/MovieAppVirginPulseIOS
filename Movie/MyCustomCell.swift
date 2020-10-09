//
//  MyCustomCell.swift
//  API
//
//  Created by Nudzejma Kezo on 10/1/20.
//

import Foundation

import UIKit

class MyCustomCell: UITableViewCell {

    @IBOutlet weak var imagePoster: UIImageView!
    @IBOutlet weak var Overview: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension UIImageView {
    func load(urlString: String) {
        guard let url = URL(string: urlString)else {
            return
        }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
