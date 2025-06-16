//
//  TimeRecordedList.swift
//  TimerOnMac
//
//  Created by SG on 6/16/25.
//

import SwiftUI

// 타이머 기록을 위한 모델
struct TimerRecord: Identifiable, Hashable {
    var id = UUID()
    var date: Date
    var duration: Int // 초 단위
    var completedSuccessfully: Bool
    
    // 날짜 문자열 (그룹핑용)
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd" 
        return formatter.string(from: date)
    }
    
    // 시간 문자열
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // 지속 시간 포맷
    var durationFormatted: String {
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct TimeRecordedList: View {
    // 예시 데이터 - 실제로는 ContentView에서 데이터를 전달받아야 합니다
    @State private var timerRecords: [TimerRecord] = [
        // 오늘
        TimerRecord(date: Date(), duration: 600, completedSuccessfully: true),
        TimerRecord(date: Date().addingTimeInterval(-3600), duration: 1500, completedSuccessfully: true),
        TimerRecord(date: Date().addingTimeInterval(-7200), duration: 300, completedSuccessfully: false),
        
        // 어제
        TimerRecord(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, duration: 900, completedSuccessfully: false),
        TimerRecord(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!.addingTimeInterval(-7200), duration: 1800, completedSuccessfully: true),
        TimerRecord(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!.addingTimeInterval(-14400), duration: 2400, completedSuccessfully: true),
        // 이틀 전
        TimerRecord(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, duration: 1200, completedSuccessfully: true),
        // 어제
        TimerRecord(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, duration: 900, completedSuccessfully: false),
        TimerRecord(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!.addingTimeInterval(-7200), duration: 1800, completedSuccessfully: true),
        TimerRecord(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!.addingTimeInterval(-14400), duration: 2400, completedSuccessfully: true),
        // 어제
        TimerRecord(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, duration: 900, completedSuccessfully: false),
        TimerRecord(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!.addingTimeInterval(-7200), duration: 1800, completedSuccessfully: true),
        TimerRecord(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!.addingTimeInterval(-14400), duration: 2400, completedSuccessfully: true),
        // 어제
        TimerRecord(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, duration: 900, completedSuccessfully: false),
        TimerRecord(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!.addingTimeInterval(-7200), duration: 1800, completedSuccessfully: true),
        TimerRecord(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!.addingTimeInterval(-14400), duration: 2400, completedSuccessfully: true),
    ]
    
    
    // 일별로 그룹화된 기록
    var groupedRecords: [String: [TimerRecord]] {
        Dictionary(grouping: timerRecords) { record in
            record.dateString
        }
    }
    
    // 정렬된 일자 키
    var sortedDates: [String] {
        groupedRecords.keys.sorted { date1, date2 in
            // 날짜 비교 로직 (최신순)
            if let first = timerRecords.first(where: { $0.dateString == date1 }),
               let second = timerRecords.first(where: { $0.dateString == date2 }) {
                return first.date > second.date
            }
            return false
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("타이머 기록")
                    .font(.headline)
                    .padding(.leading)
                
                Spacer()
                
                Button(action: {
                    // 정렬 또는 필터링 로직
                }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
                .buttonStyle(.plain)
                .padding(.trailing)
            }
            .padding(.top, 8)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16, pinnedViews: []) {
                    ForEach(sortedDates, id: \.self) { dateString in
                        VStack(alignment: .leading, spacing: 8) {
                            // 섹션 헤더 (고정되지 않음)
                            HStack {
                                Text(dateString)
                                    .font(.headline)
                                Spacer()
                                Text("총 \(dailyTotalDuration(for: dateString))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.top, 4)
                            Divider() // 헤더와 내용 사이에 구분선 추가
                                 .padding(.horizontal)
                            
                            // 섹션 내용
                            ForEach(groupedRecords[dateString] ?? [], id: \.id) { record in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(record.timeString)
                                            .font(.body)
                                        Text("지속시간: \(record.durationFormatted)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: record.completedSuccessfully ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(record.completedSuccessfully ? .green : .red)
                                }
                                
                                .padding(.vertical, 4)
                                .padding(.horizontal)
                                Divider() // 헤더와 내용 사이에 구분선 추가
                                .padding(.horizontal)
                            }
                        }
                        .background(Color(NSColor.controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 2)
                
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }
    
    // 일별 총 시간 계산
    func dailyTotalDuration(for dateString: String) -> String {
        let records = groupedRecords[dateString] ?? []
        let totalSeconds = records.reduce(0) { $0 + $1.duration }
        
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    TimeRecordedList()
}
