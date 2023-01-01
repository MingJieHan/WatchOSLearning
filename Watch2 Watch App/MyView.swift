//
//  MyView.swift
//  Watch2 Watch App
//
//  Created by jia yu on 2022/12/29.
//

import SwiftUI

struct MyView: View {
    let c:Color!
    var body: some View {
        c.overlay(
            VStack{
                Text("abc")
            }
        )
//        Color.purple
//            .overlay(
//                VStack(spacing:0) {
//            })
//            .edgesIgnoringSafeArea(.vertical)
//        .background(RoundedCorners(color: .blue, tl: 0, tr: 30, bl: 30, br: 0))
    }
        
}

