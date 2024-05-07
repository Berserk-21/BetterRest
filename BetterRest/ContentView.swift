//
//  ContentView.swift
//  BetterRest
//
//  Created by Berserk on 06/05/2024.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    static var defaultWakeUpTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeUpTime
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                }
                
                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted())", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section("Daily coffee intake") {
                    Picker("^[\(coffeeAmount + 1) cup](inflect: true)", selection: $coffeeAmount) {
                        ForEach(1..<21) {
                            Text("\($0)")
                        }
                    }
                }
                
                Section("Ideal bedtime") {
                    HStack {
                        Spacer()
                        Text(calculateBetTime())
                            .font(.largeTitle)
                            .frame(alignment: .center)
                        Spacer()
                    }
                }
            }
            
            .navigationTitle("BetterRest")
        }
    }
    
    private func calculateBetTime() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Int64(hour + minute), estimatedSleep: sleepAmount, coffee: Int64(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            return "Sorry, there was a problem calculating your bedtime."
        }
    }
}

#Preview {
    ContentView()
}
