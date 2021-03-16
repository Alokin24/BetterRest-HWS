//
//  ContentView.swift
//  BetterRest
//
//  Created by Nikola Anastasovski on 14.3.21.
//

import SwiftUI

struct ContentView: View {
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
   
    
    let model = SleepCalculator()
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
        
    func calculateBedTime() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let wake = hours*3600 + minutes*60
        
        do {
            let prediction = try model.prediction(wake: Double(wake), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            alertMessage = formatter.string(from: sleepTime)
            alertTitle = "Your ideal bedtime is..."
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
//        showingAlert = true
        
    }
    
    var body: some View {
        
//        calculateBedTime()
        
        NavigationView {
            Form {
                Section(header: Text("When do you want to wake up")
                            .font(.subheadline)) {
                    
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                        .onChange(of: wakeUp) { newValue in
                            calculateBedTime()
                        }
                        
                }
                 
                Section(header: Text("How much sleep do you want")
                            .font(.subheadline)) {
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }.onChange(of: sleepAmount) { newValue in
                        calculateBedTime()
                    }
                }
                
                Section(header: Text("Daily coffee intake")
                            .font(.subheadline)) {
                    
                    Picker(selection: $coffeeAmount, label: (coffeeAmount == 1) ?
                            Text("1 cup"): Text("\(coffeeAmount) cups")) {
                        ForEach(1...20, id: \.self) {
                            Text("\($0)")
                        }
                    }.onChange(of: coffeeAmount) { newValue in
                        calculateBedTime()
                    }
                    
//                    Stepper(value: $coffeeAmount, in: 1...20) {
//                        if coffeeAmount == 1 {
//                            Text("1 cup")
//                        } else {
//                            Text("\(coffeeAmount) cups")
//                        }
//                    }
                }
                
                Section(header: Text("Ideal goto bed time")
                            .font(.subheadline)) {
                    Text("\(alertTitle) \(alertMessage)")
                }
            }
//            .alert(isPresented: $showingAlert) {
//                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//            }
            .navigationBarTitle("BetterRest")
//            .navigationBarItems(trailing:
//                Button(action: calculateBedTime) {
//                    Text("Calculate")
//                }
//            )
        }.onAppear(perform: calculateBedTime)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}
