//
//  WindowManager.swift
//  TimerOnMac
//
//  Created by SG on 6/16/25.
//

import AppKit
import SwiftUI
import Foundation

class WindowManager: NSObject, NSWindowDelegate {
    static let shared = WindowManager()
    var timeRecordWindow: NSWindow?
    
    func showTimeRecordedList() {
        // 이미 창이 존재하면 앞으로 가져오기
        if let window = timeRecordWindow {
            // 유효성 검사를 조금 더 안전하게 수행
            if !window.isReleasedWhenClosed, window.isVisible {
                window.makeKeyAndOrderFront(nil)
                return
            }
        }
        
        // 새 창 생성
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false)
        window.title = "타이머 기록"
        window.identifier = NSUserInterfaceItemIdentifier("TimeRecordedListWindow")
        window.center()
        window.contentView = NSHostingView(rootView: TimeRecordedList())
        window.delegate = self  // 윈도우 델리게이트 설정
        window.isReleasedWhenClosed = false  // 창이 닫혀도 객체는 유지
        window.makeKeyAndOrderFront(nil)
        
        // 창에 대한 참조 저장
        timeRecordWindow = window
    }
    
    // 창이 닫힐 때 호출되는 델리게이트 메서드
    func windowWillClose(_ notification: Notification) {
        // 창 닫힘 감지 시 참조 정리
        if let closedWindow = notification.object as? NSWindow,
           closedWindow == timeRecordWindow {
            timeRecordWindow = nil
        }
    }
}
