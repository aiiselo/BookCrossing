//
//  SettingsView.swift
//  BookCrossing
//
//  Created by Олеся Мартынюк on 23.05.2022.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentation
    
    @State private var showingLogOutAlert = false
    @State private var showingLandingScreen = false
    @State private var errorLog = ""
    @State private var uid = Auth.auth().currentUser?.uid
    @AppStorage("logged") var logged = true
    @EnvironmentObject var vm: AppViewModel
    
    var body: some View {
        NavigationView {
            ZStack{
                Color("backgroundColor").ignoresSafeArea()
                VStack(spacing: 16) {
                    VStack() {
                        HStack(spacing: 15) {
                            Image("peopleIcon")
                                .font(.title)
                            Text("Account")
                                .font(.custom("GillSans", size: 20))
                            Spacer(minLength: 0)
                        }
                        .padding([.horizontal])
                        .foregroundColor(.white)
                        
                        Divider().background(Color("inactiveTextField"))
                    }
                    
                    NavigationLink(destination: EditProfileView()) {
                        HStack(spacing: 15) {
                            Text("Edit profile")
                                .font(.custom("GillSans-Light", size: 20))
                            Spacer(minLength: 0)
                            Button(action: {}, label: {
                                Image("arrowRightIcon")
                                    .foregroundColor(Color("buttonColor"))
                            })
                        }
                        .padding([.horizontal])
                        .foregroundColor(.white)
                    }
                    
                    NavigationLink(destination: ChangeEmailView()) {
                        HStack(spacing: 15) {
                            Text("Change email")
                                .font(.custom("GillSans-Light", size: 20))
                            Spacer(minLength: 0)
                            Button(action: {}, label: {
                                Image("arrowRightIcon")
                                    .foregroundColor(Color("buttonColor"))
                            })
                        }
                        .padding([.horizontal])
                        .foregroundColor(.white)
                    }
                    
                    NavigationLink(destination: ChangePasswordView()) {
                        HStack(spacing: 15) {
                            Text("Change password")
                                .font(.custom("GillSans-Light", size: 20))
                            Spacer(minLength: 0)
                            Button(action: {}, label: {
                                Image("arrowRightIcon")
                                    .foregroundColor(Color("buttonColor"))
                            })
                        }
                        .padding([.horizontal])
                        .foregroundColor(.white)
                    }
                    
                    HStack{
                        Text("My uid:")
                            .font(.custom("GillSans-Light", size: 18))
                            .foregroundColor(Color("inactiveTextField"))
                        Text(uid!)
                            .font(.custom("GillSans-Light", size: 18))
                            .foregroundColor(Color("inactiveTextField"))
                        Spacer()
                    }.padding([.horizontal])
                    
                    
                    Spacer()
                    
                    Button(action: {userSignOut()}, label: {
                        Text("LOG OUT")
                            .font(.custom("GillSans-Light", size: 20))
                            .foregroundColor(Color("buttonColor"))
                    }).alert(isPresented: $showingLogOutAlert) {
                        Alert(title: Text(""), message: Text(errorLog), dismissButton: .default(Text("Try again")){
                                                })
                    }
                    NavigationLink(destination: LandingView(), isActive: $showingLandingScreen) {
                    }.padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    
                }
                .navigationBarTitleDisplayMode(.inline)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 8, trailing: 10))
                
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(content: {
               ToolbarItem (placement: .navigation)  {
                   VStack {
                       HStack(spacing: 15) {
                           Image(systemName: "arrow.left")
                           Text("Settings")
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
    
    func userSignOut() {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            errorLog = "Error signing out: \(signOutError)"
            showingLogOutAlert = true
        }
        DispatchQueue.main.async {
            vm.signedIn = false
        }
        logged = false
        showingLandingScreen = true
      
    }
}



struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
