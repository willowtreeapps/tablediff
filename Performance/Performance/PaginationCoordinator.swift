//
//  PaginationCoordinator.swift
//  Performance
//
//  Created by Kent White on 8/4/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit
import Cordux

class PaginationCoordinator: NavigationControllerCoordinator {

    enum RouteSegment: String, RouteConvertible {
        case main
        case detail
    }
    
    var store: Store
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let navigationController: UINavigationController
    var rootViewController: UIViewController { return navigationController }
    
    let paginationViewController: PaginationViewController
    
    init(store: Store) {
        self.store = store
        
        paginationViewController = storyboard.instantiateViewControllerWithIdentifier("Pagination") as! PaginationViewController
        navigationController = UINavigationController(rootViewController: paginationViewController)
    }
    
    func start(route: Route) {
        paginationViewController.inject(self)
    }
    
    func updateRoute(route: Route) {
        if parse(route).last == .detail {
            navigationController.pushViewController(createResultsViewController(), animated: true)
        }
    }
    
    func parse(route: Route) -> [RouteSegment] {
        return route.flatMap { RouteSegment.init(rawValue: $0) }
    }
    
    func createResultsViewController() -> ResultsViewController {
        let resultsViewController = storyboard.instantiateViewControllerWithIdentifier("Results") as! ResultsViewController
//        forgotPasswordViewController.inject(self)
//        forgotPasswordViewController.corduxContext = Context(RouteSegment.fp, lifecycleDelegate: self)
        return resultsViewController
    }
}

extension PaginationCoordinator: ViewControllerLifecycleDelegate {
    @objc func viewDidLoad(viewController: UIViewController) {
        if viewController === paginationViewController {
            store.subscribe(paginationViewController, PaginationViewModel.init)
        }
    }
    
    @objc func didMove(toParentViewController parentViewController: UIViewController?, viewController: UIViewController) {
        guard parentViewController == nil else {
            return
        }
        
        popRoute(viewController)
    }
}

extension PaginationCoordinator: PaginationHandler {
    func startTest() {
        store.dispatch(TestAction.Pagination)
    }
    
    func seeResults() {
        //store.route(.push(RouteSegment.fp))
    }
}

extension PaginationViewController: Renderer {}

extension PaginationViewModel {
    init(_ state: AppState) {
        name = state.name
    }
}
