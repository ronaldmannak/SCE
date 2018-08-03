//
//  run.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/2/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

func run(_ cmd: String) -> String? {
    let pipe = Pipe()
    let process = Process()
    process.launchPath = "/bin/sh"
    process.arguments = ["-c", String(format:"%@", cmd)]
    process.standardOutput = pipe
    let fileHandle = pipe.fileHandleForReading
    process.launch()
    return String(data: fileHandle.readDataToEndOfFile(), encoding: .utf8)
}
