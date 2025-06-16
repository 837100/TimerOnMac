//
//  TimerOnMacApp.swift
//  TimerOnMac
//
//  Created by SG on 1/24/25.
//

import SwiftUI
import AVFoundation
import Combine
import Cocoa

struct AlwaysOnTopView: NSViewRepresentable {
    let window: NSWindow
    let isAlwaysOnTop: Bool
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if isAlwaysOnTop {
            window.level = .floating
        } else {
            window.level = .normal
        }
    }
}

struct ContentView: View {
    @AppStorage("selectedHoursString") private var selectedHoursString: String = "00"
    @AppStorage("selectedMinutesString") private var selectedMinutesString: String = "10"
    @AppStorage("selectedSecondString") private var selectedSecondString: String = "00"
    @AppStorage("timeRemaining") private var timeRemaining: Int = 0
    @AppStorage("setDone") private var timeSeted: Bool = false
    @AppStorage("lastSeletcted") private var lastSeletcted: Int = 0
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isOnTop: Bool = true  // 화면 위에 고정 Bool 함수
    @State private var isTimeRecording = true // 시간 기록 여부
    @State private var isRunning: Bool = false
    @State private var beepToggle: Bool = false
    @State private var timer: AnyCancellable?
    
    
    var body: some View {
        VStack {
            HStack {
                /// 시간 설정이 안 되어 있을 때.
                if !timeSeted {
                    timeSettingView
                }
                
                /// 시간 설정 완료 후
                if timeSeted {
                    timerView
                }
            }
            
            .padding()
            //            .onReceive(timer) { t in
            //                print("timer tick \(t)")
            //                if isRunning && timeRemaining > 0 {
            //                    timeRemaining -= 1
            //                } else if timeRemaining == 0 {
            //                    isRunning = false
            //
            //                    if beepToggle {
            //                        // 시스템 비프음
            //                        playAlarmSound()
            //                    }
            //
            //                } else {
            //                    // ignore
            //                }
            //            }
        }
        
        //        .onChange(of: isRunning) {
        //            isOnTop = isRunning
        //        }
        .background(AlwaysOnTopView(window: NSApplication.shared.windows.first!, isAlwaysOnTop: isOnTop))
    }
    
    private func playAlarmSound() {
        guard let url = Bundle.main.url(forResource: "song", withExtension: "m4a") else {
            print("오디오 파일을 찾을 수 없습니다.")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
            
        } catch {
            print("오디오 필레이어 초기화 중 오류 발생 : \(error.localizedDescription)")
        }
    }
    
    private func stopAlarmSound() {
        audioPlayer?.stop()
        
    }
    
    private func startTimer() {
        guard !isRunning, timeRemaining > 0 else { return }
        
        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common) // 1초 간격으로 수정
            .autoconnect()
            .sink { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                }
                if timeRemaining == 0 {
                    stopTimer()
                    playAlarmSound()
                }
            }
    }
    
    private func stopTimer() {
        isRunning = false
        timer?.cancel()
        timer = nil
        stopAlarmSound()
    }
    
    // MARK: - 시간 설정 뷰
    private var timeSettingView: some View {
        HStack {
            Button(){
                isOnTop.toggle()
            } label: {
                Image(systemName: isOnTop ? "pin.fill" : "pin.slash")
            }.buttonStyle(PlainButtonStyle())
            
            VStack {
                /// 시간 올리기 버튼
                Image(systemName: "chevron.up.2")
                    .onTapGesture {
                        if Int(selectedHoursString)! < 23 {
                            selectedHoursString = String(Int(selectedHoursString)! + 1)
                        } else if Int(selectedHoursString)! >= 23 {
                            selectedHoursString = "00"
                        }
                    }
                    .onLongPressGesture {
                        if Int(selectedHoursString)! < 16 {
                            selectedHoursString = String(Int(selectedHoursString)! + 8)
                        } else if Int(selectedHoursString)! >= 16 {
                            selectedHoursString = "00"
                        }
                    }
                
                /// 시간 입력 필드
                TextField("HH", text: Binding(
                    get: { selectedHoursString },
                    set: { newValue in
                        selectedHoursString = String(newValue.filter { $0.isNumber }.prefix(2))
                    }
                ))
                .frame(width: 40, height: 50)
                .font(.system(size: 20))
                
                
                /// 시간 낮추기 버튼
                Image(systemName: "chevron.down.2")
                    .onTapGesture {
                        if Int(selectedHoursString)! > 0 {
                            selectedHoursString = String(Int(selectedHoursString)! - 1)
                        } else if Int(selectedHoursString)! <= 0 {
                            selectedHoursString = "23"
                        }
                    }
                    .onLongPressGesture {
                        if Int(selectedHoursString)! > 6 {
                            selectedHoursString = String(Int(selectedHoursString)! - 6)
                        } else if Int(selectedHoursString)! <= 6 {
                            selectedHoursString = "23"
                        }
                    }
            }
            
            Text(":")
                .font(.system(size: 20))
            
            VStack {
                /// 분 올리기 버튼
                Image(systemName: "chevron.up.2")
                    .onTapGesture {
                        if Int(selectedMinutesString)! < 59 {
                            selectedMinutesString = String(Int(selectedMinutesString)! + 1)
                        } else if Int(selectedMinutesString)! >= 59 {
                            selectedMinutesString = "00"
                        }
                    }
                    .onLongPressGesture {
                        if Int(selectedMinutesString)! < 50 {
                            selectedMinutesString = String(Int(selectedMinutesString)! + 10)
                        } else if Int(selectedMinutesString)! >= 50 {
                            selectedMinutesString = "00"
                        }
                    }
                TextField("mm", text: Binding(
                    get: { selectedMinutesString },
                    set: { newValue in
                        let filteredValue = newValue.filter { $0.isNumber }
                        let limitedValue = String(filteredValue.prefix(2))
                        
                        if let intValue = Int(limitedValue), intValue <= 60 {
                            selectedMinutesString = limitedValue
                        } else {
                            selectedMinutesString = "59"
                        }
                    }
                    
                    
                ))
                .frame(width: 40, height: 50)
                .font(.system(size: 20))
                /// 분 낮추기 버튼
                
                Image(systemName: "chevron.down.2")
                    .onTapGesture {
                        if Int(selectedMinutesString)! > 0 {
                            selectedMinutesString = String(Int(selectedMinutesString)! - 1)
                        } else if Int(selectedMinutesString)! <= 0 {
                            selectedMinutesString = "59"
                        }
                    }
                    .onLongPressGesture {
                        if Int(selectedMinutesString)! > 10 {
                            selectedMinutesString = String(Int(selectedMinutesString)! - 10)
                        } else if Int(selectedMinutesString)! <= 10 {
                            selectedMinutesString = "59"
                        }
                    }
                
            }
            
            
            Text(":")
                .font(.system(size: 20))
            
            VStack {
                /// 초 올리기 버튼
                Image(systemName: "chevron.up.2")
                    .onTapGesture {
                        if Int(selectedSecondString)! < 59 {
                            selectedSecondString = String(Int(selectedSecondString)! + 1)
                        } else if Int(selectedSecondString)! >= 59 {
                            selectedSecondString = "00"
                        }
                    }
                    .onLongPressGesture {
                        if Int(selectedSecondString)! < 50 {
                            selectedSecondString = String(Int(selectedSecondString)! + 10)
                        } else if Int(selectedSecondString)! >= 50 {
                            selectedSecondString = "00"
                        }
                    }
                TextField("ss", text: Binding(
                    get: { selectedSecondString },
                    set: { newValue in
                        let filteredValue = newValue.filter { $0.isNumber }
                        let limitedValue = String(filteredValue.prefix(2))
                        
                        if let intValue = Int(limitedValue), intValue <= 60 {
                            selectedSecondString = limitedValue
                        } else {
                            selectedSecondString = "59"
                        }
                    }
                ))
                .frame(width: 40, height: 50)
                .font(.system(size: 20))
                /// 초 낮추기 버튼
                Image(systemName: "chevron.down.2")
                    .onTapGesture {
                        if Int(selectedSecondString)! > 0 {
                            selectedSecondString = String(Int(selectedSecondString)! - 1)
                        } else if Int(selectedSecondString)! <= 0 {
                            selectedSecondString = "59"
                        }
                    }
                    .onLongPressGesture {
                        if Int(selectedSecondString)! > 10 {
                            selectedSecondString = String(Int(selectedSecondString)! - 10)
                        } else if Int(selectedSecondString)! <= 10 {
                            selectedSecondString = "59"
                        }
                    }
            }
            
            /// 시간 설정 완료 버튼
            Image(systemName: timeSeted ? "gear" : "checkmark")
                .onTapGesture {
                    lastSeletcted = (Int(selectedHoursString)! * 3600)
                    + (Int(selectedMinutesString)! * 60)
                    + Int(selectedSecondString)!
                    timeRemaining = lastSeletcted
                    timeSeted = true
                }
        }
    }
    
    // MARK: - 타이머 뷰
    private var timerView: some View {
        VStack {
            
            HStack {
                
                Text("\(String(format: "%02d", timeRemaining / 3600)):\(String(format: "%02d", (timeRemaining % 3600) / 60)):\(String(format: "%02d", timeRemaining % 60))")
                    .font(.system(size: 30))
                
                Button(action: {
                    timeSeted = false
                    isRunning = false
                    beepToggle = false
                    stopAlarmSound()
                }, label: {
                    Image(systemName: timeSeted ? "gear" : "checkmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                })
            }
            
            HStack {
                Text("Recording Time")
                
                Button {
                    isTimeRecording.toggle()
                } label: {
                    Image(systemName: isTimeRecording ? "checkmark" : "")
                        .frame(width: 10, height: 10)
                        .foregroundStyle(isTimeRecording ? .blue : .gray)
                        .font(.system(size: 14))
                        .bold()
                }
                
                Button(action: {
                    WindowManager.shared.showTimeRecordedList()
                }) {
                    Image(systemName: "list.bullet")
                        .resizable()
                        .frame(width: 10, height: 10)
                }
            }
            HStack {
                
                Button(){
                    isOnTop.toggle()
                } label: {
                    Image(systemName: isOnTop ? "pin.fill" : "pin.slash")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                
                Button(action: {
                    //                                isRunning.toggle()
                    //                                beepToggle.toggle()
                    if !isRunning {
                        startTimer()
                    } else {
                        stopTimer()
                    }
                    
                    
                }, label: {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    
                })
                Button(action: {
                    isRunning = false
                    timeRemaining = lastSeletcted
                    beepToggle = false
                    stopAlarmSound()
                }, label: {
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                })
                
                
            }
            .font(.system(size: 30))
        }
    }
}

#Preview {
    ContentView()
}
