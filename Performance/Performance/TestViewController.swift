//
//  PaginationViewController.swift
//  Performance
//
//  Created by Kent White on 8/4/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

struct TestViewModel {
    var testState: TestState
}

protocol TestHandler {
    func startTest()
    func seeResults()
}

class TestViewController: UIViewController {

    @IBOutlet weak var startTestButton: UIButton!
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startTestButton.frame.size = CGSize(width: 100, height: 100)
        startTestButton.backgroundColor = UIColor.blueColor()
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        startTestButton.addSubview(spinner)
        spinner.center = startTestButton.center
        //spinner.alpha = 0
    }

    var handler: TestHandler!
    
    func inject(handler: TestHandler) {
        self.handler = handler
    }
    
    func render(viewModel: TestViewModel) {
        if case .testing = viewModel.testState {
            startTestButton?.enabled = false
            //startTestButton?.setTitle("", forState: .Normal)
            spinner.alpha = 1
            spinner.startAnimating()
            
        } else {
            startTestButton?.enabled = true
            startTestButton?.setTitle("Start Test", forState: .Normal)
            spinner.stopAnimating()
            spinner.alpha = 1
        }
    }
    
    @IBAction func startTest(sender: AnyObject) {
        handler.startTest()
    }
}
