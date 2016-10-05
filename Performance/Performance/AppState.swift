//
//  AppState.swift
//  Performance
//
//  Created by Kent White on 8/4/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Cordux
import TableDiff

typealias Store = Cordux.Store<AppState>

class AppState: StateType {
    var testState: TestState = .before
    var route: Route = []
    
}

enum TestState {
    case before
    case testing
    case finished(results: [Int])
}

struct RouteSubscription {
    let route: Route
    
    init(_ state: AppState) {
        route = state.route
    }
}

enum TestAction: Action {
    case startTest
    case showResults
    case resetTest
}

final class AppReducer: Reducer {
    var state: AppState? //just for testing
    func handleAction(action: Action, state: AppState) -> AppState {
        var state = state
        state = reduce(action, state: state)
        return state
    }
    
    func reduce(action: Action, state: AppState) -> AppState {
        guard let action = action as? TestAction else {
            return state
        }
        let state = state
        switch action {
        case .startTest:
            state.testState = .testing
            self.state = state
            state.route = ["testing"]
            //this represents the testing...
            NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(finishTest), userInfo: nil, repeats: false)
            break
        case .showResults:
            state.route = ["results"]
        case .resetTest:
            state.route = ["test"]
        }
        return state
    }
    
    @objc func finishTest() {
        handleAction(TestAction.showResults, state: self.state!)
    }
}
