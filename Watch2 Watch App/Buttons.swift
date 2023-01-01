//
//  Buttons.swift
//  Watch2 Watch App
//
//  Created by jia yu on 2022/12/6.
//

import SwiftUI
import CoreLocation

struct Buttons: View {
    @State private var hr:Int = -1
    @State private var hrTesting:Bool = false
    @State private var webString:String = "--"
    @State private var locationing:Bool = false
    @State private var currentSpeed:CLLocationSpeed!
    @State private var currentAltitude:CLLocationDegrees!
    @State private var currentCoordinate:CLLocationCoordinate2D!
    @State private var audioPlaying:Bool = false
//    @State  var userName:String = "hans"
//    @State  var passWord:String = "123456"
    
    func alertDemo(){
        let action = WKAlertAction(title: "Action", style: .default) {print("Action")}
        let cancel = WKAlertAction(title: "Cancel", style: .cancel){}
        WKApplication.shared().rootInterfaceController!.presentAlert(withTitle:"title",message:"message",preferredStyle:.alert , actions: [action,cancel])
    }
    init(){
    }
    var body: some View {
        Text("Lists")
        List {
            VStack {
                HStack{
                    Button("A"){
                        
                    }.buttonStyle(BorderedButtonStyle())
                    Button("B"){
                        
                    }.buttonStyle(DefaultButtonStyle())
                    Button("C"){
                        
                    }.buttonStyle(PlainButtonStyle())
                }

                Button("Alert Demo"){
                    self.alertDemo()
                }.buttonStyle(BorderedButtonStyle())
                
//                TextField("User Name", text: $userName)
//                            .textContentType(.username)
//                            .multilineTextAlignment(.center)
//                SecureField("Password", text: $passWord)
//                    .textContentType(.password)
//                    .multilineTextAlignment(.center)
                //                Button("Sign In"){
                //                    userName = "username"
                //                }.disabled(userName.isEmpty || passWord.isEmpty)
                
                if (locationing){
                    if nil != currentAltitude{
                        Text("A \(currentAltitude)")
                    }
                    if nil != currentSpeed{
                        Text("S \(currentSpeed)")
                    }
                    if nil != currentCoordinate{
                        Text("L \(currentCoordinate.longitude) \(currentCoordinate.latitude)")
                    }
                    Button("Stop Location"){
                        locationing = false
                    }.buttonStyle(BorderedButtonStyle())
                }else{
                    Button("Start Location"){
                        locationing = true
                    }.buttonStyle(BorderedButtonStyle())
                }

                Spacer()
                if (hrTesting){
                    if (hr > 0){
                        Text("HR \(hr)")
                    }else{
                        Text("HR --")
                    }
                    Button("Stop HR"){
                        hrTesting = false
                        hr = -1
                    }.buttonStyle(BorderedButtonStyle())
                }else{
                    Text("--")
                    Button("Start HR"){
                        hrTesting = true
                        hr = -1
                    }.buttonStyle(BorderedButtonStyle())
                }
                Spacer()
                Text(webString)
                Button("web") {
                    webString = "loadding ..."
                }.buttonStyle(BorderedButtonStyle())
                
                
                Spacer()
                if audioPlaying{
                    Button("Stop"){
                        audioPlaying = false
                    }.buttonStyle(BorderedButtonStyle())
                }else{
                    Button("Start"){
                        audioPlaying = true
                        let file = Bundle.main.path(forResource: "ttt", ofType: "mp3")
                        let url = NSURL.fileURL(withPath: file!)
                    }.buttonStyle(BorderedButtonStyle())
                }
            }
            .padding()
        }
        .listStyle(CarouselListStyle())
    }
}

struct Buttons_Previews: PreviewProvider {
    static var previews: some View {
        Buttons()
    }
}
