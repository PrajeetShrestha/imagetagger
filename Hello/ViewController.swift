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

    @IBOutlet weak var lblTransparency: UILabel!
    @IBOutlet weak var lblPosition: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    
    @IBOutlet weak var imgPreview: UIImageView!
    @IBOutlet weak var stepTransparency: UIStepper!
    @IBOutlet weak var stepPosition: UIStepper!
    @IBOutlet weak var stepSize: UIStepper!
    
    var picker:YPImagePicker!
    var defaultPosition:Double = 2.0
    var defaultTransparency:Double = 7.0
    var defaultSize:Double = 1.5
    
    let overlay = UIImage(named:"tag_image")!
    let previewImage = UIImage(named: "download")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var config = YPImagePickerConfiguration()
        config.library.maxNumberOfItems = 20
        config.maxCameraZoomFactor = 1.0
        config.showsCrop = .none
        config.library.isSquareByDefault = false
        config.screens = [.library]
        picker = YPImagePicker(configuration: config)
        setupDefaultValues()
        updatePreviewImage()
    }
    
    func updatePreviewImage() {
        let image = imageByMergingImages(topImage: overlay, bottomImage: previewImage)
        imgPreview.image = image
    }
    
    func setupDefaultValues() {
        stepPosition.value = defaultPosition
        setPositionLabel(value: defaultPosition)
        
        stepTransparency.value = defaultTransparency
        setTransparencyLabel(value: defaultTransparency)
        
        stepSize.value = defaultSize
        setSizeLable(value: defaultSize)
    }
    
    func setTransparencyLabel(value:Double) {
        self.lblTransparency.text = "Transparency:\(value)"
    }
    
    func setPositionLabel(value:Double) {
        self.lblPosition.text = "Position:\(value)"
    }
    
    func setSizeLable(value:Double) {
        self.lblSize.text = "Size: \(value)"
    }
    
    @IBAction func transparencyStepper(_ sender: UIStepper) {
        defaultTransparency = sender.value
        setTransparencyLabel(value: sender.value)
        updatePreviewImage()
    }
    
    @IBAction func positionStepper(_ sender: UIStepper) {
        defaultPosition = sender.value
        setPositionLabel(value: sender.value)
        updatePreviewImage()
    }
    
    @IBAction func sizeStepper(_ sender: UIStepper) {
        defaultSize = sender.value
        setSizeLable(value: sender.value)
        updatePreviewImage()
    }
    
    @IBAction func pickPhotos(_ sender: Any) {
        present(picker, animated: true, completion: nil)
        picker.didFinishPicking { [unowned picker] items, cancelled in
            for item in items {
                switch item {
                case .photo(let photo):
                    let image = self.imageByMergingImages(topImage: self.overlay, bottomImage: photo.image)
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
    
     func imageByMergingImages(topImage: UIImage, bottomImage: UIImage) -> UIImage {
        let size = bottomImage.size
        let container = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
        UIGraphicsGetCurrentContext()!.interpolationQuality = .high
        bottomImage.draw(in: container)
        
        let topWidth = size.width / CGFloat(defaultSize)
        let topHeight = size.height / CGFloat(defaultSize)
        let topX = (size.width / 2.0) - (topWidth / 2.0)
        let topY = (size.height / 2.0) - (topHeight / CGFloat(defaultPosition) )

        let wholeRect = CGRect(x: topX, y: topY, width: topWidth, height: topHeight)
        let rect = AVMakeRect(aspectRatio: CGSize(width: 248, height: 58), insideRect: wholeRect)
        topImage.draw(in:rect , blendMode: .normal, alpha: CGFloat(defaultTransparency/10.0))
    
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}

