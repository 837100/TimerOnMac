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
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isOnTop = true
    
    @State private var selectedHoursString: String = "00"
    @State private var selectedMinutesString: String = "10"
    @State private var selectedSecondString: String = "00"
    
    @State private var lastSeletcted: Int = 0
    @State private var timeRemaining: Int = 0
    @State private var isRunning: Bool = false
    @State private var setDone: Bool = false
    @State private var beepToggle: Bool = false
    
    @State private var timer: AnyCancellable?
    
    
    var body: some View {
        VStack {
            HStack {
                if !setDone {
                    Button(){
                        
                        isOnTop.toggle()
                    } label: {
                        Image(systemName: isOnTop ? "pin.fill" : "pin.slash")
                    }.buttonStyle(PlainButtonStyle())
                    VStack {
                        /// 시간 올리기 버튼
                        Button(action:  {
                            if Int(selectedHoursString)! < 23 {
                                selectedHoursString = String(Int(selectedHoursString)! + 1)
                            } else if Int(selectedHoursString)! >= 23 {
                                selectedHoursString = "00"
                            }
                        }, label: {
                            Image(systemName: "chevron.up.2")
                        })
                        TextField("HH", text: Binding(
                            get: { selectedHoursString },
                            set: { newValue in
                                selectedHoursString = String(newValue.filter { $0.isNumber }.prefix(2))
                            }
                        ))
                        .frame(width: 40, height: 50)
                        .font(.system(size: 20))
                        
                        /// 시간 낮추기 버튼
                        Button(action:  {
                            if Int(selectedHoursString)! > 0 {
                                selectedHoursString = String(Int(selectedHoursString)! - 1)
                            } else if Int(selectedHoursString)! <= 0 {
                                selectedHoursString = "23"
                            }
                        }, label: {
                            Image(systemName: "chevron.down.2")
                        })
                        
                    }
                    
                    
                    Text(":")
                        .font(.system(size: 20))
                    
                    VStack {
                        /// 분 올리기 버튼
                        Button(action:  {
                            if Int(selectedMinutesString)! < 59 {
                                selectedMinutesString = String(Int(selectedMinutesString)! + 10)
                            } else if Int(selectedMinutesString)! >= 59 {
                                selectedMinutesString = "00"
                            }
                        }, label: {
                            Image(systemName: "chevron.up.2")
                        })
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
                        Button(action:  {
                            if Int(selectedMinutesString)! > 0 {
                                selectedMinutesString = String(Int(selectedMinutesString)! - 10)
                            } else if Int(selectedMinutesString)! <= 0 {
                                selectedMinutesString = "59"
                            }
                        }, label: {
                            Image(systemName: "chevron.down.2")
                        })
                    }
                    
                    
                    Text(":")
                        .font(.system(size: 20))
                    
                    VStack {
                        /// 초 올리기 버튼
                        Button(action:  {
                            if Int(selectedSecondString)! < 59 {
                                selectedSecondString = String(Int(selectedSecondString)! + 10)
                            } else if Int(selectedSecondString)! >= 59 {
                                selectedSecondString = "00"
                            }
                        }, label: {
                            Image(systemName: "chevron.up.2")
                        })
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
                        Button(action:  {
                            if Int(selectedSecondString)! > 0 {
                                selectedSecondString = String(Int(selectedSecondString)! - 10)
                            } else if Int(selectedSecondString)! <= 0 {
                                selectedSecondString = "59"
                            }
                        }, label: {
                            Image(systemName: "chevron.down.2")
                        })
                    }
                    
                    /// 시간 설정 완료 버튼
                    
                    Button(action: {
                        lastSeletcted = (Int(selectedHoursString)! * 3600)
                        + (Int(selectedMinutesString)! * 60)
                        + Int(selectedSecondString)!
                        timeRemaining = lastSeletcted
                        setDone = true
                        
                    }, label: {
                        Image(systemName: setDone ? "gear" : "checkmark")
                    })
                    
                    
                    
                    
                }
                
                // 시간 설정 완료 후
                if setDone {
                    
                    VStack {
                        
                        HStack {
                            Text("\(String(format: "%02d", timeRemaining / 3600)):\(String(format: "%02d", (timeRemaining % 3600) / 60)):\(String(format: "%02d", timeRemaining % 60))")
                                .font(.system(size: 30))
                            Button(action: {
                                
                                setDone = false
                                isRunning = false
                                beepToggle = false
                                stopAlarmSound()
                                
                            }, label: {
                                Image(systemName: setDone ? "gear" : "checkmark")
                            })
                        }
                        
                        .padding()
                        
                        
                        HStack {
                            
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
        
        .onChange(of: isRunning) {
            isOnTop = isRunning
        }
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
    
}

#Preview {
    ContentView()
}
