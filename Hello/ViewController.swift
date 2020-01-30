//
//  ViewController.swift
//  Hello
//
//  Created by Prajeet Shrestha on 1/30/20.
//  Copyright © 2020 Spiralogics. All rights reserved.
//

import UIKit
import YPImagePicker
import AVFoundation

class ViewController: UIViewController {
    var picker:YPImagePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        var config = YPImagePickerConfiguration()
        config.library.maxNumberOfItems = 20
        config.maxCameraZoomFactor = 1.0
        config.showsCrop = .none
        config.library.isSquareByDefault = false
        config.screens = [.library]
        picker = YPImagePicker(configuration: config)
        
    }
    @IBAction func pickPhotos(_ sender: Any) {
        present(picker, animated: true, completion: nil)
        picker.didFinishPicking { [unowned picker] items, cancelled in
            for item in items {
                switch item {
                case .photo(let photo):
                    let overlayImage = UIImage(named: "tag_image")!
                    let image = UIImage.imageByMergingImages(topImage: overlayImage, bottomImage: photo.image)
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                case .video(let video):
                    print(video)
                }
            }
            picker?.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            UIGraphicsEndImageContext()
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            UIGraphicsEndImageContext()
        }
    }
    
    
}

extension UIImage {
    
    static func imageByMergingImages(topImage: UIImage, bottomImage: UIImage, scaleForTop: CGFloat = 1.5) -> UIImage {
        let size = bottomImage.size
        let container = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
        UIGraphicsGetCurrentContext()!.interpolationQuality = .high
        bottomImage.draw(in: container)
        
        let topWidth = size.width / scaleForTop
        let topHeight = size.height / scaleForTop
        let topX = (size.width / 2.0) - (topWidth / 2.0)
        let topY = (size.height / 2.0) - (topHeight / 2.0)

        let wholeRect = CGRect(x: topX, y: topY, width: topWidth, height: topHeight)
        let rect = AVMakeRect(aspectRatio: CGSize(width: 248, height: 58), insideRect: wholeRect)
        topImage.draw(in:rect , blendMode: .normal, alpha: 0.7)
    
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
}
