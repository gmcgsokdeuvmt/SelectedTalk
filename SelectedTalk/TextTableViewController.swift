//
//  TextTableViewController.swift
//  SelectedTalk
//
//  Created by ArashiUSUKI on 12/3/15.
//  Copyright © 2015 Arashi USUKI. All rights reserved.
//

import Foundation
import UIKit

class TextTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    var data: [String] = ["a","b","m"]
    var delegate: ViewController!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        let barHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        tableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier:"TextCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setTextData(data: [String]){
        self.data = data
    }
    
    func setVC(delegate : ViewController)
    {
        self.delegate = delegate
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TextCell", forIndexPath: indexPath)
        cell.textLabel!.text = data[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate.textChanged(data[indexPath.row])
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

protocol TextTableViewControllerDelegate {
    func textChanged(text: String)
}