//
//  DisplayAccVC.swift
//  Dante Staff
//
//  Created by Hung Phan on 7/20/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import FirebaseStorage

class DisplayAccVC: UIViewController {

    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var phoneNum: UILabel!
    @IBOutlet weak var pin: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var mainMenuBtn: CustomButton!
    @IBOutlet weak var QRImageView: UIImageView!
    
    var dataReceived = ["":""]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dataReceived)
        
        self.firstName.text = dataReceived["firstName"]
        self.lastName.text = dataReceived["lastName"]
        self.phoneNum.text = dataReceived["patientPhoneNumber"]
        self.pin.text = dataReceived["patientPin"]
        let qrCodeString = dataReceived["qrCodeLink"]
        let httpsReference = Storage.storage().reference(forURL: qrCodeString!)
        // allows to download up to 10 MB file (1024 * 1024) = 1 MB
        httpsReference.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
            if error != nil {
                print("ERROR DOWNLOADING IMAGE")
            } else {
                let imageCII = CIImage(data: data!)
                let scaleXX = self.QRImageView.frame.size.width / (imageCII?.extent.size.width)!
                let scaleYY = self.QRImageView.frame.size.height / (imageCII?.extent.size.height)!
                
                let transformedImage = imageCII?.transformed(by: CGAffineTransform(scaleX: scaleXX, y: scaleYY))

                self.QRImageView.image = UIImage(ciImage: transformedImage!)
            }
        }
        blurView.layer.cornerRadius = 10.0
    }

}
