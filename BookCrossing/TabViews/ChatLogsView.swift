//
//  ChatLogsView.swift
//  BookCrossing
//
//  Created by Олеся Мартынюк on 27.05.2022.
//

import SwiftUI

struct ChatLogsView: View {

    @Binding var chatUserUsername: String
    @Binding var dialogue: [Message]
    @Environment(\.presentationMode) var presentation
    @State private var answer = ""
    @ObservedObject var vm = AppViewModel()
    
    @State private var showingAlert = false
    @State private var logMessage = ""
    init(chatUserUsername: Binding<String>, dialogue: Binding<[Message]>){
        self._chatUserUsername = chatUserUsername
        self._dialogue = dialogue
    }
    
    var body: some View {
        NavigationView {
            ZStack{
                
                Color("backgroundColor").ignoresSafeArea()
                VStack(spacing: 16) {
                    ScrollView(.vertical, showsIndicators: false, content: {
                        ForEach(dialogue) { message in
                            
                            if message.sender == vm.uid {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(vm.username)
                                    Text(message.text)
                                    Text(vm.getDate(date: Double(message.time) ?? 15.0))
                                    
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .background(Color("elementBackgroundColor"))
                                .cornerRadius(6)
            //                    .padding()
                                .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                            }
                            else {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(chatUserUsername)
                                    Text(message.text)
                                    Text(vm.getDate(date: Double(message.time) ?? 15.0))
                                    
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .background(Color("colorOpponentMessage"))
                                .cornerRadius(6)
            //                    .padding()
                                .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                            }
                            
                        }
                    })
                    HStack{
                        ZStack(alignment: .leading){
                            if answer.isEmpty {
                                Text("Type answer")
                                    .foregroundColor(Color("inactiveTextField"))
                            }
                            TextField("",text: $answer)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .foregroundColor(.white)
                        }
                        .frame(width: .infinity, height: 48)
                        .padding(.all)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(lineWidth: 2, antialiased: true)
                                    .foregroundColor(.white)
                            )
                        .padding(.leading)
                        .padding(.trailing)
                        
                        Button("Send") {
                        }
                        .font(.custom("GillSans", size: 18))
                        .foregroundColor(.white)
                        .frame(width: 100, height: 48)
                        .background(Color("buttonColor"))
                        .cornerRadius(6)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .alert(isPresented:$showingAlert) {
                            Alert(title: Text(""), message: Text(logMessage), dismissButton: .default(Text("Continue")){
                                
                                                    })
                                                }
                    }
                    
                }
                
                .navigationBarTitleDisplayMode(.inline)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 8, trailing: 10))
                Spacer()
                
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(content: {
               ToolbarItem (placement: .navigation)  {
                   VStack {
                       HStack(spacing: 15) {
                           Image(systemName: "arrow.left")
                           Text("Chat with \(chatUserUsername)")
                               .font(.custom("GillSans", size: 32))
                           Spacer()
                       }
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



struct ChatLogsView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    struct PreviewWrapper: View {
        
        @State(initialValue: "") var chatUserUsername: String
        @State(initialValue: []) var dialogue: [Message]

        var body: some View {
            ChatLogsView(chatUserUsername: $chatUserUsername, dialogue: $dialogue)
        }
      }
}
