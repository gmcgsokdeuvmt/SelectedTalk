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
    var toSendList = [false, false, false, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        for i in 0...3{
            toSendList[i] = false
        }
        connect.delegate = self
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
        toSendList[0] = !toSendList[0]
        if toSendList[0]{
            button1.layer.borderColor = UIColor.redColor().CGColor
            button1.layer.borderWidth = 10
        }else{
            button1.layer.borderWidth = 0
        }
    }
    
    @IBAction func button2Tapped(sender: AnyObject) {
        toSendList[1] = !toSendList[1]
        if toSendList[1]{
            button2.layer.borderColor = UIColor.redColor().CGColor
            button2.layer.borderWidth = 10
        }else{
            button2.layer.borderWidth = 0
        }

    }
    
    @IBAction func button3Tapped(sender: AnyObject) {
        toSendList[2] = !toSendList[2]
        if toSendList[2]{
            button3.layer.borderColor = UIColor.redColor().CGColor
            button3.layer.borderWidth = 10
        }else{
            button3.layer.borderWidth = 0
        }
    }
    
    @IBAction func button4Tapped(sender: AnyObject) {
        toSendList[3] = !toSendList[3]
        if toSendList[3]{
            button4.layer.borderColor = UIColor.redColor().CGColor
            button4.layer.borderWidth = 10
        } else{
            button4.layer.borderWidth = 0
        }
    }
    
    func resetButton() {
        for i in 0..<toSendList.count{
            toSendList[i] = false
        }
        button1.layer.borderWidth = 0
        button2.layer.borderWidth = 0
        button3.layer.borderWidth = 0
        button4.layer.borderWidth = 0
    }
    
    @IBAction func refreshTapped(sender: AnyObject) {
        connect.refreshPeers()
    }
    
    @IBAction func textSendTapped(sender: AnyObject) {
        connect.sendText(self.textView.text, toSendList: toSendList)
        resetButton()
    }
    
    @IBAction func imageSendTapped(sender: AnyObject) {
        if let img = self.imageView.image{
            connect.sendImage(img, toSendList: toSendList)
            resetButton()
        }
    }
    
    @IBAction func cameraRollTapped(sender: AnyObject) {
        accessCameraRoll()
    }
    
    @IBAction func openTapped(sender: AnyObject) {
        acccessTextTable()
    }
    
    @IBAction func saveTapped(sender: AnyObject) {
        saveText(textView.text)
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
    
    func acccessTextTable(){
        let controller = TextTableViewController()
        NSLog("%@","\(controller)")
        let ud = NSUserDefaults.standardUserDefaults()
        if let data = ud.objectForKey("TEXTS") as? [String]
        {controller.setTextData(data)
            NSLog("%@","setTextData")}
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func saveText(text: String){
        let ud = NSUserDefaults.standardUserDefaults()
        if var data = ud.objectForKey("TEXTS") as? [String]{
            data.append(text)
            ud.setObject(data, forKey: "TEXTS")
        }
        else {
            var data = [String]()
            data.append(text)
            ud.setObject(data
                , forKey: "TEXTS")
        }
    }


}

extension ViewController : ConnectManagerDelegate {
    
    func connectedDevicesChanged(manager: ConnectManager, connectedDevices: [String]) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            for i in 1...4{
                switch i{
                case 1:
                    if connectedDevices.count > 0{
                        self.button1.setTitle(connectedDevices[0], forState: UIControlState.Normal)}
                    else{
                        self.button1.setTitle("1", forState: UIControlState.Normal)}
                case 2:
                    if connectedDevices.count > 1{
                        self.button2.setTitle(connectedDevices[1], forState: UIControlState.Normal)}
                    else{
                        self.button2.setTitle("2", forState: UIControlState.Normal)}
                case 3:
                    if connectedDevices.count > 2{
                        self.button3.setTitle(connectedDevices[2], forState: UIControlState.Normal)}
                    else{
                        self.button3.setTitle("3", forState: UIControlState.Normal)}
                case 4:
                    if connectedDevices.count > 3{
                        self.button4.setTitle(connectedDevices[3], forState: UIControlState.Normal)}
                    else{
                        self.button4.setTitle("4", forState: UIControlState.Normal)}
                default:break
                }
            }
        }
        NSLog("%@", "-------------------connectedDevicesChanged----------------------")
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
