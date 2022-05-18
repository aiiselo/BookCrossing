//
//  RegistrationView.swift
//  BookCrossing
//
//  Created by Олеся Мартынюк on 05.05.2022.
//

import SwiftUI
import Firebase
import FirebaseAuth


struct LogInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var wrongEmail = 0
    @State private var emailColor = Color("inactiveTextField")
    @State private var wrongPassword = 0
    @State private var passwordColor = Color("inactiveTextField")
    @State private var showingLoginScreen = false
    
    @Environment(\.presentationMode) var presentation
    
    
    var body: some View {
        NavigationView {
            ZStack{
                Color("backgroundColor").ignoresSafeArea()
                VStack {
                    Text("BOOK CROSSING")
                        .font(.custom("Cochin-Bold", size: 36))
                        .shadow(color: .black, radius: 4, x: 2, y: 2)
                        .foregroundColor(Color.white)
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
        
                    ZStack(alignment: .leading){
                        if password.isEmpty {
                            Text("Password")
                                .foregroundColor(Color("inactiveTextField"))
                        }
                        SecureField("",text: $password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.white)
                    }
                    .padding(.all)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(lineWidth: 2, antialiased: true)
                                .foregroundColor(passwordColor)
                        )
                    .padding(.leading)
                    .padding(.trailing)
                    
                    Button("LOG IN") {
                        authUser(email: email, password: password)
                    }
                    .font(.custom("GillSans", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.all)
                    .background(Color("buttonColor"))
                    .cornerRadius(6)
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))

                    NavigationLink(destination: Text("You are logged in @\(email)"), isActive: $showingLoginScreen) {
                        EmptyView()
                    }
                    
                }
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 80, trailing: 10))
            }
            .accentColor(Color.black)
            .navigationBarBackButtonHidden(true)
            .toolbar(content: {
               ToolbarItem (placement: .navigation)  {
                  Image(systemName: "arrow.left")
                  .foregroundColor(.white)
                  .onTapGesture {
                      // code to dismiss the view
                      self.presentation.wrappedValue.dismiss()
                  }
               }
            })
        }.navigationBarHidden(true)
    }
    
    func authUser(email: String, password: String) {
        let result = checkValidFields(email: email, password: password)
        if result != nil {
            passwordColor = Color(.orange)
            wrongPassword = 2
            emailColor = Color(.orange)
            wrongEmail = 2
        }
        else {
            Auth.auth().signIn(withEmail: email, password: password) {
            (result, error) in
                if error != nil {
//                    self.errorLabel.alpha = 1
//                    self.errorLabel.numberOfLines = 0
//                    self.errorLabel.textColor = .red
//                    self.errorLabel.lineBreakMode = .byWordWrapping
//                    self.errorLabel.text = error?.localizedDescription
//                    self.errorLabel.sizeToFit()
                }
                else {
                    showingLoginScreen = true
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let secondVC = storyboard.instantiateViewController(identifier: "MainPageViewController") as! MainPageViewController
//                    self.view.window?.rootViewController = secondVC
                }
            }
        }
    }
    
    func checkValidFields(email: String, password: String) -> String? {
            if email == "" ||
                password == "" {
                return "Please, fill in all the fields"
            }
            return nil
        }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
