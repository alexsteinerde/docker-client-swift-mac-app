//
//  ContentView.swift
//  DockerClientMacApp
//
//  Created by Alexander Steiner on 02.03.21.
//

import SwiftUI
import DockerClientSwift
import NIO

struct ContentView: View {
    var body: some View {
        NavigationView {
            SidebarView()
            ContainersListView()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
