//
//  ListProductView.swift
//  TutorialAsyncAwait
//
//  Created by Rafael Fernandez Alvarez on 16/9/21.
//

import SwiftUI

struct ListProductView: View {
    @ObservedObject var viewModel = ListProductViewModel()
    
    var body: some View {
        NavigationView {
            content
                .navigationBarTitle("List")
        }
        .task {
            await viewModel.loadData()
        }
    }
    
    @ViewBuilder
    var content: some View {
        switch viewModel.state {
        case .idle:
            Text("No data")
        case .loading:
            ProgressView()
        case .error(let error):
            Text("Error \(error.localizedDescription)")
        case .loaded(let items):
            List {
                ForEach(items) {
                    CellProductView(productDTO: $0)
                }
            }
        }
    }
}

struct CellProductView: View {
    var productDTO: ProductDTO
    
    var body: some View {
        HStack {
            AsyncImage(url: productDTO.imageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray
                    .opacity(0.3)
                    .overlay(ProgressView())
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(Color.black, lineWidth: 2)
            )
            
            Text("\(productDTO.title)")
                .lineLimit(2)
            Spacer()
            Text("$ \(productDTO.price, specifier: "%.2f")")
                .font(.subheadline)
        }
    }
}

struct ListProductView_Previews: PreviewProvider {
    static var previews: some View {
        ListProductView()
        CellProductView(productDTO: ProductDTO.mock).previewLayout(.sizeThatFits)
    }
}
