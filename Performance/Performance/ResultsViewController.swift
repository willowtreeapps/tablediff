//
//  ResultsViewController.swift
//  Performance
//
//  Created by Kent White on 8/4/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

struct ResultsViewModel {
    //let results: [[Int]]
}

protocol ResultsHandler {
    func resetTest()
    func printResults()
}

class ResultsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    var handler: ResultsHandler!
    
    func inject(handler: ResultsHandler) {
        self.handler = handler
    }
    
    func render(viewModel: ResultsViewModel) {
        print("hello")
    }
    
    @IBAction func signIn(sender: AnyObject) {
        handler.resetTest()
    }
    
    @IBAction func forgotPassword(sender: AnyObject) {
        handler.printResults()
    }
}
