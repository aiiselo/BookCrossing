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
    
    @State private var showingAlert = false
    @State private var logMessage = "Changes are saved"
    
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
                    }).alert(isPresented:$showingAlert) {
                        Alert(title: Text(""), message: Text(logMessage), dismissButton: .default(Text("Continue")){
                                                })
                                            }
                }
                .navigationBarTitleDisplayMode(.inline)
                .padding(EdgeInsets(top: 12, leading: 10, bottom: 8, trailing: 10))
                
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
        titleColor = Color(.white)
        authorColor = Color(.white)
        genreColor = Color(.white)
        yearColor = Color(.white)
        countryColor = Color(.white)
        locationColor = Color(.white)
        descriptionColor = Color(.white)
        languageColor = Color(.white)
        
        var imageURL: String = ""
        var isValidImage = false
        showingAlert = false
        
        
        if isValidFields() {
            
            // If all fields contain valid values ...
            
            // Get book uid ...
            let bookUid = randomString(length: 16)
            
            // Upload cover photo to storage ...
            
            if isPhotoChanged {
                if let image = self.image {
                    guard let uid = Auth.auth().currentUser?.uid else { return }
                    let ref = Storage.storage().reference(withPath: ("booksCover/\(bookUid)"))
                    guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
                    ref.putData(imageData, metadata: nil) { metadata, err in
                        if let err = err {
                            print("Failed to push image to Storage: \(err)")
                            return
                        }

                        ref.downloadURL { url, err in
                            if let err = err {
                                print("Failed to retrieve downloadURL: \(err)")
                                return
                            }
                        
                            print("Successfully stored image with url: \(url?.absoluteString ?? "")")
                            imageURL = url?.absoluteString ?? ""
                            
                            
                            // Update user statistics ...
                            var newBooksNum: String = ""
                            guard let uid = Auth.auth().currentUser?.uid else { return }
                            if let oldBooksNum = Int(vm.booksNum) {
                                newBooksNum = String(oldBooksNum+1)
                            }
                            else {
                                logMessage = "Error while updating books statistics"
                                showingAlert = true
                            }
                            var userData = [
                                "books_num": newBooksNum,
                            ]
                            
                            Firestore.firestore()
                                .collection("users")
                                .document(uid).updateData(userData) {
                                    err in
                                    if let err = err {
                                        print(err)
                                        logMessage = "Error while updating books statistics"
                                        showingAlert = true
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
                                        print(err)
                                        return
                                    }
                                    if !addPostNewBook(imageURL: imageURL) {
                                        logMessage = "Error while creating post"
                                        showingAlert = true
                                        return
                                    }
                                }
                            Firestore.firestore()
                                .collection("books")
                                .document(uid).setData(["exists": true]) { err in
                                    if let err = err {
                                        print(err)
                                        return
                                    }
                                    if !addPostNewBook(imageURL: imageURL) {
                                        logMessage = "Error while creating post"
                                        showingAlert = true
                                        return
                                    }
                                    logMessage = "New book has been added"
                                    showingAlert = true
                                    print("Success")
                                }
                        }
                    }
                }
                else {
                    logMessage = "Error while uploading photo"
                    showingAlert = true
                    return
                }
                    
            }
            else {
                logMessage = "Please upload cover image"
                showingAlert = true
                return
            }
        }
        else {
            showingAlert = true
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
                    print(err)
                }
            }
        return true
    }
    
    func isValidFields()->Bool {
        if !isValidField(field: author) {
            logMessage = "Please enter valid author"
            authorColor = .orange
            return false
        }
        else if !isValidField(field: title) {
            logMessage = "Please enter valid title"
            titleColor = .orange
            return false
        }
        else if !isValidGenre() {
            logMessage = "Please enter valid genres: Fantasy, Sci-fi, Mystery, Romance, Historical, Horror, Childen or Other. You can choose one."
            genreColor = .orange
            return false
        }
        else if !isValidYear(year: year) {
            logMessage = "Please enter valid year"
            yearColor = .orange
            return false
        }
        else if !isValidField(field: country) {
            logMessage = "Please enter valid country"
            countryColor = .orange
            return false
        }
        else if !isValidLanguage() {
            logMessage = "Please enter valid language: English, Italian, Chineese, French, Spanish, German, Ukranian, Russian or Other. You can choose one"
            languageColor = .orange
            return false
        }
        else if !isValidField(field: location) {
            logMessage = "Please enter valid location"
            locationColor = .orange
            return false
        }
        else if !isValidDescription() {
            logMessage = "Please enter shorter description"
            descriptionColor = .orange
            return false
        }
        else {
            return true
        }
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
    
    func isValidLanguage()->Bool {
        let languages = ["English", "Italian", "Chineese", "French", "Spanish", "German", "Ukranian", "Russian", "Other"]
        if languages.contains(language) {
            return true
        }
        else {
            return false
        }
    }
    
    func isValidGenre()->Bool {
        let genres = ["Fantasy", "Sci-fi", "Mystery", "Romance", "Historical", "Horror", "Children", "Other"]
        if genres.contains(genre) {
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
