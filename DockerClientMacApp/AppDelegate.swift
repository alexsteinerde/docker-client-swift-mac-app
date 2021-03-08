//
//  AppDelegate.swift
//  DockerClientMacApp
//
//  Created by Alexander Steiner on 02.03.21.
//

import Cocoa
import SwiftUI
import DockerClientSwift
import Logging

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    
    let dockerClient = DockerClient()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()
            .environmentObject(dockerClient)

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.title = "Docker Client"
        window.makeKeyAndOrderFront(nil)
        
        
        LoggingSystem.bootstrap(StreamLogHandler.standardOutput(label:))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

extension DockerClient: ObservableObject {}

