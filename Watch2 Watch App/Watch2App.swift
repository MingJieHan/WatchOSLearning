//
//  Watch2App.swift
//  Watch2 Watch App
//
//  Created by jia yu on 2022/11/28.
//

import SwiftUI

enum TabBarItem:Int{
    case Control
    case Main
    case Living
    case Message
    case Mine
}

enum SportState:Int{
    case Normal
    case Playing
    case Paused
    case Completed
}


final class Watch1Observer : ObservableObject{
    @Published var loaded:Bool = false
    @Published var loading:Bool = false
    @Published var logining:Bool = true
    @Published var state:SportState = SportState.Normal
    @Published var tabSelected:TabBarItem = .Control
    @Published var currentDuration:String = "0:00:00.00"
    @Published var currentHR:String = "--"
    @Published var currentLocation:String = ""
    @Published var currentSpeed:String = "--"
    
    var HRsArray:[NSNumber] = []
    var speedsArray:[NSNumber] = []
    var longitudeArray:[NSNumber] = []
    var latitudeArray:[NSNumber] = []
    var altitudeArray:[NSNumber] = []
    var timeArray:[NSNumber] = []
    var lastLocation:CLLocation!
    var duration:TimeInterval!
    var durationTimer:Timer!
    var recordTimer:Timer!
    
    func SportsAlert(title:String, message:String){
        WKInterfaceDevice().play(.notification)
        let cancel = WKAlertAction(title: "Okay", style: .cancel){}
        WKApplication.shared().rootInterfaceController!.presentAlert(withTitle:title,message:message,preferredStyle:.alert , actions: [cancel])
    }
}

var the:Watch1Observer = Watch1Observer()

@main
struct Watch2_Watch_AppApp: App {
    /* 开启 Watch2ExtensionDelegate 后， Application Delegate就不会被调用了*/
//    @WKExtensionDelegateAdaptor var appExtension:Watch2ExtensionDelegate
    
    @WKApplicationDelegateAdaptor var appDelegate: SportsHRWatchAppDelegate
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView().environmentObject(the)
            }
        }
        .backgroundTask(.appRefresh("WEATHER_DATA")) {
            await updateWeatherData()
        }
    }
    func updateWeatherData() async {
        print ("ccc")
    }
}
