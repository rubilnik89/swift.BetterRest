//
//  ContentView.swift
//  BetterRest
//
//  Created by Roman Zherebko on 23.05.2022.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var cofeeAmount = 1

    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var recommendedBedTime: String {
        calculateBedTime()
    }
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 6
        components.minute = 30
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("When do you want to wake up?")) {
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    
                    Section(header: Text("Desired amount of sleep")) {
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                    
                    Section(header: Text("Daily coffee intake")) {
                        Picker("Daily coffee intake", selection: $cofeeAmount) {
                            ForEach(1 ..< 20) {
                                Text($0 == 1 ? "1 cup" : "\($0) cups")
                            }
                        }
                    }
                }
                .frame(maxHeight: 350)
                .clipShape(RoundedRectangle(cornerRadius: 50))
                .navigationTitle("BetterRest")
            
                Text("Your ideal bedtime is")
                    .font(.largeTitle.bold())
                Text("\(recommendedBedTime)")
                    .font(.largeTitle.bold())
                    .foregroundColor(.mint)
                    
                Spacer()
            }
        }
    }
    
    func calculateBedTime() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(cofeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            return formatter.string(from: sleepTime)
        } catch {
            return "Error"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
