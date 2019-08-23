//
//  CreateAccountVC.swift
//  Dante Staff
//
//  Created by Hung Phan on 7/20/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class CreateAccountVC: UIViewController {
    
    var qrcodeCIImage: CIImage!
    var qrcodeData : NSData!
    
    @IBOutlet weak var emptyValLabel: UILabel!
    @IBOutlet weak var firstNameTF: CustomFieldRounded!
    @IBOutlet weak var lastNameTF: CustomFieldRounded!
    @IBOutlet weak var phoneNumTF: CustomFieldRounded!
    @IBOutlet weak var pinTF: CustomFieldRounded!
    @IBOutlet weak var createBtn: CustomButton!
    @IBAction func createBtnPressed(_ sender: Any) {
        ViewController().showSpinner(onView: self.view)
        let opfn = self.firstNameTF.text
        let opln = self.lastNameTF.text
        let oppn = self.phoneNumTF.text
        let opp = self.pinTF.text
        
        if (!(opfn ?? "").isEmpty && !(opln ?? "").isEmpty && !(oppn ?? "").isEmpty && !(opp ?? "").isEmpty) {
            let dict : [String : String] = [
                "firstName" : self.firstNameTF.text!,
                "lastName" : self.lastNameTF.text!,
                "patientPhoneNumber" : self.phoneNumTF.text!,
                "patientPin" : self.pinTF.text!
            ]

            Database.database().reference().child("Patients").queryOrdered(byChild: "patientPhoneNumber").queryEqual(toValue: oppn!).observeSingleEvent(of: .value, with: { snapshot in
                if (snapshot.exists()) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        ViewController().removeSpinner()
                        self.emptyValLabel.isHidden = false
                        self.emptyValLabel.text = "Error! This phone number is already existed in the database."
                    }
                }
                else {
                    print("Account requested is new!")
                    Database.database().reference().child("Patients").childByAutoId().setValue(dict)
                    
                    // generate QR code as CIImage
                    let qrData = self.phoneNumTF.text?.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
                    let filter = CIFilter(name: "CIQRCodeGenerator")
                    filter?.setValue(qrData, forKey: "inputMessage")
                    filter?.setValue("Q", forKey: "inputCorrectionLevel")
                    self.qrcodeCIImage = filter?.outputImage
                    
                    // convert CIImage to UIImage
                    let context:CIContext = CIContext.init(options:nil)
                    let cgImage:CGImage = context.createCGImage(self.qrcodeCIImage, from: self.qrcodeCIImage.extent)!
                    let qrcodeUIImage = UIImage.init(cgImage: cgImage)
                    // convert UIImage to JPEG
                    self.qrcodeData = qrcodeUIImage.jpegData(compressionQuality: 1.0)! as NSData
                    
                    // Upload to Firebase Storage
                    let filePath = "userQrCode/\(oppn!).jpg"
                    let ref = Storage.storage().reference().child(filePath)
                    let uploadTask = ref.putData(self.qrcodeData as Data, metadata: nil) {
                        (UserMetadata, error) in guard UserMetadata != nil else {
                            print("ERROR UPLOADING")
                            return
                        }
                        // finished uploading. this part only runs after .observer(.success) is called
                    }
                    uploadTask.observe(.progress) { snapshot in
                        let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                        print("PROGRESS = ", percentComplete)
                    }
                    uploadTask.observe(.pause) { snpashot in
                        print("UPLOAD PAUSED")
                    }
                    uploadTask.observe(.success) { snapshot in
                        print("UPLOAD COMPLETED SUCCESSFULLY")
                        ref.downloadURL {
                            (url, error) in guard url != nil else {
                                print("ERROR downloading the URL")
                                return
                            }
                            print("URL = ", url!)
                            
                            // QR code is uploaded successfully -> Display success message
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                ViewController().removeSpinner()
                                self.firstNameTF.text = ""
                                self.lastNameTF.text = ""
                                self.phoneNumTF.text = ""
                                self.pinTF.text = ""
                                self.performSegue(withIdentifier: "success", sender: self)
                            }
                        }
                    }
                    uploadTask.observe(.failure) { snapshot in
                        if let error = snapshot.error as NSError? {
                            switch (StorageErrorCode(rawValue: error.code)!) {
                            case .objectNotFound:
                                print("FILE DOESN'T EXIST")
                                break
                            case .unauthorized:
                                print("USER DOESN'T HAVE PERMISSION TO ACCESS FILE")
                                break
                            case .cancelled:
                                print("USER CANCELED THE UPLOAD")
                                break
                            case .unknown:
                                print("UNKOWN ERROR OCCURED, INSPECT THE SERVER RESPONSE")
                                break
                            default:
                                print("A SEPARATE ERROR OCCURRED. THIS IS A GOOD PLACE TO RETRY THE UPLOAD")
                                break
                            }
                        }
                    }
                }
            })
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                ViewController().removeSpinner()
                self.emptyValLabel.isHidden = false
                self.emptyValLabel.text = "One of the required fields is empty."
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.emptyValLabel.text = ""
        self.emptyValLabel.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.emptyValLabel.text = ""
        self.emptyValLabel.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        emptyValLabel.isHidden = true
        
        self.addDoneButtonOnKeyboard()
    }
    
    // add Done to the top of the keyboard
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        firstNameTF.inputAccessoryView = doneToolbar
        lastNameTF.inputAccessoryView = doneToolbar
        phoneNumTF.inputAccessoryView = doneToolbar
        pinTF.inputAccessoryView = doneToolbar
        
    }
    @objc func doneButtonAction(){
        firstNameTF.resignFirstResponder()
        lastNameTF.resignFirstResponder()
        phoneNumTF.resignFirstResponder()
        pinTF.resignFirstResponder()
    }
}
