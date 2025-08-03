//
//  Utils.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 3/8/25.
//

import Foundation

func runOnMainThread(_ execute: @escaping () -> Void) {
    DispatchQueue.main.async(execute: execute)
}

func runOnMainThread(after: Double, _ execute: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + after, execute: execute)
}

func runOnMainThread(after: Double, _ execute: DispatchWorkItem) {
    DispatchQueue.main.asyncAfter(deadline: .now() + after, execute: execute)
}
