//
//  run.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/2/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

func run(_ cmd: String, path: String = "/bin/sh") -> String? {
    let pipe = Pipe()
    let process = Process()
    process.launchPath = path
//    process.arguments = ["ls"]
    process.arguments = ["-c", String(format:"%@", cmd), "-a"]
    process.standardOutput = pipe
    let fileHandle = pipe.fileHandleForReading
    process.launch()
    process.waitUntilExit()
    return String(data: fileHandle.readDataToEndOfFile(), encoding: .utf8)
}


// https://www.raywenderlich.com/125071/nstask-tutorial-os-x


// so we're running sh here https://superuser.com/questions/408890/what-is-the-purpose-of-the-sh-command
//https://forums.swift.org/t/pipe-child-processes-together/12527/3


// https://stackoverflow.com/questions/24961725/how-can-i-run-a-nstask-in-the-background-and-show-the-results-in-a-modal-nswindo
