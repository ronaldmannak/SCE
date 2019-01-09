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
    
    var required: Bool { get }
    
    var children: [DependencyViewModelProtocol]? { get }
    
    func install() throws -> [BashOperation]?
    
    func update() throws -> [BashOperation]?
    
    // Queries the dependency version. This can be slow. Some tools need up to 20 seconds to return a version
    // Once fetch, the version will be cached in the version property
    func versionQueryOperation() -> BashOperation?
    
    // Parses the version query response
    func versionQueryParser(_ output: String) -> String
}
