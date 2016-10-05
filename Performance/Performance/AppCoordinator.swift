//
//  AppCoordinator.swift
//  Performance
//
//  Created by Kent White on 8/4/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit
import Cordux

final class AppCoordinator: SceneCoordinator, SubscriberType {
    enum RouteSegment: String, RouteConvertible {
        case test
        case results
    }
    
    var scenePrefix: String = RouteSegment.test.rawValue
    let store: Store
    let container: UIViewController
    
    var currentScene: AnyCoordinator?
    
    var rootViewController: UIViewController {
        return container
    }
    
    init(store: Store, container: UIViewController) {
        self.store = store
        self.container = container
    }
    
    func start(route: Route) {
        store.subscribe(self, RouteSubscription.init)
        changeScene(route)
    }
    
    func newState(state: RouteSubscription) {
        self.route = state.route
    }
    
    func changeScene(route: Route) {
        guard let segment = RouteSegment(rawValue: route.first ?? "") else {
            return
        }
        
        let old = currentScene?.rootViewController
        let coordinator: AnyCoordinator
        switch segment {
        case .test:
            coordinator = TestCoordinator(store: store)
        case .results:
            coordinator = ResultsCoordinator(store: store)
        }
        
        coordinator.start(sceneRoute(route))
        currentScene = coordinator
        scenePrefix = segment.rawValue
        
        let container = self.container
        let new = coordinator.rootViewController
        
        old?.willMoveToParentViewController(nil)
        container.addChildViewController(new)
        container.view.addSubview(new.view)
        
        var constraints: [NSLayoutConstraint] = []
        constraints.append(new.view.leftAnchor.constraintEqualToAnchor(container.view.leftAnchor))
        constraints.append(new.view.rightAnchor.constraintEqualToAnchor(container.view.rightAnchor))
        constraints.append(new.view.topAnchor.constraintEqualToAnchor(container.view.topAnchor))
        constraints.append(new.view.bottomAnchor.constraintEqualToAnchor(container.view.bottomAnchor))
        NSLayoutConstraint.activateConstraints(constraints)
        
        new.view.alpha = 0
        UIView.animateWithDuration(0.3, animations: {
            old?.view.alpha = 0
            new.view.alpha = 1
            }, completion: { _ in
                old?.view.removeFromSuperview()
                old?.removeFromParentViewController()
                new.didMoveToParentViewController(container)
        })
    }
}
