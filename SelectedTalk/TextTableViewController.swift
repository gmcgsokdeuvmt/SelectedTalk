//
//  TextTableViewController.swift
//  SelectedTalk
//
//  Created by ArashiUSUKI on 12/3/15.
//  Copyright © 2015 Arashi USUKI. All rights reserved.
//

import Foundation
import UIKit

class TextTableViewController: UITableViewController {
    var data: [String] = []
    
    func setTextData(data: [String]){
        self.data = data
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TextCell", forIndexPath: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
}