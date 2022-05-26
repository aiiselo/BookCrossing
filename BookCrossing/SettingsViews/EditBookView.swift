//
//  EditBookView.swift
//  BookCrossing
//
//  Created by Олеся Мартынюк on 26.05.2022.
//

import SwiftUI

import SDWebImageSwiftUI
import FirebaseStorage
import FirebaseAuth
import Firebase

struct EditBookView: View {
    
    @Environment(\.presentationMode) var presentation
    
    @ObservedObject var vm = AppViewModel()
    
    @State var shouldShowImagePicker = false
    @State var image: UIImage?
    @State var isPhotoChanged = false
    
    @State private var titleColor = Color(.white)
    @State private var authorColor = Color(.white)
    @State private var genreColor = Color(.white)
    @State private var yearColor = Color(.white)
    @State private var ownerColor = Color(.white)
    @State private var countryColor = Color(.white)
    @State private var locationColor = Color(.white)
    @State private var descriptionColor = Color(.white)
    @State private var languageColor = Color(.white)
    
    @State private var showingAlert = false
    @State private var logMessage = ""
    @State private var showingAlertDelete = false
    @State private var goToPrevView = false
    
    @Binding var collection: BookData
    
    init(collection: Binding<BookData>){
            UITableView.appearance().backgroundColor = .clear
            self._collection = collection
        }
    
    var body: some View {
        NavigationView {
            ZStack{
                Color("backgroundColor").ignoresSafeArea()
                VStack(spacing: 16) {
                    
                    VStack {
                        if let image = self.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 160, height: 180)
                                .cornerRadius(12)
                        }
                        else {
                            if let coverImageLink = collection.bookCover {
                                WebImage(url: URL(string: String(coverImageLink)))
                                    .resizable()
                                    .frame(width: 160, height: 180)
                                    .cornerRadius(12)
                            } else {
                                Image(coverImage())
                                    .resizable()
                                    .frame(width: 160, height: 180)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    
                    
                        
                    Button(action: {changeCoverPhoto()}, label: {
                        Text("Change book cover")
                            .font(.custom("GillSans-Light", size: 20))
                            .foregroundColor(Color("buttonColor"))
                    })
                    Form {
                        Section(header: Text("General information").font(.custom("GillSans-Light", size: 16))) {
                            
                            TextField("", text: $collection.bookTitle)
                                .placeholder(when: collection.bookTitle.isEmpty) {
                                    Text("Title").foregroundColor(Color("inactiveTextField"))
                                }
                                .foregroundColor(titleColor)
                            
                            TextField("", text: $collection.bookAuthor)
                                .placeholder(when: collection.bookAuthor.isEmpty) {
                                    Text("Author").foregroundColor(Color("inactiveTextField"))
                                }
                                .foregroundColor(authorColor)
                            
                            TextField("", text: $collection.bookGenre)
                                .placeholder(when: collection.bookGenre.isEmpty) {
                                    Text("Genre").foregroundColor(Color("inactiveTextField"))
                                }
                                .foregroundColor(genreColor)
                            
                            TextField("", text: $collection.bookLanguage)
                                .placeholder(when: collection.bookLanguage.isEmpty) {
                                    Text("Language").foregroundColor(Color("inactiveTextField"))
                                }
                                .foregroundColor(languageColor)
                            
                            TextField("", text: $collection.bookYear)
                                .placeholder(when: collection.bookYear.isEmpty) {
                                    Text("Year").foregroundColor(Color("inactiveTextField"))
                                }
                                .foregroundColor(yearColor)
                            
                            TextField("", text: $collection.bookCountry)
                                .placeholder(when: collection.bookCountry.isEmpty) {
                                    Text("Country").foregroundColor(Color("inactiveTextField"))
                                }
                                .foregroundColor(countryColor)
                            
                            TextField("", text: $collection.bookLocation)
                                .placeholder(when: collection.bookLocation.isEmpty) {
                                    Text("Book Location").foregroundColor(Color("inactiveTextField"))
                                }
                                .foregroundColor(locationColor)
                            
                            TextField("", text: $collection.bookOwner)
                                .placeholder(when: collection.bookOwner.isEmpty) {
                                    Text("Owner UID").foregroundColor(Color("inactiveTextField"))
                                }
                                .foregroundColor(ownerColor)
                            
                        }.listRowBackground(Color("elementBackgroundColor"))
                            .font(.custom("GillSans-Light", size: 20))
                        Section(header: Text("Additional information").font(.custom("GillSans-Light", size: 16))) {
                            TextField("", text: $collection.bookDescription)
                                .placeholder(when: collection.bookDescription.isEmpty) {
                                    Text("Description").foregroundColor(Color("inactiveTextField"))
                                }
                                .foregroundColor(descriptionColor)
                                .disableAutocorrection(true)
                            
                        
                        }.listRowBackground(Color("elementBackgroundColor"))
                            .font(.custom("GillSans-Light", size: 20))
                    }
                    
                    .foregroundColor(Color(.white))
                    .background(Color("backgroundColor"))
                    Spacer()
                    
                    Button(action: {saveChanges()}, label: {
                        Text("SAVE CHANGES")
                            .font(.custom("GillSans", size: 18))
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color("buttonColor"))
                            .cornerRadius(6)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 4, trailing: 10))
                    }).alert(isPresented:$showingAlert) {
                        Alert(title: Text(""), message: Text(logMessage), dismissButton: .default(Text("Continue")){
                            if goToPrevView {
                                self.presentation.wrappedValue.dismiss()
                            }
                                                })
                                            }
                }
                .navigationBarTitleDisplayMode(.inline)
                .padding(EdgeInsets(top: 12, leading: 10, bottom: 8, trailing: 10))
                
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(content: {
               ToolbarItem (placement: .navigation)  {
                   HStack(spacing: 4) {
                           Image(systemName: "arrow.left")
                           Text("Edit book")
                               .font(.custom("GillSans", size: 32))
                               .padding()
                           Spacer(minLength: 0)
                           Button(action: {
                               removeBookFromBookDatabase(bookId: collection.bookId)
                               updateUserBookStatistics()
                               showingAlertDelete = true
                           }, label: {
                               Image("trashIcon").frame(width: 32, height: 32)
                           })
                           .alert(isPresented:$showingAlertDelete) {
                               Alert(title: Text("Book has been deleted"), message: Text(logMessage), dismissButton: .default(Text("Continue")){
                                   self.presentation.wrappedValue.dismiss()
                               })
                            }
                           
                       }
                   .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                   .frame(width: UIScreen.main.bounds.size.width)
                   .foregroundColor(.white)
                   .onTapGesture {
                      self.presentation.wrappedValue.dismiss()
                  }
               
               }
               
            })
            .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
                        ImagePicker(image: $image)
                            .ignoresSafeArea()
                    }
        }.navigationBarHidden(true)
    }
    
    
    func coverImage() -> String {
        return "defaultCover"
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func saveChanges() {
        yearColor = Color(.white)
        descriptionColor = Color(.white)
        ownerColor = Color(.white)
        var imageURL: String = ""
        var isValidImage = false
        showingAlert = false
        logMessage = ""
        
        if isEditedOwner() {
            
                Firestore.firestore()
                    .collection("users")
                    .document(collection.bookOwner).getDocument { snapshot, error in
                        if let error = error {
                            logMessage =  "No user found"
                            ownerColor = .orange
                            showingAlert = true
                            return
                        }

                        guard let data = snapshot?.data() else {
                            logMessage = "No user found"
                            showingAlert = true
                            return
                        }
                        
                        let secondUserUsername = data["username"] as? String ?? ""
                        let secondUserExchangesNum = data["exchanges_num"] as? String ?? ""
                        
                        addPostNewExchange(secondUser: collection.bookOwner, secondUserUsername: secondUserUsername, secondUserExchangesNum: secondUserExchangesNum)
                        
                        removeBookFromBookDatabase(bookId: collection.bookId)
                        updateUserBookStatistics()
                        logMessage = "You changed book owner. Thank you for participating in book crossing!"
                        goToPrevView = true
                    }
        }
        else {
            
            if isValidFields() {
                // Update book collection
                
                let values = [
                    "author": collection.bookAuthor,
                    "country": collection.bookCountry,
                    "description": collection.bookDescription,
                    "location": collection.bookLocation,
                    "title": collection.bookTitle,
                    "year": collection.bookYear,
                    "genre": collection.bookGenre,
                    "language": collection.bookLanguage,
                ]
                guard let uid = Auth.auth().currentUser?.uid else { return }
                Firestore.firestore()
                    .collection("books")
                    .document(uid).collection("books").document(collection.bookId).updateData(values) { err in
                        if let err = err {
                            print(err)
                            return
                        }
                        logMessage = "Book information has been changed"
                        vm.fetchLibrary()
                    }
                if isPhotoChanged {
                    if let image = self.image {
                        guard let uid = Auth.auth().currentUser?.uid else { return }
                        let ref = Storage.storage().reference(withPath: ("booksCover/\(collection.bookId)"))
                        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
                        ref.putData(imageData, metadata: nil) { metadata, err in
                            if let err = err {
                                logMessage = "Failed to push image to Storage: \(err)"
                                showingAlert = true
                                return
                            }

                            ref.downloadURL { url, err in
                                if let err = err {
                                    logMessage = "Failed to retrieve downloadURL: \(err)"
                                    showingAlert = true
                                    return
                                }
                                
                                let values = [
                                    "cover": url?.absoluteString ?? ""
                                    ]
                                guard let uid = Auth.auth().currentUser?.uid else { return }
                                Firestore.firestore()
                                    .collection("books")
                                    .document(uid).collection("books").document(collection.bookId).updateData(values) { err in
                                        if let err = err {
                                            print(err)
                                            return
                                        }
                                    }
                                collection.bookCover = url?.absoluteString ?? ""
                                
                            }
                        }
                        logMessage = "Successfully stored image"
                    }
                    
                }
            }
            else {
                logMessage = "Please fill in general information"
            }
        }
        showingAlert = true

    }
    
    func isEditedOwner()->Bool {
        if collection.bookOwner != vm.uid {
            return true
        }
        else {
            return false
        }
    }
    
    func removeBookFromBookDatabase(bookId: String)->Void {
        Firestore.firestore().collection("books").document(vm.uid).collection("books").document(bookId).delete() { err in
            if let err = err {
                logMessage = "Error removing document: \(err)"
                return
            }
        }
    }
    
    func updateUserBookStatistics()->Void {
        var newBooksNum: String = ""
        
        if let oldBooksNum = Int(vm.booksNum) {
            newBooksNum = String(oldBooksNum-1)
        }
        else {
            logMessage = "Error while updating books statistics"
            showingAlert = true
        }
        
        var userData = [
            "books_num": newBooksNum
        ]
        
        Firestore.firestore()
            .collection("users")
            .document(vm.uid).updateData(userData) {
                err in
                if let err = err {
                    print(err)
                    logMessage = "Error while updating books statistics"
                    showingAlert = true
                    return
                }
            }
    }
    
    func isValidFields()->Bool {
        var flag:Bool = true
        if !isValidField(field: collection.bookAuthor) {
            flag = false
        }
        if !isValidField(field: collection.bookTitle) {
            flag = false
        }
        if !isValidField(field: collection.bookGenre) {
            flag = false
        }
        if !isValidYear(year: collection.bookYear) {
            yearColor = .orange
            flag = false
        }
        if !isValidField(field: collection.bookCountry) {
            flag = false
        }
        if !isValidField(field: collection.bookLanguage) {
            flag = false
        }
        if !isValidField(field: collection.bookLocation) {
            flag = false
        }
        if !isValidDescription() {
            descriptionColor = .orange
            flag = false
        }
        
        return flag
        
    }
    
    func isValidImageURL(url: String)->Bool {
        if url != "" {
            return true
        }
        else {
            return false
        }
    }
    
    func isValidDescription() -> Bool {
        if collection.bookDescription.count <= 500 {
            return true
        }
        else {
            return false
        }
    }
    
    func isValidField(field: String) -> Bool {
        if field != "" && field.count < 100 {
            return true
        }
        else {
            return false
        }
    }
    
    
    func isValidYear(year: String) -> Bool {
        if let yearNum = Int(year) {
            if yearNum > 0 && yearNum <= Calendar.current.component(.year, from: Date()) {
                return true
            }
            return false
        }
        else {
            return false
        }
    }
    
    
    func changeCoverPhoto() {
        shouldShowImagePicker.toggle()
        isPhotoChanged  = true
    }
        
    func addPostNewExchange(secondUser: String, secondUserUsername: String, secondUserExchangesNum: String)->Bool {
        let postUid = randomString(length: 16)
        let valuesFirstUser = [
            "coverUrl": collection.bookCover,
            "text": "gave book \(collection.bookTitle) by \(collection.bookAuthor) to \(secondUserUsername). Happy reading!",
            "timePost": Date().currentTimeMillis(),
            "uid": postUid
        ] as [String : Any]
        
        let valuesSecondUser = [
            "coverUrl": collection.bookCover,
            "text": "got book \(collection.bookTitle) by \(collection.bookAuthor) from \(vm.username). New adventure is coming!",
            "timePost": Date().currentTimeMillis(),
            "uid": postUid
        ] as [String : Any]
        
        Firestore.firestore()
            .collection("users")
            .document(vm.uid).collection("posts").document(postUid).setData(valuesFirstUser) { err in
                if let err = err {
                    print(err)
                    return
                }
            }
        
        Firestore.firestore()
            .collection("users")
            .document(secondUser).collection("posts").document(postUid).setData(valuesSecondUser) { err in
                if let err = err {
                    print(err)
                    return
                }
            }
        
        // Update first user statistics ...
        
        updateUserBookStatistics()
        var newExchangesNum: String = ""
        if let oldExchangesNum = Int(vm.exchangesNum) {
            newExchangesNum = String(oldExchangesNum+1)
        }
        else {
            logMessage = "Error while updating books statistics"
            showingAlert = true
        }
        var userData = [
            "exchanges_num": newExchangesNum
        ]
        
        Firestore.firestore()
            .collection("users")
            .document(vm.uid).updateData(userData) {
                err in
                if let err = err {
                    print(err)
                    logMessage = "Error while updating books statistics"
                    showingAlert = true
                    return
                }
            }
        
        // Update second user statistics ...
        newExchangesNum = ""
        
        if let oldExchangesNum = Int(secondUserExchangesNum) {
            newExchangesNum = String(oldExchangesNum+1)
        }
        else {
            logMessage = "Error while updating books statistics"
            showingAlert = true
        }
        userData = [
            "exchanges_num": newExchangesNum
        ]
        
        Firestore.firestore()
            .collection("users")
            .document(secondUser).updateData(userData) {
                err in
                if let err = err {
                    print(err)
                    logMessage = "Error while updating books statistics"
                    showingAlert = true
                    return
                }
            }
        
        return true
    }

}

struct EditBookView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    struct PreviewWrapper: View {
        @State(initialValue: BookData(bookId: "", bookTitle: "", bookAuthor: "", bookYear: "", bookGenre: "", bookLanguage: "", bookCountry: "", bookCover: "", bookLocation: "", bookDescription: "", bookOwner: "")) var collection: BookData

        var body: some View {
          EditBookView(collection: $collection)
        }
      }
}
