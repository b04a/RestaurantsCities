//
//  PopularDestinationsView.swift
//  TravelDiscoveryLBTA
//
//  Created by Brian Voong on 10/14/20.
//

import SwiftUI
import MapKit

struct PopularDestinationsView: View {
    
    let destinations: [Destination] = [
        .init(name: "Paris", country: "France", imageName: "eiffel_tower", latitude: 48.859565, longitude: 2.35325),
        .init(name: "Tokyo", country: "Japan", imageName: "japan", latitude: 35.67988, longitude: 139.7695),
        .init(name: "New York", country: "US", imageName: "new_york", latitude: 40.71592, longitude: -74.0055),
    ]
    
    var body: some View {
        VStack {
            HStack {
                Text("Popular destinations")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("See all")
                    .font(.system(size: 12, weight: .semibold))
            }.padding(.horizontal)
                .padding(.top)
            
            ScrollView(.horizontal) {
                HStack(spacing: 8.0) {
                    ForEach(destinations, id: \.self) { destination in
                        NavigationLink(
                            destination:
                                NavigationLazyView(PopularDestinationDetailsView(destination: destination)),
                            label: {
                                PopularDestinationTitle(destination: destination)
                                    .padding(.bottom)
                            })
                    }
                }.padding(.horizontal)
            }
        }
    }
}

struct DestinationDetails : Decodable {
    let description : String
    let photos : [String]
}

class DestinationDetailsViewModel : ObservableObject {
    @Published var isLoading = true
    @Published var destinationDetails : DestinationDetails?
    
    init(name: String) {
        
        let fixedString = "https://travel.letsbuildthatapp.com/travel_discovery/destination?name=\(name.lowercased())".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        guard let url = URL(string: fixedString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, resp, err in
            
            DispatchQueue.main.async {
                guard let data = data else { return }
                
                do {
                    self.destinationDetails = try JSONDecoder().decode(DestinationDetails.self, from: data)
                    
                } catch {
                    print("error ;(")
                }
            }
            
        }.resume()
    }
}


struct PopularDestinationDetailsView : View {
    @ObservedObject var vm : DestinationDetailsViewModel
    
    let destination : Destination
    
    @State var region : MKCoordinateRegion
    @State var isShowAttractions = false
    
    init(destination: Destination) {
        self.destination = destination
        self._region = State(initialValue: MKCoordinateRegion(center: .init(latitude: destination.latitude, longitude: destination.longitude), span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)))
        
        self.vm = .init(name: destination.name)
    }
    
    let imageUrlString = [
        "https://letsbuildthatapp-videos.s3.us-west-2.amazonaws.com/7156c3c6-945e-4284-a796-915afdc158b5",
        "https://letsbuildthatapp-videos.s3-us-west-2.amazonaws.com/b1642068-5624-41cf-83f1-3f6dff8c1702",
        "https://letsbuildthatapp-videos.s3-us-west-2.amazonaws.com/6982cc9d-3104-4a54-98d7-45ee5d117531",
        "https://letsbuildthatapp-videos.s3-us-west-2.amazonaws.com/2240d474-2237-4cd3-9919-562cd1bb439e"
    ]
    
    var body: some View {
        ScrollView {
            
            if let photos = vm.destinationDetails?.photos {
                DestinationHeaderContainer(imageUrlString: photos)
                    .frame(height: 250)
            }
            
            VStack(alignment: .leading) {
                Text(destination.name)
                    .font(.system(size: 18, weight: .bold))
                Text(destination.country)
                
                HStack {
                    ForEach(0..<5, id: \.self) { num in
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                    }
                }.padding(.top, 2)
                
                HStack {
                    Text(vm.destinationDetails?.description ?? "")
                        .padding(.top, 4)
                        .font(.system(size: 14))
                    Spacer()
                }
            }
            .padding(.horizontal)
            
            HStack {
                Text("Location")
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                
                Button {
                    isShowAttractions.toggle()
                } label: {
                    Text("\(isShowAttractions ? "Hide" : "Show") Attractions")
                        .font(.system(size: 12, weight: .semibold))
                }
                
                Toggle("", isOn: $isShowAttractions)
                    .labelsHidden()
                
                
            }.padding(.horizontal)
            
            
            Map(coordinateRegion: $region, annotationItems: isShowAttractions ? attractions : []) { attractions in
                
                MapAnnotation(coordinate: .init(latitude: attractions.latitude, longitude: attractions.longitude)) {
                    CustomMapAnnotation(attractions: attractions)
                }
            }
            .frame(height: 300)
            
        }.navigationBarTitle("Title", displayMode: .inline)
    }
    
    let attractions: [Attraction] = [
        .init(name: "Eiffel Tower", imageName: "eiffel_tower", latitude: 48.858605, longitude: 2.2946),
        .init(name: "Champs-Elysees", imageName: "new_york", latitude: 48.866867,  longitude: 2.311780),
        .init(name: "Louvre Museum", imageName: "art2", latitude: 48.860288, longitude: 2.337789)
    ]
}

struct CustomMapAnnotation: View {
    let attractions : Attraction
    
    var body: some View {
        VStack {
            Image(attractions.imageName)
                .resizable()
                .frame(width: 80, height: 60)
                .cornerRadius(4)
            Text(attractions.name)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(LinearGradient(colors: [Color.red , Color.blue], startPoint: .leading, endPoint: .trailing))
                .foregroundColor(.white)
                .border(.black)
                .cornerRadius(4)
            
            
        }.shadow(radius: 5)
    }
}

struct Attraction : Identifiable {
    var id = UUID().uuidString
    
    let name, imageName : String
    let latitude, longitude : Double
}


struct PopularDestinationTitle : View {
    let destination: Destination
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Image(destination.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 125, height: 125)
                .cornerRadius(4)
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
            
            
            Text(destination.name)
                .foregroundColor(Color(.label))
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 12)
            
            Text(destination.country)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
                .foregroundColor(.gray)
        }
        .asTile()
    }
}

struct PopularDestinationsView_Previews: PreviewProvider {
    static var previews: some View {
        
        PopularDestinationsView()
            .colorScheme(.dark)
        
        NavigationView {
            PopularDestinationDetailsView(destination: .init(name: "Paris", country: "France", imageName: "eiffel_tower", latitude: 48.859565, longitude: 2.35325))
        }
        
        DiscoverView()
        
    }
}
