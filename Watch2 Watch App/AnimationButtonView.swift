//
//  ButtonView.swift
//  Watch2 Watch App
//
//  Created by jia yu on 2022/12/6.
//

import SwiftUI

struct AnimationButtonView: View {
    @State private var isTapped: Bool = false
    var body: some View {
        Text("image Button")
        Button(action:{
            self.isTapped.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isTapped.toggle()
            }
            imageButtonAction()
        }){
            Image(systemName: "leaf")
                .foregroundColor(.blue)
                .scaleEffect(isTapped ? 1.5 : 1)
                .animation(nil, value: 0)
                .rotationEffect(.degrees(isTapped ? 360 : 0))
                .animation(.spring(), value: 0)
                .imageScale(.large)
        }.buttonStyle(BorderedButtonStyle())
    }
    func imageButtonAction(){
        print("Leaf image button action")
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AnimationButtonView()
    }
}
