//
//  ChangeEmailView.swift
//  BookCrossing
//
//  Created by Олеся Мартынюк on 24.05.2022.
//

import SwiftUI
import FirebaseStorage
import FirebaseAuth
import Firebase

struct ChangeEmailView: View {
    
    @Environment(\.presentationMode) var presentation
    @State private var email = ""
    @State private var emailColor = Color("inactiveTextField")
    @State private var errorLog = ""
    @State private var showingPasswordAlert = false
    var body: some View {
        NavigationView {
            ZStack{
                Color("backgroundColor").ignoresSafeArea()
                VStack(spacing: 16) {
//                    Text("PLEASE BE SURE THAT YOU NEW EMAIL IS CORRECT AND YOU CAN VERIFY IT ON THE NEXT LOGIN. OTHERVWISE YOU MAY LOOSE YOU ACCOUNT")
//                                            .multilineTextAlignment(.center)
//                                            .font(.custom("GillSans-Light", size: 16))
//                                            .foregroundColor(Color("inactiveTextField"))
//                                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 8, trailing: 10))
                    
                    ZStack(alignment: .leading){
                        if email.isEmpty {
                            Text("New Email")
                                .foregroundColor(Color("inactiveTextField"))
                        }
                        TextField("",text: $email)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.white)
                    }
                    .padding(.all)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(lineWidth: 2, antialiased: true)
                                .foregroundColor(emailColor)
                        )
                    .padding(.leading)
                    .padding(.trailing)
                    
                    Button("CHANGE EMAIL") {
                        changeEmail()
                    }
                    .font(.custom("GillSans-Light", size: 20))
                    .foregroundColor(Color("buttonColor"))
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    
                    
                    
                    .alert(isPresented:$showingPasswordAlert) {
                        Alert(title: Text(""), message: Text(errorLog), dismissButton: .default(Text("Continue")){
                                                })
                    }
                    
                    Spacer()
                    
                }
                .navigationBarTitleDisplayMode(.inline)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 16, trailing: 10))
            }
            .accentColor(Color.black)
            .navigationBarBackButtonHidden(true)
            .toolbar(content: {
               ToolbarItem (placement: .navigation)  {
                   VStack {
                       HStack(spacing: 15) {
                           Image(systemName: "arrow.left")
                           Text("Change Email")
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
    
    func changeEmail() {
        emailColor = Color("inactiveTextField")
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser?.uid
        let userEmail = Auth.auth().currentUser?.email
        let currentUser = Auth.auth().currentUser
        if email != "" {
            if email != userEmail {
                currentUser?.updateEmail(to: email, completion: { error in
                    if let error = error {
                        errorLog = error.localizedDescription
                        emailColor = .orange
                        showingPasswordAlert = true
                    }
                    else {
                        db.collection("users").document(uid!).updateData([
                            "email": email,
                            "previous_email": userEmail
                        ])
                        errorLog = "Your email was updated"
                        showingPasswordAlert = true
                    }
                })
            }
            
        }
        else {
            errorLog = "Please fill in email"
            emailColor = .orange
            showingPasswordAlert = true
        }
    }
}

struct ChangeEmailView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeEmailView()
    }
}
