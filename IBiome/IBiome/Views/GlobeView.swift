import SwiftUI
import MapKit

struct GlobeView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
    )
    
    @State private var mapStyle: MKMapConfiguration = {
        let config = MKStandardMapConfiguration()
        config.pointOfInterestFilter = .excludingAll
        config.showsTraffic = false
        return config
    }()
    
    var body: some View {
        Map(coordinateRegion: $region, 
            interactionModes: .all,
            showsUserLocation: true,
            userTrackingMode: nil,
            annotationItems: [],
            annotationContent: { _ in },
            mapStyle: mapStyle)
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            withAnimation {
                                mapStyle = MKStandardMapConfiguration()
                            }
                        }) {
                            Image(systemName: "map")
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            withAnimation {
                                let config = MKImageryMapConfiguration()
                                config.pointOfInterestFilter = .excludingAll
                                mapStyle = config
                            }
                        }) {
                            Image(systemName: "globe")
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                }
            )
    }
}
