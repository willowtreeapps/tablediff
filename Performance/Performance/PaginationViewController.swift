//
//  PaginationViewController.swift
//  Performance
//
//  Created by Kent White on 8/4/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

struct PaginationViewModel {
    let name: String
    //let results: [[Int]]
}

protocol PaginationHandler {
    func startTest()
    func seeResults()
}

class PaginationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    var handler: PaginationHandler!
    
    func inject(handler: PaginationHandler) {
        self.handler = handler
    }
    
    func render(viewModel: PaginationViewModel) {
        //nameLabel?.text = viewModel.name
        print("hello")
    }
    
    @IBAction func signIn(sender: AnyObject) {
        handler.startTest()
    }
    
    @IBAction func forgotPassword(sender: AnyObject) {
        handler.seeResults()
    }
}
