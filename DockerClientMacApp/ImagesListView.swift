//
//  ImagesListView.swift
//  DockerClientMacApp
//
//  Created by Alexander Steiner on 03.03.21.
//

import SwiftUI
import DockerClientSwift

struct ImagesListView: View {
    @EnvironmentObject var dockerClient: DockerClient
    
    var body: some View {
        
        GenericListLoadingView(loading: { completion in
            try! dockerClient.images.list(all: true)
                .whenComplete({ result in
                    completion(result)
                })
        }, content: { images in
            GenericTableView<DockerClientSwift.Image>(items: .constant(images)) {
                TableColumnBuilder<DockerClientSwift.Image>(name: "ID") { AnyView(Text($0.id.value)) }
                TableColumnBuilder<DockerClientSwift.Image>(name: "Name") { AnyView(Text($0.repositoryTags.first?.repository ?? "")) }
                TableColumnBuilder<DockerClientSwift.Image>(name: "Tag") { AnyView(Text($0.repositoryTags.first?.tag ?? "")) }
                TableColumnBuilder<DockerClientSwift.Image>(name: "Created At") { AnyView(Text($0.createdAt ?? Date(), style: .relative)) }
            }
        })
        .navigationTitle("Images")
    }
}

struct ImagesListView_Previews: PreviewProvider {
    static var previews: some View {
        ImagesListView()
    }
}
