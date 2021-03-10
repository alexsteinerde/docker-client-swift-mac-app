//
//  ContainerTableView.swift
//  DockerClientMacApp
//
//  Created by Alexander Steiner on 09.03.21.
//

import Foundation
import AppKit
import Cocoa
import Quartz
import SwiftUI
import QuickLook
import StoreKit
import SwiftUI
import DockerClientSwift

struct ContainerTableView: GenericTableViewProtocol {
    typealias T = Container
    
    @Binding var items: Array<Container>?
    var columns: [TableColumnBuilder<Container>]
    @EnvironmentObject var dockerClient: DockerClient
    var reload: () -> Void

    typealias NSViewControllerType = ContainerNSTableView

    func makeNSViewController(context: Context) -> ContainerNSTableView {
        let vc = ContainerNSTableView(dockerClient: dockerClient, reload: reload)
        return vc
    }

    func updateNSViewController(_ nsViewController: ContainerNSTableView, context: Context) {
        nsViewController.refresh(items ?? [], columns: columns)
    }
    
    init(items: Binding<Array<Container>?>, reload: @escaping () -> Void, @TableCellBuilder<Container> columns: () -> [TableColumnBuilder<Container>]) {
        self._items = items
        self.columns = columns()
        self.reload = reload
    }
}

class ContainerNSTableView: GenericNSTableView<Container> {
    internal init(dockerClient: DockerClient, reload: @escaping () -> Void) {
        self.dockerClient = dockerClient
        self.reload = reload
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var dockerClient: DockerClient
    var reload: () -> Void
    
    override func setupTableView() {
        super.setupTableView()
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Start", action: #selector(startContainer(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Stop", action: #selector(stopContainer(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Remove", action: #selector(removeContainer(_:)), keyEquivalent: ""))
        tableView.menu = menu
    }
    
    @objc private func startContainer(_ sender: AnyObject) {
        guard tableView.clickedRow >= 0 else { return }
        let item = sizes[tableView.clickedRow]
        do {
            try item.start(on: dockerClient).wait()
        } catch {
            let alert = NSAlert(error: error)
            alert.beginSheetModal(for: NSApplication.shared.keyWindow!, completionHandler: nil)
        }
        reload()
    }
    
    @objc private func stopContainer(_ sender: AnyObject) {
        guard tableView.clickedRow >= 0 else { return }
        let item = sizes[tableView.clickedRow]
        do {
            try item.stop(on: dockerClient).wait()
        } catch {
            let alert = NSAlert(error: error)
            alert.beginSheetModal(for: NSApplication.shared.keyWindow!, completionHandler: nil)
        }
        reload()
    }
    
    @objc private func removeContainer(_ sender: AnyObject) {
        guard tableView.clickedRow >= 0 else { return }
        let item = sizes[tableView.clickedRow]
        do {
            try item.remove(on: dockerClient).wait()
        } catch {
            let alert = NSAlert(error: error)
            alert.beginSheetModal(for: NSApplication.shared.keyWindow!, completionHandler: nil)
        }
        reload()
    }
}
