//
//  SubmitView.swift
//  Watch2 Watch App
//
//  Created by jia yu on 2022/12/6.
//

import SwiftUI

struct AddItemLink: View {
    @EnvironmentObject private var model: ItemListModel
    
    var body: some View {
        VStack {
            TextFieldLink(prompt: Text("New Item")) {
                Label("Add", systemImage: "plus.circle.fill")
            } onSubmit: {
                model.items.insert(ListItem($0), at: 0) //insert in first
//                model.items.append(ListItem($0))      //append in last
            }.foregroundColor(Color.blue)
            Spacer()
                .frame(height: 5.0)
        }
    }
}

struct SubmitView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemLink()
    }
}
