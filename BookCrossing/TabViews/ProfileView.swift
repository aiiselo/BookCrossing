//
//  ProfileView.swift
//  BookCrossing
//
//  Created by Олеся Мартынюк on 22.05.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    @Binding var activeTab: Int
    
    @ObservedObject var vm = AppViewModel()
    @State var showingEditBookScreen = false
    @State var showingAddNewBookScreen = false
    @State var bookCollection: BookData = BookData(bookId: "", bookTitle: "", bookAuthor: "", bookYear: "", bookGenre: "", bookLanguage: "", bookCountry: "", bookCover: "", bookLocation: "", bookDescription: "", bookOwner: "")
    
    var body: some View {
        VStack {
            VStack{
                HStack(spacing: 4){
                    Text(vm.username)
                        .foregroundColor(.white)
                        .font(.custom("GillSans", size: 32))
                    Spacer(minLength: 0)
                }
                .background(Color("backgroundColor"))
                .padding(EdgeInsets(top: 28, leading: 10, bottom: 0, trailing: 10))
                .padding([.horizontal, .top])
                Divider().background(Color("inactiveTextField"))
            }
            
            ScrollView(.vertical, showsIndicators: false, content: {
                VStack(alignment: .customCenter) {
                    Divider()
                    // Image and statistics ...
                    HStack {
                        profileImage
                            .frame(width: 76, height: 76)
                            .clipShape(Circle())
                        VStack {
                            Text("Country")
                                .font(.custom("GillSans", size: 20))
                            
                            Text(vm.chatUser?.country ?? "—")
                                .font(.custom("GillSans-Light", size: 18))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            Text("Exchanges")
                                .font(.custom("GillSans", size: 20))
                            Text(vm.chatUser?.exchangesNum ?? "0")
                                .font(.custom("GillSans-Light", size: 18))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            Text("Books")
                                .font(.custom("GillSans", size: 20))
                            Text(vm.chatUser?.booksNum ?? "0")
                                .font(.custom("GillSans-Light", size: 18))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    HStack {
                        // Profile description
                        VStack(alignment: .leading, spacing: 4, content: {
                            if let fullName = vm.chatUser?.fullName {
                                if !fullName.isEmpty {
                                    Text(fullName)
                                        .font(.custom("GillSans", size: 20))
                                        .foregroundColor(.white)
                                }
                            }
                            if let bio = vm.chatUser?.bio {
                                if !bio.isEmpty {
                                    Text(bio)
                                        .font(.custom("GillSans-Light", size: 18))
                                    .foregroundColor(.white)
                                }
                            }
                            if let link = vm.chatUser?.link {
                                if !link.isEmpty {
                                    Link(destination: URL(string: link)!, label: {
                                        Text(link)
                                    }).foregroundColor(Color("buttonColor"))
                                }
                            }
                        })
                            .padding(.horizontal)
                        Spacer()
                    }
                    // Button
                    NavigationLink(destination: SettingsView()) {
                        Text("EDIT PROFILE")
                            .font(.custom("GillSans", size: 18))
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color("inactiveTextField"))
                            .cornerRadius(6)
                            .padding()
                    }
                    
                    // Books for crossing ...
                    
                    HStack(spacing: 15) {
                        Text("Books for Crossing")
                            .font(.custom("GillSans", size: 20))
                        Spacer(minLength: 0)
                        NavigationLink(destination: AddNewBookView(), isActive: $showingAddNewBookScreen) {
                            Button(action: {
                                showingAddNewBookScreen = true
                            }, label: {
                                Image(systemName: "plus")
                                    .font(.title)
                                    .foregroundColor(Color("buttonColor"))
                            })
                        }
                    }
                    .padding([.horizontal])
                    .foregroundColor(.white)
                    
                    // Scroll books ...
                    ScrollView(.horizontal, showsIndicators: false, content: {
                        HStack(spacing: 8){
                            ForEach(vm.booksCollection) { collection in
                                
                                NavigationLink(destination: EditBookView(collection: $bookCollection), isActive: $showingEditBookScreen) {
                                    Button(action: {
                                        bookCollection = collection
                                        showingEditBookScreen = true
                                    }, label: {
                                    
                                        WebImage(url: URL(string: collection.bookCover))
                                            .resizable()
                                            .frame(width: 88, height: 116)
                                            .cornerRadius(15)
                                    })
                                }
                            }
                        }
                        .padding([.horizontal])
                        })
                    
                    // Exchange History ...
                    HStack(spacing: 15) {
                        Text("Exchange History")
                            .font(.custom("GillSans", size: 20))
                        Spacer(minLength: 0)
                    }
                    .padding([.horizontal])
                    .foregroundColor(.white)
                    
                    ForEach(vm.postsHistory) { post in
                        
                        HStack {
                            Text(" ")
                            VStack(alignment: .leading) {
                                HStack(spacing: 8) {
                                    profileImage
                                        .frame(width: 44, height: 44)
                                        .clipShape(Circle())
                                    VStack(alignment: .leading) {
                                        Text(vm.username)
                                            .font(.custom("GillSans-Light", size: 18))
                                        Text(post.postTime)
                                            .font(.custom("GillSans-Light", size: 16))
                                    }
                                    .foregroundColor(.white)
                                    Spacer()
                                    Spacer()
                                }
                                Text("\(vm.username) \(post.text)")
                                    .font(.custom("GillSans-Light", size: 16))
                                    .foregroundColor(.white)
                                Spacer()
                            }.padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
                            WebImage(url: URL(string: post.postImage))
                                .resizable()
                                .frame(width: 88, height: 116)
                                .cornerRadius(15)
                            
                            
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color("elementBackgroundColor"))
                        .cornerRadius(6)
    //                    .padding()
                        .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                    }
                }
            })
            Divider().background(Color("inactiveTextField"))
        }
        .background(Color("backgroundColor"))
        .navigationBarHidden(true)
        
        
    }
    
    private var profileImage: some View {
        ZStack {
            if vm.chatUser?.profileImageURL == "" || vm.chatUser?.profileImageURL == nil{
                Image("defaultAvatar")
                    .resizable()
             } else {
                if let profileImageLink = vm.chatUser?.profileImageURL {
                    WebImage(url: URL(string: String(profileImageLink)))
                        .resizable()
                }
            }
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(activeTab: .constant(3))
    }
}

