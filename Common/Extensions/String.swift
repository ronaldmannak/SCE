//
//  String.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 9/5/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

extension String {
    
    func capitalizedFirstChar() -> String {
        return self.prefix(1).capitalized + self.dropFirst()
    }
}
