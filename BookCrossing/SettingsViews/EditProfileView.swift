//
//  EditProfileView.swift
//  BookCrossing
//
//  Created by Олеся Мартынюк on 23.05.2022.
//

import SwiftUI
import FirebaseStorage
import FirebaseAuth
import Firebase

import SDWebImageSwiftUI


//var vm = MainMessagesViewModel()

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentation
    
    @ObservedObject var vm = AppViewModel()
    
    @State private var connectFacebook = false
    @State var v: String = "VALUE"
    @State var shouldShowImagePicker = false
    @State var image: UIImage?
    @State var imageProfileURL: String?
    @State var isPhotoChanged = false
    
    @State private var usernameColor = Color(.white)
    @State private var linkColor = Color(.white)
    @State private var bioColor = Color(.white)
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
                                .frame(width: 152, height: 152)
                                .cornerRadius(76)
                        }
                        else {
                            if let profileImageLink = vm.profileImageURL {
                                WebImage(url: URL(string: String(profileImageLink)))
                                    .resizable()
                                    .frame(width: 152, height: 152)
                                    .clipShape(Circle())
                            } else {
                            Image(profileImage())
                                .resizable()
                                .frame(width: 152, height: 152)
                                .clipShape(Circle())
                            }
                        }
                    }
                    
                    
                        
                    Button(action: {changeProfilePhoto()}, label: {
                        Text("Change profile photo")
                            .font(.custom("GillSans-Light", size: 20))
                            .foregroundColor(Color("buttonColor"))
                    })
                    Form {
                        Section(header: Text("Personal information").font(.custom("GillSans-Light", size: 16))) {
                            TextField("", text: $vm.username)
                                .placeholder(when: vm.username.isEmpty) {
                                    Text("Username").foregroundColor(Color("inactiveTextField"))
                                }
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .foregroundColor(usernameColor)
                            TextField("", text: $vm.fullName)
                                .placeholder(when: vm.fullName.isEmpty) {
                                    Text("Full Name").foregroundColor(Color("inactiveTextField"))
                                }
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            TextField("", text: $vm.country)
                                .placeholder(when: vm.country.isEmpty) {
                                    Text("Country").foregroundColor(Color("inactiveTextField"))
                                }
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }.listRowBackground(Color("elementBackgroundColor"))
                            .font(.custom("GillSans-Light", size: 20))
                        Section(header: Text("Additional information").font(.custom("GillSans-Light", size: 16))) {
                            TextField("", text: $vm.link)
                                .placeholder(when: vm.link.isEmpty) {
                                    Text("Website").foregroundColor(Color("inactiveTextField"))
                                }
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .foregroundColor(linkColor)
                            TextEditor(text: $vm.bio)
                                .placeholder(when: vm.bio.isEmpty) {
                                    Text("Bio").foregroundColor(Color("inactiveTextField"))
                                }
                                .foregroundColor(bioColor)
                                .autocapitalization(.none)
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
                           Text("Edit Profile")
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
    
    func profileImage() -> String {
        return "thirdOnboardingImage"
    }
    
    
    func saveChanges() {
        var imageURL: String = ""
        var isValidImage = false
        if isPhotoChanged {
            if let image = self.image {
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let ref = Storage.storage().reference(withPath: "userAvatar/\(uid)")
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
                        isValidImage = isValidImageURL(url: imageURL)
                        var userData = [
                            "profileImageURL": imageURL
                        ]
                        Firestore.firestore()
                            .collection("users")
                            .document(uid).updateData(userData) {
                                err in
                                if let err = err {
                                    print(err)
                                    return
                                }
                                logMessage = "Profile photo is updated"
                            }
                        
                    }
                }
            }
        }
        
        if isValidFields(link: vm.link) {
            
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            var userData = [
                "full_name": vm.fullName,
                "bio": vm.bio,
                "username": vm.username,
                "link": vm.link,
                "country": vm.country,
                
            ]
            if vm.country.isEmpty{
                userData["country"] = "—"
            } else {
                userData["country"] = vm.country
            }
            
            Firestore.firestore()
                .collection("users")
                .document(uid).updateData(userData) {
                    err in
                    if let err = err {
                        print(err)
                        return
                        logMessage = "Unknown error. Please try again"
                    }
                    logMessage = "Your changes has been saved"
                }
        }
        else {
            logMessage = "Please fill in valid values"
        }
        
        showingAlert = true
    }
    
    func isValidFields(link: String)->Bool {
        let res1 = isValidBio()
        let res2 = isValidUsername()
        if res1 && res2 {
            return true
        }
        else {
            return false
        }
    }
    
    func isValidBio() -> Bool {
        if vm.bio.count <= 280 {
            bioColor = .white
            return true
        }
        else {
            bioColor = .orange
            return false
        }
    }
    
    func isValidUsername() -> Bool {
        for chr in vm.username {
              if (!(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") ) {
                  usernameColor = .orange
                  return false
              }
           }
        if vm.username == "" {
            usernameColor = .orange
            return false
        }
        usernameColor = .white
        return true
    }
    
    func isValidURL (urlString: String?) -> Bool {
        if urlString!.isValidURL && urlString!.contains("https://"){
            linkColor = .white
            return true
        }
        else {
            linkColor = .orange
            return false
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
    
    func changeProfilePhoto() {
        shouldShowImagePicker.toggle()
        isPhotoChanged  = true
    }
    
    
    
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}


extension String {
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
        
    }
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}


struct ImagePicker: UIViewControllerRepresentable {

    @Binding var image: UIImage?

    private let controller = UIImagePickerController()

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            parent.image = info[.originalImage] as? UIImage
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }

    }

    func makeUIViewController(context: Context) -> some UIViewController {
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }

}


