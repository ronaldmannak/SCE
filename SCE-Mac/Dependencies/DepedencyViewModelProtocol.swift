//
//  DepedencyViewModelProtocol.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 9/21/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

protocol DependencyViewModelProtocol {
    
    /// Name of the dependency, with capitalized first letter
    var name: String { get }
    
    /// Name of the dependency, with state emoji added
    var displayName: String { get }
    
    var state: DependencyState { get }
    
    var path: String? { get }
    
    /// Returns cached version number or nil if no version has been cached
    var version: String? { get }
    
    var minimumVersion: String? { get }
    
    var required: Bool { get }
    
    var children: [DependencyViewModelProtocol]? { get }
    
    func install(output: @escaping (String) -> Void, finished: @escaping (Int) -> Void) throws -> [ScriptTask]
    
    func update(output: @escaping (String) -> Void, finished: @escaping (Int) -> Void) throws -> [ScriptTask]
    
    /// Updates version number. Run this the first time requesting version, or after an update
    func updateVersion(completion: @escaping (String) -> ()) throws
    
    /// Queries version of dependency. This is slow, some tools need up to 20 seconds to return a version.
    /// Once fetched, the version will be cached in the version property
    func fetchVersion(completion: @escaping (String) -> ()) throws -> BashOperation
}
