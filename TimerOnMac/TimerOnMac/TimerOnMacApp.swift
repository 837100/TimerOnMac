//
//  TimerOnMacApp.swift
//  TimerOnMac
//
//  Created by SG on 1/24/25.
//

import SwiftUI

@main
struct TimerOnMacApp: App {
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .frame(minWidth: 250, idealWidth: 260, maxWidth: 900,
                         minHeight: 140, idealHeight: 200, maxHeight: 600)
        }
//        MenuBarExtra("Timer", systemImage: "fitness.timer") {
//                   ContentView()
//               }
//               .menuBarExtraStyle(.window)
//               .keyboardShortcut("m",modifiers: .command, localization: .automatic)
    }
}
