//
//  CrossingView.swift
//  BookCrossing
//
//  Created by Олеся Мартынюк on 22.05.2022.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseStorage
import FirebaseAuth
import Firebase

struct CrossingView: View {
    @Binding var activeTab: Int
    @ObservedObject var vm = AppViewModel()
    @State private var isShownDescription = false
    @State private var shouldNavigateToChatLogView = false
    @State private var buttonText = "MORE"
    @State private var chatExistsFlag:Bool = false
    
    @State private var showingAlert = false
    @State private var logMessage = ""
    
    var body: some View {
            VStack {
                VStack{
                    HStack(spacing: 4){
                        Text("Available crossings")
                            .foregroundColor(.white)
                            .font(.custom("GillSans", size: 32))
                        Spacer(minLength: 0)
                    }
                    .background(Color("backgroundColor"))
                    .padding(EdgeInsets(top: 28, leading: 10, bottom: 0, trailing: 10))
                    .padding([.horizontal, .top])
                    Divider().background(Color("inactiveTextField"))
                }
                ScrollView(.vertical, showsIndicators: false, content: {
                    VStack(alignment: .customCenter){
                        ForEach(vm.library) { collection in
                            ZStack{
                                VStack {
                                    HStack{
                                        
                                        // Short description ..
                                       
                                        VStack(alignment: .leading) {
                                            Text(collection.bookTitle)
                                                .font(.custom("GillSans-Light", size: 24))
                                                .foregroundColor(.white)
                                            Spacer()
                                            Text("Author: \(collection.bookAuthor)")
                                                .font(.custom("GillSans-Light", size: 16))
                                                .foregroundColor(.white)
                                            Text("Year: \(collection.bookYear)")
                                                .font(.custom("GillSans-Light", size: 16))
                                                .foregroundColor(.white)
                                            HStack(spacing: 8) {
                                                Text("Genre: \(collection.bookGenre)")
                                                    .font(.custom("GillSans-Light", size: 16))
                                                    .foregroundColor(.white)
                                                Text("Language: \(collection.bookLanguage)")
                                                    .font(.custom("GillSans-Light", size: 16))
                                                    .foregroundColor(.white)
                                            }
                                            HStack(spacing: 8) {
                                                Text("Country: \(collection.bookCountry)")
                                                    .font(.custom("GillSans-Light", size: 16))
                                                    .foregroundColor(.white)
                                                Text("Location: \(collection.bookLocation)")
                                                    .font(.custom("GillSans-Light", size: 16))
                                                    .foregroundColor(.white)
                                                
                                            }
                                            Spacer()
                                        }.padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                                        Spacer()
                                        // Cover Image ..
                                        WebImage(url: URL(string: collection.bookCover))
                                            .resizable()
                                            .frame(width: 100, height: 140)
                                            .cornerRadius(12)
                                    }
                                    if isShownDescription {
                                        VStack(alignment: .leading) {
                                            Text(collection.bookDescription)
                                                .foregroundColor(.white)
                                                .font(.custom("GillSans-Light", size: 16))
                                        }.padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                                            
                                    }
                                    HStack {
                                        // Button More/less
                                        Button(buttonText) {
                                            if isShownDescription {
                                                isShownDescription = false
                                                buttonText = "MORE"
                                            }
                                            else {
                                                isShownDescription = true
                                                buttonText = "LESS"
                                            }
                                        }
                                        .font(.custom("GillSans", size: 18))
                                        .foregroundColor(Color("buttonColor"))
                                        .frame(width: 100, height: 48)
                                        
                                        .overlay(
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .strokeBorder(lineWidth: 2, antialiased: true)
                                                        .foregroundColor(Color("buttonColor"))
                                                )
                                        // Button Cross Now
                                        
                                        Button("CROSS NOW") {
                                            createChatWithNewUser(anotherUser: collection.bookOwner, bookTitle: collection.bookTitle, bookAuthor: collection.bookAuthor)
                                        }
                                        .font(.custom("GillSans", size: 18))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, minHeight: 48)
                                        .background(Color("buttonColor"))
                                        .cornerRadius(6)
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                        .alert(isPresented:$showingAlert) {
                                            Alert(title: Text(""), message: Text(logMessage), dismissButton: .default(Text("Continue")){
                                                
                                                                    })
                                                                }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .background(Color("elementBackgroundColor"))
                                .cornerRadius(6)
                                
                            }
                            .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                        }
                    }
                })
                Divider().background(Color("inactiveTextField"))
            }
            .background(Color("backgroundColor"))
            .navigationBarHidden(true)
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    private func createChatWithNewUser(anotherUser: String, bookTitle: String, bookAuthor: String) {
        showingAlert = false
        guard let uid = Auth.auth().currentUser?.uid else {
            logMessage = "Could not find firebase uid"
            return
        }
        Firestore.firestore().collection("users").document(uid).collection("chats").whereField("secondUser", isEqualTo: anotherUser).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                let documents = querySnapshot!.documents
                if documents.count == 0 {
                        let chatId = randomString(length: 16)
                        Firestore.firestore().collection("users").document(uid).collection("chats").document(chatId).setData(
                            ["secondUser": anotherUser]) { err in
                            if let err = err {
                                logMessage = "Error during chat creating"
                                return
                            }
                        }
                        Firestore.firestore().collection("users").document(anotherUser).collection("chats").document(chatId).setData(
                            ["secondUser": uid]) { err in
                            if let err = err {
                                logMessage = "Error during chat creating"
                                return
                            }
                        }
                        Firestore.firestore().collection("chats").document(chatId).setData(
                            ["exists" : true]) { err in
                            if let err = err {
                                logMessage = "Error during chat creating"
                                return
                            }
                        }
                        let firstMessageID = randomString(length: 16)
                        Firestore.firestore().collection("chats").document(chatId).collection("messages").document(firstMessageID).setData([
                            "sender" : uid,
                            "text": "Hi! I want to take this book: \(bookTitle) by \(bookAuthor). Is this still available?",
                            "time": Date().currentTimeMillis(),
                        ] as [String : Any]) { err in
                            if let err = err {
                                logMessage = "Error during chat creating"
                                return
                            }
                        }
                }
                else {
                    let chatId = documents[0].documentID
                    let firstMessageID = randomString(length: 16)
                    Firestore.firestore().collection("chats").document(chatId).collection("messages").document(firstMessageID).setData([
                        "sender" : uid,
                        "text": "Hi! I want to take this book: \(bookTitle) by \(bookAuthor). Is this still available?",
                        "time": Date().currentTimeMillis(),
                    ] as [String : Any]) { err in
                        if let err = err {
                            logMessage = "Error during chat creating"
                            return
                        }
                    }
                }
            }
        }
        showingAlert = true
        logMessage = "Chat with book owner has been created. Please check CHATS tab"
        
        
    }
    
    
    
        
}

struct BookItem: View {
    
    @ObservedObject var vm = AppViewModel()
    
    var body: some View {
        ZStack{
            HStack {
                VStack(alignment: .leading) {
                    Image("thirdOnboardingImage")
                        .resizable()
                        .frame(width: 100, height: 140)
                        .cornerRadius(12)
                    Button("MORE") {
                        
                    }
                    .font(.custom("GillSans", size: 18))
                    .foregroundColor(Color("buttonColor"))
                    .frame(width: 100, height: 48)
                    
                    .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(lineWidth: 2, antialiased: true)
                                    .foregroundColor(Color("buttonColor"))
                            )
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("")
                    Text("The Catcher in the Rye")
                        .font(.custom("GillSans-Light", size: 24))
                        .foregroundColor(.white)
                    Text("by Jerome Salinger")
                        .font(.custom("GillSans-Light", size: 16))
                        .foregroundColor(.white)
                    Text("Recently Caught by Krofi")
                        .font(.custom("GillSans-Light", size: 16))
                        .foregroundColor(.white)
                    Text("Nordrhein-Westfalen, Germany")
                        .font(.custom("GillSans-Light", size: 16))
                        .foregroundColor(.white)
                    Spacer()
                    Button("CROSS NOW") {
                        
                    }
                    .font(.custom("GillSans", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color("buttonColor"))
                    .cornerRadius(6)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                
                
            }
            .frame(maxWidth: .infinity)
            .background(Color("elementBackgroundColor"))
            .cornerRadius(6)
        }
        .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
        
    }
    
    private var profileImage: some View {
        ZStack {
            if vm.chatUser?.profileImageURL == "" || vm.chatUser?.profileImageURL == nil{
                Image("thirdOnboardingImage")
                    .resizable()
             } else {
                if let profileImageLink = vm.chatUser?.profileImageURL {
                    WebImage(url: URL(string: String(profileImageLink)))
                        .resizable()
                }
            }
        }
    }
    
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    
    var configure: (UINavigationController) -> Void = { _ in }
    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController  {
            self.configure(nc)
        }
    }
}

struct CrossingView_Previews: PreviewProvider {
    static var previews: some View {
        CrossingView(activeTab: .constant(1))
    }
}
