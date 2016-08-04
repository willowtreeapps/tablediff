//
//  AppCoordinator.swift
//  Performance
//
//  Created by Kent White on 8/4/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit
import Cordux

final class AppCoordinator: NSObject, TabBarControllerCoordinator, SubscriberType {
    let store: Store
    let scenes: [Scene]
    let tabBarController: UITabBarController
    init(store: Store, container: UIViewController) {
        self.store = store
        scenes = [
            Scene(prefix: "pagination", coordinator: PaginationCoordinator(store: store)),
            //Scene(prefix: "random moves", coordinator: PaginationCoordinator(store: store)),
        ]
        
        tabBarController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateInitialViewController() as! UITabBarController
        
        tabBarController.viewControllers = scenes.map { $0.coordinator.rootViewController }
        print(tabBarController.viewControllers?.count)
    }
    
    func start(route: Route) {
        tabBarController.delegate = self
        scenes.forEach { $0.coordinator.start([]) }
        store.setRoute(.push(scenes[tabBarController.selectedIndex]))
    }
    
    func newState(state: RouteSubscription) {
        self.route = state.route
    }
}

extension AppCoordinator: UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        return setRouteForViewController(viewController)
    }
}
