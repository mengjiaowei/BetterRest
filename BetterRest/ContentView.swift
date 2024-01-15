//
//  ContentView.swift
//  BetterRest
//
//  Created by MJ Wei on 13/1/2024.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var idealBedtime = ""

    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    var body: some View {
        NavigationStack{
            Form {
                Section{
                    Text("When do you want to wake up?")
                        .font(.headline)
                    HStack{
                        Spacer()
                        DatePicker("Please enter a time", selection: $wakeUp,displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
                .onChange(of: wakeUp){
                    calculateBedtime()
                }
                Section{
                    Text("Desired amoutn of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours",value: $sleepAmount,in: 3...16, step: 0.25)
                }
                .onChange(of: sleepAmount){
                    calculateBedtime()
                }
                Section{
                    Text("Daily coffee intake")
                        .font(.headline)
                    Stepper("^[\(coffeeAmount) cup](inflect:true)",value: $coffeeAmount, in: 0...20)
                }
                .onChange(of: coffeeAmount){
                    calculateBedtime()
                }
                Section{
                    Text("Go to bed at")
                        .font(.headline)
                    Text(idealBedtime)
                }
            }
            .navigationTitle("BetteRest")
        }
    }

    
    func calculateBedtime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Int64(Double(hour+minute)), estimatedSleep: sleepAmount, coffee: Int64(Double(coffeeAmount)))
            let sleepTime = wakeUp-prediction.actualSleep
            
            idealBedtime =  sleepTime.formatted(date:.omitted, time: .shortened)
        } catch {
            idealBedtime =  "something went wrong :("
        }
        
    }
}
#Preview {
        ContentView()
    }
    
