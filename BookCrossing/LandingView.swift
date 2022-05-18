//
//  LandingView.swift
//  BookCrossing
//
//  Created by Олеся Мартынюк on 20.01.2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    // AppStorage("_shouldShowOnboarding") or State
    @AppStorage("_shouldShowOnboarding") var shouldShowOnboarding: Bool = true
    @State private var showingLoginScreen = false
    @State private var showingRegistrationScreen = false
    var body: some View {
        NavigationView {
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
                
                NavigationLink(destination: RegistrationView(), isActive: $showingRegistrationScreen) {
                    Text("SIGN UP")
                        .font(.custom("GillSans", size: 18))
                        .foregroundColor(Color.black)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.white)
                        .cornerRadius(6)
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 4, trailing: 10))
                }
                NavigationLink(destination: LogInView(), isActive: $showingLoginScreen) {
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
                            print("Edit button was tapped")
                        },
                        label: {
                            Label("GOOGLE", image: "googleIcon")
                        }
                    ).padding()
                    Spacer()
                    Button(
                        action: {
                            print("Edit button was tapped")
                        },
                        label: {
                            Label("VKONTAKTE", image: "vkicon")
                        }
                    ).padding()
                        
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
    }.navigationBarHidden(true)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
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
