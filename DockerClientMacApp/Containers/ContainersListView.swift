//
//  ContainersListView.swift
//  DockerClientMacApp
//
//  Created by Alexander Steiner on 03.03.21.
//

import SwiftUI
import DockerClientSwift
import NIO
import Combine

struct ContainersListView: View {
    @EnvironmentObject var dockerClient: DockerClient
    private let changeSubject = PassthroughSubject<Void, Never>()
    
    var body: some View {
        GenericListLoadingView(loading: { completion in
            try! dockerClient.containers.list(all: true)
                .whenComplete({ result in
                    completion(result)
                })
        }, changeSubject: changeSubject, content: tableView(containers: ))
        .navigationTitle("Containers")
    }

    func tableView(containers: [Container]) -> ContainerTableView {
        ContainerTableView(items: .constant(containers), reload: {
            changeSubject.send()
        }) {
            TableColumnBuilder(name: "", builder: { (container: Container) in
                AnyView(
                    Group {
                        switch container.state {
                        case "running":
                            Circle()
                                .fill(Color.green)
                        case "exited":
                            Circle()
                                .fill(Color.red)
                        case "created":
                            Circle()
                                .fill(Color.yellow)
                        default:
                            Circle()
                                .fill(Color.gray)
                        }
                    }
                    .help(container.state)
                    .frame(width: 16, height: 16)
                )
            })
            TableColumnBuilder<Container>(name: "Id", builder: { AnyView(Text($0.id.value.prefix(12))) })
            TableColumnBuilder<Container>(name: "Image Digest", builder: { AnyView(Text($0.image.id.value)) })
            TableColumnBuilder<Container>(name: "Image Name", builder: { AnyView(Text($0.image.repositoryTags.first?.repository ?? "")) })
            TableColumnBuilder<Container>(name: "Image Tag", builder: { AnyView(Text($0.image.repositoryTags.first?.tag ?? "")) })
            TableColumnBuilder<Container>(name: "Command", builder: { AnyView(Text($0.command)) })
            TableColumnBuilder<Container>(name: "Names", builder: { AnyView(Text($0.names.joined(separator: ", "))) })
            TableColumnBuilder<Container>(name: "Created At", builder: { AnyView(Text($0.createdAt, style: .relative)) })
        }
    }
}

struct ContainersListView_Previews: PreviewProvider {
    static var previews: some View {
        ContainersListView()
    }
}
