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
    var name: String = "Hello"
    var route: Route = []
}

struct RouteSubscription {
    let route: Route
    
    init(_ state: AppState) {
        route = state.route
    }
}

enum TestAction: Action {
    case Pagination
    case RandomMoves
}

final class AppReducer: Reducer {
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
        case .Pagination:
            state.route = ["pagination"]
        case .RandomMoves:
            state.route = ["randomMoves"]
        }
        
        return state
    }
}
