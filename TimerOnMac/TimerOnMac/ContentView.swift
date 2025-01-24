import SwiftUI

struct ContentView: View {
    // 00:01을 초기값으로 설정
    @State private var selectedHoursString: String = "00"
    @State private var selectedMinutesString: String = "00"
    @State private var selectedSecondString: String = "00"
    @State private var selectedTotalTime: Int = 0
    @State private var isRunning: Bool = false
    @State private var setDone: Bool = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            
            
            HStack {
                TextField("HH", text: Binding(
                    get: { selectedHoursString },
                    set: { newValue in
                        selectedHoursString = String(newValue.filter { $0.isNumber }.prefix(2))
                       

                    }
                ))
                .frame(width: 40, height: 50)
                
                Text(":")
                
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
                Text(":")
                
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
               
                Button(action: {
                    
                }, label: {
                    Image(systemName: setDone ? "gear" : "checkmark")
                }
                
                )
                
            }
            .font(.system(size: 24))
            
            
            
            
            HStack {
                Button(action: {
                    isRunning.toggle()
                }, label: {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding()
                })
                Button(action: {}, label: {
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding()
                })
            }
            .font(.system(size: 30))
        }
        .padding()
        .onReceive(timer) { t in
            print("timer tick \(t)")
            if isRunning && selectedTotalTime > 0 {
                selectedTotalTime -= 1
            } else if selectedTotalTime == 0 {
                isRunning = false
            } else {
                // ignore
            }
        }
        
     
    }
}
#Preview {
    ContentView()
}
