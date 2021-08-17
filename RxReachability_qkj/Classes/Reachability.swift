//
//  Reachability.swift
//  PC Money
//
//  Created by czn on 2019/6/20.
//  Copyright © 2019 czn. All rights reserved.
//

import Foundation
import RxSwift
import Reachability

// An observable that completes when the app gets online (possibly completes immediately).
public func connectedToInternet() -> Observable<Bool> {
    return ReachabilityManager.shared.reach
}

public var isWifi: Bool {
    return ReachabilityManager.shared.isWifi
}

public class ReachabilityManager: NSObject {
    
    static let shared = ReachabilityManager()
    
    fileprivate let reachability = try! Reachability()
    
    let reachSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    var reach: Observable<Bool> {
        return reachSubject.asObservable()
    }
    
    var isWifi: Bool {
        return reachability.connection == .wifi
    }
    
    override init() {
        super.init()
        
        reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                self.reachSubject.onNext(true)
            }
        }
        
        reachability.whenUnreachable = { reachability in
            DispatchQueue.main.async {
                self.reachSubject.onNext(false)
            }
        }
        //Reachability.NetworkReachable
        
        
        do {
            try reachability.startNotifier()
            reachSubject.onNext(reachability.connection != .unavailable)
        } catch {
            #if DEBUG
            print("Unable to start notifier")
            #endif
        }
    }
}
