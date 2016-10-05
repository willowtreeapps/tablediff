//
//  PaginationCoordinator.swift
//  Performance
//
//  Created by Kent White on 8/4/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit
import Cordux

class TestCoordinator: SceneCoordinator {
    var rootViewController: UIViewController {
        return container
    }
    
    var store: Store
    var scenePrefix: String { return "test"}
    var currentScene: AnyCoordinator?
    let container: UIViewController
    let storyboard = UIStoryboard(name: "Test", bundle: nil)
    let testViewController: TestViewController
    
    init(store: Store) {
        self.store = store
        testViewController = storyboard.instantiateInitialViewController() as! TestViewController
        container = testViewController
    }
    
    func start(route: Route) {
        testViewController.inject(self)
        store.subscribe(testViewController, TestViewModel.init)
    }
    
    func changeScene(route: Route) {}
}

extension TestCoordinator: ViewControllerLifecycleDelegate {
    @objc func viewDidLoad(viewController: UIViewController) {
        if viewController === testViewController {
            store.subscribe(testViewController, TestViewModel.init)
        }
    }
}

extension TestCoordinator: TestHandler {
    func startTest() {
        
        store.dispatch(TestAction.startTest)
    }
    
    func seeResults() {
        
    }
}

extension TestViewController: Renderer {}

extension TestViewModel {
    init(_ state: AppState) {
        testState = state.testState
    }
}
