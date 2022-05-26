//
//  ChangePasswordView.swift
//  BookCrossing
//
//  Created by Олеся Мартынюк on 23.05.2022.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct ChangePasswordView: View {
    
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
                    
                    Text("Enter your registration email. We will send you link for password reset")
                        .multilineTextAlignment(.leading)
                        .font(.custom("GillSans-Light", size: 18))
                        .foregroundColor(Color("inactiveTextField"))
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 8, trailing: 10))
                    
                    ZStack(alignment: .leading){
                        if email.isEmpty {
                            Text("Email")
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
                    
                    
                    Button("CHANGE PASSWORD") {
                        resetPassword()
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
                           Text("Change Password")
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
    
    func resetPassword() {
        emailColor = Color("inactiveTextField")
        Auth.auth().sendPasswordReset(withEmail: email) {  (error) in
            if email == "" {
                errorLog = "Please fill in email"
                emailColor = .orange
                showingPasswordAlert = true
            } else if let error = error {
                errorLog = "Please enter valid email"
                showingPasswordAlert = true
            } else {
                errorLog = "Reset link was sent to your email"
                showingPasswordAlert = true
            }
        }
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
    }
}
