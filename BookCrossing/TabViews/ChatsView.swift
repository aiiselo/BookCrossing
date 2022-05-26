//
//  ChatsView.swift
//  BookCrossing
//
//  Created by Олеся Мартынюк on 22.05.2022.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseAuth
import FirebaseStorage
import Firebase

struct ChatsView: View {
    
    @Binding var activeTab: Int
    @State var shouldNavigateToChatLogView = false
    @ObservedObject var vm = AppViewModel()
    @State var profileImageURL = ""
    @State var profileNickname = ""
    @State var secondUserUsername = ""
    @State var dialogueChat:[Message] = []
    var body: some View {
        VStack {
            VStack{
                HStack(spacing: 4){
                    Text("Chats")
                        .foregroundColor(.white)
                        .font(.custom("GillSans", size: 32))
                    Spacer(minLength: 0)
                }
                .background(Color("backgroundColor"))
                .padding(EdgeInsets(top: 28, leading: 10, bottom: 0, trailing: 10))
                .padding([.horizontal, .top])
                Divider().background(Color("inactiveTextField"))
                ScrollView(.vertical, showsIndicators: false, content: {
                    VStack(spacing: 2){
                        ForEach(vm.chats) { collection in
                            
                            NavigationLink(destination: ChatLogsView(chatUserUsername: $secondUserUsername, dialogue: $dialogueChat), isActive: $shouldNavigateToChatLogView) {
                                Button(action: {
                                    secondUserUsername = collection.secondUser.username
                                    dialogueChat = collection.dialogue
                                    shouldNavigateToChatLogView = true
                                }, label: {
                                    HStack {
                                        ZStack {
                                            if collection.secondUser.profileImageURL == "" || vm.chatUser?.profileImageURL == nil{
                                                Image("defaultAvatar")
                                                    .resizable()
                                             } else {
                                                if let profileImageLink = collection.secondUser.profileImageURL {
                                                    WebImage(url: URL(string: String(profileImageLink)))
                                                        .resizable()
                                                }
                                            }
                                        }
                                        .frame(width: 76, height: 76)
                                        .clipShape(Circle())
                                        .padding(EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 8))
                                        VStack(alignment: .leading) {
                                            Text(collection.secondUser.username)
                                                .font(.custom("GillSans", size: 22))
                                                .foregroundColor(.white)
                                            Text(collection.dialogue[0].text)
                                                .font(.custom("GillSans-Light", size: 18))
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.leading)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .background(Color("elementBackgroundColor"))
                                    .cornerRadius(6)
                //                    .padding()
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                })
                            }
                        }
                    }
                    .padding([.horizontal])
                    })
            }
            Divider().background(Color("inactiveTextField"))
        }
        .background(Color("backgroundColor"))
        .navigationBarHidden(true)
    }

    
}

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsView(activeTab: .constant(2))
    }
}


