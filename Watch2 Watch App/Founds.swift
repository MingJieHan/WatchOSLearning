//
//  Founds.swift
//  Watch2 Watch App
//
//  Created by jia yu on 2022/12/6.
//

import SwiftUI

struct Founds: View {
    var recordFile:String = NSHomeDirectory().appending("/Documents/record.m4a") //ext name must .m4a
    var body: some View {
        GeometryReader { proxy in
            ScrollView{
                HStack(spacing:-10){
                    MyView(c: Color.red).frame(width:0.1 * proxy.size.width).cornerRadius(16)
                    MyView(c: Color.green).frame(width:0.1 * proxy.size.width).cornerRadius(16)
                    MyView(c: Color.purple).frame(width:0.8 * proxy.size.width).cornerRadius(16)
                }.frame(height: 40)
                VStack{
                    Image(systemName: "leaf.fill")
                    ProgressView()
                        .frame(width: 20, height: 20)
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                }.frame(height: proxy.size.height)
                
                VStack{
                    Image(systemName: "leaf.fill")
                    ProgressView()
                        .frame(width: 20, height: 20)
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                }.frame(height: proxy.size.height)
            }
        }
        List {
            VStack{
                //        let webstring = try! AttributedString(
                //            markdown: "**Thank You!** Please visit our [website](https://www.hamingjie.com/).")
                //        Text(webstring)

                Button("Present Controller"){
                    WKApplication.shared().rootInterfaceController?.presentController(withNames: ["CCCInterfaceController"], contexts: nil)
                }.buttonStyle(BorderedButtonStyle())
                Spacer(minLength: 15)
//                
                Button("Text Input"){
                    WKApplication.shared().rootInterfaceController?.presentTextInputController(withSuggestions: ["default text","second word"], allowedInputMode: WKTextInputMode.allowEmoji, completion: { res in
                        print(res)
                    })
                }.buttonStyle(BorderedButtonStyle())
                Spacer(minLength: 15)
                
                Button("Record M4A"){
                    //requires "com.apple.carousel.backlightaccess" entitlement
                    /*
                     <key>com.apple.carousel.backlightaccess</key>
                     <true/>
                     */
                    let url = NSURL.fileURL(withPath: recordFile)
                    WKApplication.shared().rootInterfaceController?.presentAudioRecorderController(withOutputURL: url, preset:WKAudioRecorderPreset.highQualityAudio, completion: { res, error in
                        if nil != error{
                            print("Record Error:" + error!.localizedDescription)
                            return
                        }
                        if false == res{
                            print("start record failed.")
                            return
                        }
                        print("Recrod audio finished.")
                    })
                    print ("start record view")
                }.buttonStyle(BorderedButtonStyle())
                if FileManager().fileExists(atPath: recordFile){
                    Button("Play M4A"){
                        let file = NSHomeDirectory().appending("/Documents/record.m4a")
                        let url = NSURL.fileURL(withPath: file)
                        WKApplication.shared().rootInterfaceController?.presentMediaPlayerController(with: url, completion: { completed, t, error in
                            
                        })
                    }.buttonStyle(BorderedButtonStyle())
                }
                Spacer(minLength: 25)
                Button("Demo MP4"){
                    let file = Bundle.main.path(forResource: "ttt", ofType: "mp4")
                    let url = NSURL.fileURL(withPath: file!)
                    WKApplication.shared().rootInterfaceController?.presentMediaPlayerController(with: url, completion: { completed, t, error in

                    })
                }.buttonStyle(BorderedButtonStyle())
                Button("Demo MP3"){
                    let file = Bundle.main.path(forResource: "ttt", ofType: "mp3")
                    let url = NSURL.fileURL(withPath: file!)
                    WKApplication.shared().rootInterfaceController?.presentMediaPlayerController(with: url, completion: { completed, t, error in

                    })
                }.buttonStyle(BorderedButtonStyle())
            }
            .scrollContentBackground(.hidden)
        }
        .scrollContentBackground(.hidden)
    }
    
}

struct Founds_Previews: PreviewProvider {
    static var previews: some View {
        Founds()
    }
}
