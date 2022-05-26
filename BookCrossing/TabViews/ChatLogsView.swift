//
//  ChatLogsView.swift
//  BookCrossing
//
//  Created by Олеся Мартынюк on 27.05.2022.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage

struct ChatLogsView: View {
    @Binding var chatUserDestination: String
    @Binding var chatUserUsername: String
    @Binding var dialogue: [Message]
    @Environment(\.presentationMode) var presentation
    @State private var answer = ""
    @ObservedObject var vm = AppViewModel()
    
    @State private var showingAlert = false
    @State private var logMessage = ""
    init(chatUserUsername: Binding<String>, chatUserDestination: Binding<String>, dialogue: Binding<[Message]>){
        self._chatUserUsername = chatUserUsername
        self._chatUserDestination = chatUserDestination
        self._dialogue = dialogue
    }
    
    var body: some View {
        NavigationView {
            ZStack{
                
                Color("backgroundColor").ignoresSafeArea()
                VStack(spacing: 16) {
                    ScrollView(.vertical, showsIndicators: false, content: {
                        ForEach(dialogue) { message in
                            MessageItem(messageText: message.text, messageSender: message.sender, messageTime: message.time)
                        }
                    })
                    Spacer()
                    MessageField(destinationUser: self.chatUserDestination)
                    
                }
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                .navigationBarTitleDisplayMode(.inline)
                
                
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(content: {
               ToolbarItem (placement: .navigation)  {
                   VStack {
                       HStack(spacing: 15) {
                           Image(systemName: "arrow.left")
                           Text(chatUserUsername)
                               .font(.custom("GillSans", size: 32))
                           Spacer()
                       }
                       .background(Color("backgroundColor"))
                        .foregroundColor(.white)
                       Divider()
                           .foregroundColor(Color("inactiveTextField"))
                   }
                  .onTapGesture {
                      // code to dismiss the view
                      self.presentation.wrappedValue.dismiss()
                  }
               }
            })
        }.navigationBarHidden(true)
                       
    }
}

struct MessageItem: View {
    let messageText: String
    let messageSender: String
    let messageTime: String
    @ObservedObject var vm = AppViewModel()
    
    @State private var showTime = false
    var body: some View {
        VStack(alignment: messageSender == vm.uid ? .trailing : .leading) {
            HStack {
                Text(messageText)
                    .padding()
                    .font(.custom("GillSans-Light", size: 18))
                    .background(messageSender == vm.uid ? Color("elementBackgroundColor") : Color("colorOpponentMessage"))
                    .foregroundColor(messageSender == vm.uid ? .white : .black)
                    .cornerRadius(30)
            }
            .frame(maxWidth: 300, alignment: messageSender == vm.uid ? .trailing : .leading)
            .onTapGesture {
                showTime.toggle()
            }
            
            if showTime {
                Text(messageTime)
                    .font(.custom("GillSans-Light", size: 16))
                    .foregroundColor(Color("inactiveTextField"))
                    .padding(messageSender == vm.uid ? .trailing : .leading, 25)
            }
        }
        .frame(maxWidth: .infinity, alignment: messageSender == vm.uid ? .trailing : .leading)
        .padding(messageSender == vm.uid ? .trailing : .leading)
        .padding(.horizontal)
    }
}

struct MessageField: View {
    @State private var message = ""
    let destinationUser: String
    var body: some View {
        HStack {
            CustomTextField(placeholder: Text("Enter reply"), text: $message)
            Button {
                if !message.isEmpty {
                    sendMessage(text:message, destinationUser: destinationUser)
                }
                message = ""
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color("buttonColor"))
                    .cornerRadius(50)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color("inactiveTextField"))
        .cornerRadius(50)
        .padding()
    }
}

func sendMessage(text: String, destinationUser: String) {
    
    let uid = Auth.auth().currentUser!.uid
    Firestore.firestore().collection("users").document(uid).collection("chats").whereField("secondUser", isEqualTo: destinationUser).getDocuments { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
            return
        } else {
            let documents = querySnapshot!.documents
            
            let chatId = documents[0].documentID
            let messageID = randomString(length: 16)
            Firestore.firestore().collection("chats").document(chatId).collection("messages").document(messageID).setData([
                "sender" : uid,
                "text": text,
                "time": Date().currentTimeMillis(),
            ] as [String : Any]) { err in
                if let err = err {
                    return
                }
            }
            
        }
    }
}

func randomString(length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0..<length).map{ _ in letters.randomElement()! })
}

struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String
    var edititngChanged: (Bool) -> () = {_ in}
    var commit: () -> () = {}
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                placeholder.opacity(0.5)
            }
            TextField("", text: $text, onEditingChanged: edititngChanged, onCommit: commit)
        }
    }
}


struct ChatLogsView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    struct PreviewWrapper: View {
        
        @State(initialValue: "") var chatUserUsername: String
        @State(initialValue: "") var chatUserDestination: String
        @State(initialValue: []) var dialogue: [Message]

        var body: some View {
            ChatLogsView(chatUserUsername: $chatUserUsername, chatUserDestination: $chatUserDestination, dialogue: $dialogue)
        }
      }
}
