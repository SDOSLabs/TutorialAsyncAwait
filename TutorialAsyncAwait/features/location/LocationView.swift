//
//  LocationView.swift
//  LocationView
//
//  Created by Rafael Fernandez Alvarez on 21/9/21.
//

import SwiftUI
import MapKit

struct LocationView: View {
    @ObservedObject var viewModel = LocationViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if let userPoint = viewModel.userPoint {
                    Map(coordinateRegion: $viewModel.coordinateRegion, annotationItems: [userPoint], annotationContent: { item in
                        MapMarker(coordinate: item.coordinate, tint: Color.red)
                    })
                } else {
                    Map(coordinateRegion: $viewModel.coordinateRegion)
                }
            }
            .navigationBarTitle("Map")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.handleLocation()
                    } label: {
                        Image(systemName: (viewModel.isLocationMonitoring) ? "location.fill" : "location")
                    }

                }
            }
        }
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView()
    }
}
