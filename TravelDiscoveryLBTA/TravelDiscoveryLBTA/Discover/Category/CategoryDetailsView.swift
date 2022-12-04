//
//  CategoryDetailsView.swift
//  TravelDiscoveryLBTA
//
//  Created by Danil Bochkarev on 24.11.2022.
//

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI
import Kingfisher

struct CategoryDetailsView: View {
    
    private let name : String
    @ObservedObject private var vm : CategoryDetailsViewModel
    
    init(name: String) {
        self.name = name
        self.vm = .init(name: name)
    }
    
    
    var body: some View {
        
        ZStack {
            if vm.isLoading {
                VStack {
                    ActivityIndicatorView()
                    Text("Loading...")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                    
                }
                .padding()
                .background(Color.black)
                .cornerRadius(8)
                
            } else {
                ZStack {
                    
                    if !vm.errorMessage.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "xmark.app.fill")
                                .font(.system(size: 64, weight: .semibold))
                                .foregroundColor(.red)
                            Text(vm.errorMessage)
                        }
                    }
                    
                    ScrollView {
                        ForEach(vm.places, id: \.self) { places in
                            VStack(alignment: .leading, spacing: 0) {
                                //KFImage(URL(string: places.thumbnail))
                                WebImage(url: URL(string: places.thumbnail))
                                    .resizable()
                                    .indicator(.activity)
                                    .transition(.fade(duration: 0.5))
                                    .scaledToFill()
                                
                                
                                
                                Text(places.name)
                                    .font(.system(size: 12, weight: .semibold))
                                    .padding()
                                    
                            }.asTile()
                            .padding()
                        }
                    }
                }
            }
        }
        .navigationBarTitle(name)
    }
}

struct CategoryDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategoryDetailsView(name: "Food")
        }
    }
}
