//
//  SidebarView.swift
//  DockerClientMacApp
//
//  Created by Alexander Steiner on 03.03.21.
//

import SwiftUI

struct SidebarView: View {
    @State private var isCotnainersActive = true
    
    var body: some View {
        List {
            Section {
                NavigationLink(destination: ContainersListView(), isActive: $isCotnainersActive) {
                    Text("Containers")
                }
                
                NavigationLink(
                    destination: ImagesListView(),
                    label: {
                        Text("Images")
                    })
            }
        }
        .listStyle(SidebarListStyle())
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}
