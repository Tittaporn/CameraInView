//
//  PhotoView.swift
//  ScrollViewHorizantal
//
//  Created by M3ts LLC on 10/7/21.
//

import UIKit

// MARK: - Protocol
protocol PhotoViewDelegate: AnyObject {
    func updatePhotoData(image: UIImageView, text: String)
}


class PhotoView: UIView {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lbl: UILabel!
    
    weak var delegate: PhotoViewDelegate?

    @IBAction func photoViewButtonTapped(_ sender: Any) {
        delegate?.updatePhotoData(image: img, text: lbl.text ?? "")
    }
}
