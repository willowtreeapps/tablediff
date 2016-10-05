//
//  Results.swift
//  Performance
//
//  Created by Kent White on 8/4/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit
import Cordux

class ResultsCoordinator: SceneCoordinator {
    var rootViewController: UIViewController {
        return container
    }
    
    var store: Store
    var scenePrefix: String { return "results"}
    var currentScene: AnyCoordinator?
    let container: UIViewController
    let storyboard = UIStoryboard(name: "Results", bundle: nil)
    let resultsViewController: ResultsViewController
    
    init(store: Store) {
        self.store = store
        resultsViewController = storyboard.instantiateInitialViewController() as! ResultsViewController
        container = resultsViewController
    }
    
    func start(route: Route) {
        resultsViewController.inject(self)
    }
    
    func changeScene(route: Route) {}
}

extension ResultsCoordinator: ViewControllerLifecycleDelegate {
    @objc func viewDidLoad(viewController: UIViewController) {
        if viewController === resultsViewController {
            store.subscribe(resultsViewController, ResultsViewModel.init)
        }
    }
}

extension ResultsCoordinator: ResultsHandler {
    func resetTest() {
        
        
    }
    
    func printResults() {
        //store.route(.push(RouteSegment.fp))
    }
}

extension ResultsViewController: Renderer {}

extension ResultsViewModel {
    init(_ state: AppState) {
        
    }
}
