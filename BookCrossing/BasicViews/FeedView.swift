//
//  FeedView.swift
//  BookCrossing
//
//  Created by Олеся Мартынюк on 22.05.2022.
//

import SwiftUI

struct FeedView: View {
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color("backgroundColor"))
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color("inactiveBottomBarIcons"))
    }
    @Environment(\.presentationMode) var presentation
    @State var activeTab = 1
    var body: some View {
        TabView (selection: $activeTab){
            CrossingView(activeTab: $activeTab)
                    .tabItem() {
                        Image("crossingsIcon").renderingMode(.template)
                        Text("CROSSINGS")
                    }.tag(1)
                .edgesIgnoringSafeArea(.top)
            ChatsView(activeTab: $activeTab)
                    .tabItem() {
                        Image("chatsIcon").renderingMode(.template)
                        Text("CHATS")
                    }.tag(2)
                .edgesIgnoringSafeArea(.top)
            ProfileView(activeTab: $activeTab)
                    .tabItem() {
                        Image("profileIcon").renderingMode(.template)
                        Text("PROFILE")
                    }.tag(3)
                .edgesIgnoringSafeArea(.top)
            
            }
            .accentColor(.white)
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            
            
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
