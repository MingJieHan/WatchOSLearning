//
//  ContentView.swift
//  Watch2 Watch App
//
//  Created by jia yu on 2022/11/28.

import SwiftUI

struct ContentView: View{
    @EnvironmentObject private var rootApp:Watch1Observer
//    private var selectedTab:Binding<Int>{
//        Binding(
//            get:{rootApp.tabSelected.rawValue},
//            set:{rootApp.tabSelected = TabBarItem(rawValue: $0)!}
//        )
//    }
    @StateObject var itemListModel = ItemListModel()
    var body: some View {
        TabView (){
            NavigationStack {
                Founds()
            }
            NavigationStack {
                Buttons()
            }
            NavigationStack {
                Others()
            }
            NavigationStack {
                AnimationButtonView()
            }
            NavigationStack{
                ItemList().environmentObject(ItemListModel.shortList)
            }
            NavigationStack{
                ProductivityChart()
            }
        }
        .tabViewStyle(.page)
        .navigationTitle("Sports HR")
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ItemListModel.shortList)
    }
}
