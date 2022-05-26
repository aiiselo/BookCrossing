//
//  Onboarding.swift
//  BookCrossing
//
//  Created by Олеся Мартынюк on 20.01.2022.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    @Binding var shouldShowOnboarding: Bool
    var body: some View {
        TabView {
            PageView(
                subtitle: "MEET NEW BOOKS AND FRIENDS",
                quote: "IF YOU LOVE YOUR BOOKS, LET THEM GO \n - THE NEW YORK TIMES",
                showDismissButton: false,
                image: "firstOnboardingImage",
                opacity: 0.80,
                isSkipShown: true,
                shouldShowOnboarding: $shouldShowOnboarding
            )
            PageView(
                subtitle: "EXCHANGE OPINIONS",
                quote: "AN UNLIKELY GLOBAL SOCIOLOGY EXPERIMENT \n - BOOK MAGAZINE",
                showDismissButton: false,
                image: "secondOnboardingImage",
                opacity: 0.90,
                isSkipShown: true,
                shouldShowOnboarding: $shouldShowOnboarding
            )
            PageView(
                subtitle: "PRESERVE THE ENVIRONMENT",
                quote: "A MODERN-DAY MESSAGE IN A BOTTLE \n - SAN FRANCISCO CHRONICLE",
                showDismissButton: true,
                image: "thirdOnboardingImage",
                opacity: 0.90,
                isSkipShown: false,
                shouldShowOnboarding: $shouldShowOnboarding
            )
        }.tabViewStyle(PageTabViewStyle())
    }
}

struct PageView : View {
    let title: String = "BOOK CROSSING"
    let subtitle: String
    let quote: String
    let showDismissButton: Bool
    let image: String
    let opacity: Double
    let isSkipShown: Bool
    @Binding var shouldShowOnboarding: Bool
    var body: some View {
        VStack {
            if isSkipShown {
                HStack {
                    Text(" ")
                    Spacer()
                    Button(action: {
                        shouldShowOnboarding.toggle()
                    }, label: {
                        Text("SKIP")
                            .bold()
                            .foregroundColor(Color.white)
                    })
                }.padding(EdgeInsets(top: 50, leading: 10, bottom: 0, trailing: 10))
            }
            
            Spacer()
            
            VStack{
                Text(title)
                    .font(.custom("Cochin", size: 36)) // Cochin Baskerville-Bold
                Text(subtitle)
                    .font(.custom("GillSans-Light", size: 24)).padding(.bottom, 16)
                Text(quote)
                    .font(.custom("GillSans", size: 16)).padding(.bottom, 16)
                    
                if showDismissButton {
                    Button(action: {
                        shouldShowOnboarding.toggle()
                    }, label: {
                        Text("JOIN")
                            .font(.custom("GillSans", size: 18))
                            .foregroundColor(Color.black)
                            .frame(width: 240, height: 50)
                            .background(Color.white)
                            .cornerRadius(6)
                    })
                }
            }
            .multilineTextAlignment(.center)
            .foregroundColor(Color.white)
            .shadow(color: .black, radius: 1, x: 1, y: 1)
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 100, trailing: 10))
        }
        .background(ZStack {
            Image(image)
                .resizable()
                .scaledToFill()
                .clipped()
            Rectangle()
                .foregroundColor(.clear)
                .background(LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(opacity)]), startPoint: .center, endPoint: .bottom))
        })
        .edgesIgnoringSafeArea(.all)
    }
}

