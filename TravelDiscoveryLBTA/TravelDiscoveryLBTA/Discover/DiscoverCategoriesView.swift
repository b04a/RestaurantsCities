//
//  DiscoverCategoriesView.swift
//  TravelDiscoveryLBTA
//
//  Created by Brian Voong on 10/14/20.
//

import SwiftUI
import Kingfisher
import SDWebImage
import SDWebImageSwiftUI

struct NavigationLazyView<Context: View>: View {
    
    let build: () -> Context
    
    init(_ build: @autoclosure @escaping () -> Context) {
        self.build = build
    }
    
    var body: Context {
        build()
    }
}


struct DiscoverCategoriesView: View {
    
    let categories: [Category] = [
        .init(name: "Art", imageName: "paintpalette.fill"),
        .init(name: "Sport", imageName: "sportscourt.fill"),
        .init(name: "Live Events", imageName: "music.mic"),
        .init(name: "Food", imageName: "tray.fill"),
        .init(name: "History", imageName: "books.vertical.fill")
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 14) {
                ForEach(categories, id: \.self) { category in
                    
                    NavigationLink(
                        destination: NavigationLazyView(CategoryDetailsView(name: category.name)),
                        label: {
                            VStack(spacing: 8) {
                                Image(systemName: category.imageName)
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(#colorLiteral(red: 1, green: 0.5059075952, blue: 0.2313886285, alpha: 1)))
                                    .frame(width: 64, height: 64)
                                    .background(Color.white)
                                    .cornerRadius(64)
                                Text(category.name)
                                    .font(.system( size: 12, weight: .semibold))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                            }.frame(width: 68)
                        })
                    
                }
            }.padding(.horizontal)
        }
    }
}

struct DiscoverDestination: Hashable {
    let name, imageName: String
}

class CategoryDetailsViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var places = [Place]()
    @Published var errorMessage = ""
    
    
    init(name: String) {
        
        let urlString = "https://travel.letsbuildthatapp.com/travel_discovery/category?name=\(name.lowercased())".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        guard let url = URL(string: urlString) else {
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, resp, err in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                
                if let statusCode = (resp as? HTTPURLResponse)?.statusCode, statusCode >= 400 {
                    self.isLoading = false
                    self.errorMessage = "Bad status: \(statusCode)"
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    self.places = try JSONDecoder().decode([Place].self, from: data)
                } catch {
                    print("Error filed decoder JSON: ", error)
                }
                
                self.isLoading = false
            }
        }.resume()
        
    }
}


struct DiscoverCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
//        ZStack {
//            Color.orange
//            DiscoverCategoriesView()
//        }
    }
}
