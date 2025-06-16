//
//  TimerSettings.swift
//  TimerOnMac
//
//  Created by SG on 6/16/25.
//

import SwiftData

@Model
final class TimerSettings {
    var isOnTop: Bool // 항상 위에 표시 여부
    var isTimeRecording: Bool // 시간 기록 여부
    var selectedHoursString: String
    var selectedMinutesString: String
    var selectedSecondString: String
    
    // 음원 관련 변수
    var mainSoundURL: String?      // 메인으로 설정된 음원의 URL (문자열로 저장)
    var customSoundNames: [String] // 저장된 사용자 음원 파일명 목록
    var isCustomSoundEnabled: Bool // 사용자 음원 사용 여부
    
    init(isOnTop: Bool, isTimeRecording: Bool, selectedHoursString: String, selectedMinutesString: String, selectedSecondString: String, mainSoundURL: String? = nil, customSoundNames: [String], isCustomSoundEnabled: Bool) {
        self.isOnTop = isOnTop
        self.isTimeRecording = isTimeRecording
        self.selectedHoursString = selectedHoursString
        self.selectedMinutesString = selectedMinutesString
        self.selectedSecondString = selectedSecondString
        self.mainSoundURL = mainSoundURL
        self.customSoundNames = customSoundNames
        self.isCustomSoundEnabled = isCustomSoundEnabled
    }
}
