//
//  EditBookView.swift
//  BookCrossing
//
//  Created by Олеся Мартынюк on 25.05.2022.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseStorage
import FirebaseAuth
import Firebase

struct AddNewBookView: View {
    @Environment(\.presentationMode) var presentation
    
    @ObservedObject var vm = AppViewModel()
    
    @State var shouldShowImagePicker = false
    @State var image: UIImage?
    @State var isPhotoChanged = false
    
    @State private var titleColor = Color(.white)
    @State private var authorColor = Color(.white)
    @State private var genreColor = Color(.white)
    @State private var yearColor = Color(.white)
    @State private var countryColor = Color(.white)
    @State private var locationColor = Color(.white)
    @State private var descriptionColor = Color(.white)
    @State private var languageColor = Color(.white)
    
    @State private var title = ""
    @State private var author = ""
    @State private var genre = ""
    @State private var year = ""
    @State private var country = ""
    @State private var location = ""
    @State private var description = ""
    @State private var language = ""
    
    @State private var showingErrorAlert = false
    @State private var goToPrevView = false
    @State private var logMessage = "Changes are saved"
    @State private var showLoading = false
    
    init(){
            UITableView.appearance().backgroundColor = .clear
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
                            Image(coverImage())
                                .resizable()
                                .frame(width: 160, height: 180)
                                    .cornerRadius(12)
                        }
                    }
                        
                    Button(action: {changeCoverPhoto()}, label: {
                        Text("Change book cover")
                            .font(.custom("GillSans-Light", size: 20))
                            .foregroundColor(Color("buttonColor"))
                    })
                    Form {
                        Section(header: Text("General information").font(.custom("GillSans-Light", size: 16))) {
                            
                            TextField("", text: $title)
                                .placeholder(when: title.isEmpty) {
                                    Text("Title").foregroundColor(Color("inactiveTextField"))
                                }
                                .foregroundColor(titleColor)
                            
                            TextField("", text: $author)
                                .placeholder(when: author.isEmpty) {
                                    Text("Author").foregroundColor(Color("inactiveTextField"))
                                }
                                .foregroundColor(authorColor)
                            
                            TextField("", text: $genre)
                                .placeholder(when: genre.isEmpty) {
                                    Text("Genre").foregroundColor(Color("inactiveTextField"))
                                }
                                .foregroundColor(genreColor)
                            
                            TextField("", text: $language)
                                .placeholder(when: language.isEmpty) {
                                    Text("Language").foregroundColor(Color("inactiveTextField"))
                                }
                                .foregroundColor(languageColor)
                            
                            TextField("", text: $year)
                                .placeholder(when: year.isEmpty) {
                                    Text("Year").foregroundColor(Color("inactiveTextField"))
                                }
                                .foregroundColor(yearColor)
                            
                            TextField("", text: $country)
                                .placeholder(when: country.isEmpty) {
                                    Text("Country").foregroundColor(Color("inactiveTextField"))
                                }
                                .foregroundColor(countryColor)
                            
                            TextField("", text: $location)
                                .placeholder(when: location.isEmpty) {
                                    Text("Book Location").foregroundColor(Color("inactiveTextField"))
                                }
                                .foregroundColor(locationColor)
                            
                        }.listRowBackground(Color("elementBackgroundColor"))
                            .font(.custom("GillSans-Light", size: 20))
                        Section(header: Text("Additional information").font(.custom("GillSans-Light", size: 16))) {
                            TextField("", text: $description)
                                .placeholder(when: description.isEmpty) {
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
                        Text("ADD BOOK")
                            .font(.custom("GillSans", size: 18))
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color("buttonColor"))
                            .cornerRadius(6)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 4, trailing: 10))
                    }).alert(isPresented:$showingErrorAlert) {
                        Alert(title: Text(""), message: Text(logMessage), dismissButton: .default(Text("Continue")){
                                if goToPrevView {
                                    self.presentation.wrappedValue.dismiss()
                                }
                            })
                       }
                }
                .navigationBarTitleDisplayMode(.inline)
                .padding(EdgeInsets(top: 12, leading: 10, bottom: 8, trailing: 10))
                
                if showLoading {
                    ZStack {
                        Color("backgroundColor")
                            .ignoresSafeArea()
                            .opacity(0.8)
                        VStack(alignment: .center, spacing: 24) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color("buttonColor")))
                                .scaleEffect(3)
                            Text("Uploading your book")
                                .foregroundColor(.white)
                                .font(.custom("GillSans-Light", size: 20))
                        }
                    }
                }
                
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(content: {
               ToolbarItem (placement: .navigation)  {
                   VStack {
                       HStack(spacing: 15) {
                           Image(systemName: "arrow.left")
                           Text("Add new book")
                               .font(.custom("GillSans", size: 32))
                           Spacer()
                       }
                        .foregroundColor(.white)
                   }
                   
                  .onTapGesture {
                      // code to dismiss the view
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
        
        var imageURL: String = ""
        var isValidImage = false
        
        showingErrorAlert = false
        goToPrevView = false
        showLoading = false

        if isValidFields() {
            
            // If all fields contain valid values ...
            
            // Get book uid ...
            let bookUid = randomString(length: 16)
            
            // Upload cover photo to storage ...
            
            if isPhotoChanged {
                showLoading = true
                if let image = self.image {
                    guard let uid = Auth.auth().currentUser?.uid else { return }
                    let ref = Storage.storage().reference(withPath: ("booksCover/\(bookUid)"))
                    guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
                    ref.putData(imageData, metadata: nil) { metadata, err in
                        if let err = err {
                            showLoading = false
                            logMessage = "Failed to push image to Storage: \(err)"
                            showingErrorAlert = true
                            return
                        }

                        ref.downloadURL { url, err in
                            if let err = err {
                                showLoading = false
                                logMessage = "Failed to retrieve downloadURL: \(err)"
                                showingErrorAlert = true
                                return
                            }
                            imageURL = url?.absoluteString ?? ""
                            
                            
                            // Update user statistics ...
                            var newBooksNum: String = ""
                            guard let uid = Auth.auth().currentUser?.uid else { return }
                            if let oldBooksNum = Int(vm.booksNum) {
                                newBooksNum = String(oldBooksNum+1)
                            }
                            else {
                                showLoading = false
                                logMessage = "Error while updating books statistics"
                                showingErrorAlert = true
                            }
                            let userData = [
                                "books_num": newBooksNum,
                            ]
                            
                            Firestore.firestore()
                                .collection("users")
                                .document(uid).updateData(userData) {
                                    err in
                                    if err != nil {
                                        showLoading = false
                                        logMessage = "Error while updating books statistics"
                                        showingErrorAlert = true
                                        return
                                    }
                                }
                            
                            // Add book to user's collection
                            
                            let values = [
                                "author": author,
                                "country": country,
                                "cover": imageURL,
                                "description": description,
                                "location": location,
                                "owner": uid,
                                "title": title,
                                "year": year,
                                "genre": genre,
                                "language": language,
                                "uid": bookUid
                            ]
                            Firestore.firestore()
                                .collection("books")
                                .document(uid).collection("books").document(bookUid).setData(values) { err in
                                    if let err = err {
                                        logMessage = err.localizedDescription
                                        showingErrorAlert = true
                                        return
                                    }
                                }
                            Firestore.firestore()
                                .collection("books")
                                .document(uid).setData(["exists": true]) { err in
                                    if let err = err {
                                        showLoading = false
                                        logMessage = err.localizedDescription
                                        showingErrorAlert = true
                                        return
                                    }
                                    showLoading = false
                                    logMessage = "New book has been added"
                                    showingErrorAlert = true
                                }
                            if !addPostNewBook(imageURL: imageURL) {
                                showLoading = false
                                logMessage = "Error while creating post"
                                showingErrorAlert = true
                                return
                            }
                            showLoading = false
                            logMessage = "New book has been added"
                            goToPrevView = true
                            showingErrorAlert = true
                        }
                    }
                }
                else {
                    showLoading = false
                    logMessage = "Error while uploading photo"
                    showingErrorAlert = true
                    return
                }
    
            }
            else {
                showLoading = false
                logMessage = "Please upload cover image"
                showingErrorAlert = true
                return
            }
        }
        else {
            logMessage = "Please fill in valid values"
            if !isValidDescription() {
                logMessage = "Please write shorter description"
            }
            showLoading = false
            showingErrorAlert = true
            return
        }

    }
    
    func addPostNewBook(imageURL: String)->Bool {
        let postUid = randomString(length: 16)
        let values = [
            "coverUrl": imageURL,
            "text": "added new book for crossing: \(title) by \(author)",
            "timePost": Date().currentTimeMillis(),
            "uid": postUid
        ] as [String : Any]
        
        guard let uid = Auth.auth().currentUser?.uid else { return false}
        Firestore.firestore()
            .collection("users")
            .document(uid).collection("posts").document(postUid).setData(values) { err in
                if let err = err {
                }
            }
        return true
    }
    
    func isValidFields()->Bool {
        var flag:Bool = true
        if !isValidField(field: author) {
            flag = false
        }
        if !isValidField(field: title) {
            flag = false
        }
        if !isValidField(field: genre) {
            flag = false
        }
        if !isValidYear(year: year) {
            yearColor = .orange
            flag = false
        }
        if !isValidField(field: country) {
            flag = false
        }
        if !isValidField(field: language) {
            flag = false
        }
        if !isValidField(field: location) {
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
        if description.count <= 500 {
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
}

struct AddNewBookView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewBookView()
    }
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
