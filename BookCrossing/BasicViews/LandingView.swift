//
//  LandingView.swift
//  BookCrossing
//
//  Created by Олеся Мартынюк on 20.01.2022.
//

import SwiftUI
import CoreData

import Firebase
import GoogleSignIn
import FBSDKLoginKit

struct LandingView: View {
    @EnvironmentObject var vm: AppViewModel
    var body: some View {
        NavigationView {
            if vm.signedIn {
                FeedView()
            }
            else {
                LandingViewRegistration()
            }
        }
            .navigationBarHidden(true)
            .onAppear(perform: {
                vm.signedIn = vm.isSignedIn
            })
    }
}

struct LandingViewRegistration: View {
    
    // @AppStorage("_shouldShowOnboarding") or @State
    @AppStorage("_shouldShowOnboarding") var shouldShowOnboarding: Bool = true
    
    @State private var showingFeedScreen = false
    @State private var showingPhoneScreen = false
    @AppStorage("logged") var logged = false
    @AppStorage("email") var email = ""
    @State private var manager = LoginManager()
    @EnvironmentObject var vm: AppViewModel
    var body: some View {
            VStack(alignment: .customCenter){
                Spacer()
                
                Text("BOOK CROSSING")
                    .font(.custom("Cochin-Bold", size: 36))
                    .shadow(color: .black, radius: 4, x: 2, y: 2)
                    .foregroundColor(Color.white)
                
                Text("MEET NEW BOOKS AND FRIENDS")
                    .font(.custom("GillSans-Light", size: 24))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.white)
                    .padding(.bottom, 16)
                
                NavigationLink(destination: RegistrationView()) {
                    Text("SIGN UP")
                        .font(.custom("GillSans", size: 18))
                        .foregroundColor(Color.black)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.white)
                        .cornerRadius(6)
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 4, trailing: 10))
                }
                NavigationLink(destination: LogInView()) {
                    Text("LOG IN")
                        .font(.custom("GillSans", size: 18))
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        
                        .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .strokeBorder(lineWidth: 2, antialiased: true)
                                        .foregroundColor(.white)
                                )
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 4, trailing: 10))
                }
                
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: .infinity, height: 2)
                    Text("or login with")
                        .font(.custom("GillSans", size: 18))
                        .foregroundColor(Color.white)
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: .infinity, height: 2)
                }.padding()
                
                HStack {
                    Button(
                        action: {
                            authWithGoogle()
                        },
                        label: {
                            Label("GOOGLE", image: "googleIcon")
                        }
                    ).padding()
                    
                    NavigationLink(destination: FeedView(), isActive: $showingFeedScreen) {
                    }.padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    
                    Spacer()
                    
                    Button(
                        action: {
                            authWithFacebook()
                        },
                        label: {
                            Label("FACEBOOK", image: "fbicon")
                        }
                    ).padding()

                    NavigationLink(destination: FeedView(), isActive: $showingFeedScreen) {
                    }.padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    
                }
                    .font(.custom("GillSans", size: 18))
                    .foregroundColor(Color.white)
                    .frame(width: .infinity , height: 48)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 80, trailing: 10))
            .background(ZStack {
                Image("registration")
                    .resizable()
                    .scaledToFill()
                    .clipped()
                Rectangle()
                    .foregroundColor(.clear)
                    .background(LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.90)]), startPoint: .top, endPoint: .bottom))
            })
            .edgesIgnoringSafeArea(.all)
            .fullScreenCover(isPresented: $shouldShowOnboarding, content: {
                OnboardingView(shouldShowOnboarding: $shouldShowOnboarding).frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.blue).edgesIgnoringSafeArea(.all)
            })
    }
    
    func authWithFacebook() {
        manager.logIn(permissions: ["public_profile", "email"], from: nil) {
            (result, err) in
            if err != nil {
                print(err!.localizedDescription)
                return
            }
            if !result!.isCancelled {
                logged = true
                let request = GraphRequest(graphPath: "me", parameters: ["fields": "email"])
                request.start{ (_, res, _) in
                    guard let profileData = res as? [String:Any] else {return}
                    email = profileData["email"] as! String
                    showingFeedScreen = true
                }
            }
        }
    }
    
    func authWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        var userGlobalID: String = ""
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: getRootViewController()) {
            [self] user, err in
            if let error = err {
                print(error.localizedDescription)
                return
              }

              guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
              else {
                return
              }
              let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                             accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { result, err in
                if let error = err {
                    print(error.localizedDescription)
                }
                guard let user = result?.user else {
                    return
                }
                print("ВАААУ")
                print(result!.user.uid)
                userGlobalID = result!.user.uid
                
                let docRef = Firestore.firestore().collection("users").document(userGlobalID)

                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        print("Document data: \(dataDescription)")
                    } else {
                        createDB(idUser: result!.user.uid)
                    }
                }
                
                email = user.email ?? "None"
                print(user.displayName ?? "Success")
                showingFeedScreen = true
                DispatchQueue.main.async {
                    vm.signedIn = true
                }
            }
        }
        print(userGlobalID)
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}

struct CustomCenter: AlignmentID {
  static func defaultValue(in context: ViewDimensions) -> CGFloat {
    context[HorizontalAlignment.center]
  }
}

extension HorizontalAlignment {
  static let customCenter: HorizontalAlignment = .init(CustomCenter.self)
}

extension View {
    func getRootViewController()->UIViewController{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        return root
    }
}
