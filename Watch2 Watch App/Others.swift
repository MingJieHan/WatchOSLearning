//
//  Others.swift
//  Watch2 Watch App
//
//  Created by jia yu on 2022/12/6.
//

import SwiftUI

struct Others: View {
    var body: some View {
        Text("Others")
        NavigationLink("Pink", value: Color.pink)
    }
}

struct Others_Previews: PreviewProvider {
    static var previews: some View {
        Others()
    }
}
