import SDWebImage
import Foundation
import FirebaseAuth
import FirebaseStorage
import Firebase

struct ChatUser {
    let uid, email, profileImageURL, exchangesNum, booksNum, country, username, fullName, bio, link: String
}

struct BookData: Identifiable  {
    var id = UUID()
    var bookId, bookTitle, bookAuthor, bookYear, bookGenre, bookLanguage, bookCountry, bookCover, bookLocation, bookDescription, bookOwner: String
}

struct PostData: Identifiable  {
    var id = UUID()
    var text, postImage, postTime, postId: String
}

struct Message: Identifiable {
    var id = UUID()
    var sender, text, time, uid: String
}

struct Chat: Identifiable {
    var id = UUID()
    var chatID:String
    var secondUser: ChatUser
    var dialogue: [Message]
}

class AppViewModel: ObservableObject {

    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var username: String = ""
    @Published var country: String = ""
    @Published var fullName: String = ""
    @Published var bio: String = ""
    @Published var link: String = ""
    @Published var profileImageURL: String = ""
    @Published var signedIn = false
    @Published var booksNum = ""
    @Published var uid = ""
    @Published var exchangesNum = ""
    @Published var anotherChatUser: ChatUser?
    
    @Published var booksCollection:[BookData] = []
    
    @Published var postsHistory:[PostData] = []
    @Published var library:[BookData] = []
    
    @Published var dialogue:[Message] = []
    
    @Published var chats:[Chat] = []
    
    var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    init() {
        fetchCurrentUser()
        fetchBookCollection()
        fetchPosts()
        fetchLibrary()
        fetchAllMessages()
    }
    
    func getDate(date: Double)->String {
        let validDate = Date(timeIntervalSince1970: Double(date) / 1000)
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium

        return formatter.string(from: validDate)
    }
    
    private func fetchPosts() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        
        Firestore.firestore()
            .collection("users")
            .document(uid).collection("posts").order(by: "timePost", descending: true).getDocuments { querySnapshot, error in
             
                if let err = error {
                        print("Error getting documents: \(err)")
                    }
                else {
                        for data in querySnapshot!.documents {
                            let document = data.data()
                            self.postsHistory.append(
                                PostData(
                                    text: document["text"] as? String ?? "",
                                    postImage: document["coverUrl"] as? String ?? "",
                                    postTime: self.getDate(date: document["timePost"] as! Double),
                                    postId: document["uid"] as? String ?? ""
                                )
                            )
                        }
                    }
            }
        
    }
    
    private func fetchLibrary() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        
        Firestore.firestore().collection("books").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for userid in querySnapshot!.documents {
                    print("\(userid.documentID) \(uid)")
                    if userid.documentID != uid {
                        Firestore.firestore()
                            .collection("books")
                            .document(userid.documentID).collection("books").getDocuments { querySnapshot, error in
                             
                                if let err = error {
                                        print("Error getting documents: \(err)")
                                    }
                                else {
                                        for data in querySnapshot!.documents {
                                            let document = data.data()
                                            self.library.append(
                                                BookData(
                                                    bookId: document["uid"] as? String ?? "",
                                                    bookTitle: document["title"] as? String ?? "",
                                                    bookAuthor: document["author"] as? String ?? "",
                                                    bookYear: document["year"] as? String ?? "",
                                                    bookGenre: document["genre"] as? String ?? "",
                                                    bookLanguage: document["language"] as? String ?? "",
                                                    bookCountry: document["country"] as? String ?? "",
                                                    bookCover: document["cover"] as? String ?? "",
                                                    bookLocation: document["location"] as? String ?? "",
                                                    bookDescription: document["description"] as? String ?? "",
                                                    bookOwner: document["owner"] as? String ?? ""
                                                )
                                            )
                                        }
                                    }
                            }
                    }
                }
            }
        }
        
    }
    
    private func fetchBookCollection() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        
        Firestore.firestore()
            .collection("books")
            .document(uid).collection("books").getDocuments { querySnapshot, error in
             
                if let err = error {
                        print("Error getting documents: \(err)")
                    }
                else {
                        for data in querySnapshot!.documents {
                            let document = data.data()
                            self.booksCollection.append(
                                BookData(
                                    bookId: document["uid"] as? String ?? "",
                                    bookTitle: document["title"] as? String ?? "",
                                    bookAuthor: document["author"] as? String ?? "",
                                    bookYear: document["year"] as? String ?? "",
                                    bookGenre: document["genre"] as? String ?? "",
                                    bookLanguage: document["language"] as? String ?? "",
                                    bookCountry: document["country"] as? String ?? "",
                                    bookCover: document["cover"] as? String ?? "",
                                    bookLocation: document["location"] as? String ?? "",
                                    bookDescription: document["description"] as? String ?? "",
                                    bookOwner: document["owner"] as? String ?? ""
                                )
                            )
                        }
                    }
            }
        
    }

    private func fetchCurrentUser() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }

        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }

            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return

            }
            let uid = data["uid"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let profileImageURL = data["profileImageURL"] as? String ?? ""
            let exchangeNum = data["exchanges_num"] as? String ?? ""
            let booksNum = data["books_num"] as? String ?? ""
            let country = data["country"] as? String ?? ""
            let username = data["username"] as? String ?? ""
            let fullName = data["full_name"] as? String ?? ""
            let bio = data["bio"] as? String ?? ""
            let link = data["link"] as? String ?? ""
            
            self.chatUser = ChatUser(
                uid: uid,
                email: email,
                profileImageURL: profileImageURL,
                exchangesNum: exchangeNum,
                booksNum: booksNum,
                country: country,
                username: username,
                fullName: fullName,
                bio: bio,
                link: link
            )
            
            self.fullName = fullName
            self.username = username
            self.link = link
            self.bio = bio
            self.country = country
            self.profileImageURL = profileImageURL
            self.booksNum = booksNum
            self.uid = uid
            self.exchangesNum = exchangeNum
            self.booksNum = booksNum
            
        }
    }
    
    private func fetchAllMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
//        var userChats:[Chat] = []
        // Идем по списку чатов одного пользователя, получаем ID чата и ID пользователя
        Firestore.firestore()
            .collection("users")
            .document(uid).collection("chats").getDocuments { querySnapshot, error in

             
                if let err = error {
                        print("Error getting documents: \(err)")
                    }
                else {
                        for dataChat in querySnapshot!.documents {
                            // Получаем ID чата и ID пользователя
                            
                            let document = dataChat.data()
                            let chatID = dataChat.documentID
                            let secondUserId = document["secondUser"] as? String ?? ""
                            
                            // Далее с полученным ID чата идем в коллекцию чатов получать по нему все сообщения
                            // Создаем диалог персонального чата
                            
                            var dialogue:[Message] = []
                            
                            Firestore.firestore().collection("chats").document(chatID).collection("messages").order(by: "time", descending: false).getDocuments { querySnapshot, error in
                                
                                if let err = error {
                                        print("Error getting documents: \(err)")
                                    }
                                else {
                                    // Идем по всем сообщениям, закидываем их данные в message, потом кидаем в список сообщений - Диалог
                                        for dataMessage in querySnapshot!.documents {
                                            let documentMessage = dataMessage.data()
                                            let messageID = dataMessage.documentID
                                            dialogue.append(
                                                Message(
                                                    sender: documentMessage["sender"] as? String ?? "",
                                                    text: documentMessage["text"] as? String ?? "",
                                                    time: self.getDate(date: documentMessage["time"] as! Double),
                                                    uid: messageID
                                                )
                                            )
                                        }
                                    
                                    // Когда все получили - надо составить ChatUser структуру
                                    
                                    Firestore.firestore().collection("users").document(secondUserId).getDocument { snapshot, error in
                                        if let error = error {
                                            self.errorMessage = "Failed to fetch current user: \(error)"
                                            print("Failed to fetch current user:", error)
                                            return
                                        }

                                        guard let data = snapshot?.data() else {
                                            self.errorMessage = "No data found"
                                            return

                                        }
                                        
                                        var secondChatUser = ChatUser(
                                            uid: data["uid"] as? String ?? "",
                                            email: data["email"] as? String ?? "",
                                            profileImageURL: data["profileImageURL"] as? String ?? "",
                                            exchangesNum: data["exchanges_num"] as? String ?? "",
                                            booksNum: data["books_num"] as? String ?? "",
                                            country: data["country"] as? String ?? "",
                                            username: data["username"] as? String ?? "",
                                            fullName: data["full_name"] as? String ?? "",
                                            bio: data["bio"] as? String ?? "",
                                            link: data["link"] as? String ?? ""
                                        )
                                        
                                        self.chats = [Chat(chatID: chatID, secondUser: secondChatUser, dialogue: dialogue)]
                                        
                                    }
                                }
                            }
                        }
                }
            }
        print(self.chats)
        
    }
    
    func fetchChatUser(userID: String) {


        Firestore.firestore().collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }

            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return

            }
            let uid = data["uid"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let profileImageURL = data["profileImageURL"] as? String ?? ""
            let exchangeNum = data["exchanges_num"] as? String ?? ""
            let booksNum = data["books_num"] as? String ?? ""
            let country = data["country"] as? String ?? ""
            let username = data["username"] as? String ?? ""
            let fullName = data["full_name"] as? String ?? ""
            let bio = data["bio"] as? String ?? ""
            let link = data["link"] as? String ?? ""
            
            self.anotherChatUser = ChatUser(
                uid: uid,
                email: email,
                profileImageURL: profileImageURL,
                exchangesNum: exchangeNum,
                booksNum: booksNum,
                country: country,
                username: username,
                fullName: fullName,
                bio: bio,
                link: link
            )
            
        }
    }
    
    func getAnotherChatUser(userID:String) -> ChatUser{
        fetchChatUser(userID: userID)
        return self.anotherChatUser ?? ChatUser(uid: "", email: "", profileImageURL: "", exchangesNum: "", booksNum: "", country: "", username: "", fullName: "", bio: "", link: "")
    }

}
//
//func getDate(date: Double)->String {
//    let validDate = Date(timeIntervalSince1970: Double(date) / 1000)
//    let formatter = DateFormatter()
//    formatter.dateStyle = .long
//    formatter.timeStyle = .medium
//
//    return formatter.string(from: validDate)
//}
