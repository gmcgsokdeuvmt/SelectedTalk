//
//  ViewController.swift
//  SelectedTalk
//
//  Created by Arashi USUKI on 12/3/15.
//  Copyright © 2015 Arashi USUKI. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    let connect = ConnectManager()
    var toSendList = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        for i in 1...4{
            toSendList[i] = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!

    @IBAction func button1Tapped(sender: AnyObject) {
        toSendList[1] = true
    }
    
    @IBAction func button2Tapped(sender: AnyObject) {
        toSendList[2] = true
    }
    
    @IBAction func button3Tapped(sender: AnyObject) {
        toSendList[3] = true
    }
    
    @IBAction func button4Tapped(sender: AnyObject) {
        toSendList[4] = true
    }
    
    @IBAction func refreshTapped(sender: AnyObject) {
        connect.refreshPeers()
    }
    
    @IBAction func textSendTapped(sender: AnyObject) {
            connect.sendText(self.textView.text, toSendList: toSendList)
    }
    
    @IBAction func imageSendTapped(sender: AnyObject) {
        if let img = self.imageView.image{
            connect.sendImage(img, toSendList: toSendList)
        }
    }
    
    @IBAction func cameraRollTapped(sender: AnyObject) {
        accessCameraRoll()
    }
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    func accessCameraRoll(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.imageView.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.imageView.image = image
    }


}

extension ViewController : ConnectManagerDelegate {
    
    func connectedDevicesChanged(manager: ConnectManager, connectedDevices: [String]) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            for i in 1...connectedDevices.count{
                switch i{
                case 1: self.button1.setTitle(connectedDevices[0], forState: UIControlState.Normal)
                case 2: self.button2.setTitle(connectedDevices[1], forState: UIControlState.Normal)
                case 3: self.button3.setTitle(connectedDevices[2], forState: UIControlState.Normal)
                case 4: self.button4.setTitle(connectedDevices[3], forState: UIControlState.Normal)
                default:break
                }
            }
            for i in connectedDevices.count...4{
                switch i{
                case 1: self.button1.setTitle("1", forState: UIControlState.Normal)
                case 2: self.button2.setTitle("2", forState: UIControlState.Normal)
                case 3: self.button3.setTitle("3", forState: UIControlState.Normal)
                case 4: self.button4.setTitle("4", forState: UIControlState.Normal)
                default:break
                }
            }
        }
        NSLog("connectedDevicesChanged")
    }
    
    func textChanged(manager: ConnectManager, text: String) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.textView.text = text
        }
    }
    
    func imageChanged(manager: ConnectManager, image: UIImage) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.imageView.image = image
        }
    }
}
