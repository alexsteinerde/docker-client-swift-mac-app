//
//  ImageTableView.swift
//  DockerClientMacApp
//
//  Created by Alexander Steiner on 10.03.21.
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

struct ImageTableView: GenericTableViewProtocol {
    typealias T = DockerClientSwift.Image
    
    @Binding var items: Array<T>?
    var columns: [TableColumnBuilder<T>]
    @EnvironmentObject var dockerClient: DockerClient
    var reload: () -> Void

    typealias NSViewControllerType = ImageNSTableView

    func makeNSViewController(context: Context) -> NSViewControllerType {
        let vc = ImageNSTableView(dockerClient: dockerClient, reload: reload)
        return vc
    }

    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
        nsViewController.refresh(items ?? [], columns: columns)
    }
    
    init(items: Binding<Array<T>?>, reload: @escaping () -> Void, @TableCellBuilder<T> columns: () -> [TableColumnBuilder<T>]) {
        self._items = items
        self.columns = columns()
        self.reload = reload
    }
}

class ImageNSTableView: GenericNSTableView<DockerClientSwift.Image> {
    
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
        menu.addItem(NSMenuItem(title: "Remove", action: #selector(removeImage(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Force Remove", action: #selector(removeImageForce(_:)), keyEquivalent: ""))
        tableView.menu = menu
    }
    
    @objc private func removeImage(_ sender: AnyObject) {
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
    
    @objc private func removeImageForce(_ sender: AnyObject) {
        guard tableView.clickedRow >= 0 else { return }
        let item = sizes[tableView.clickedRow]
        do {
            try item.remove(on: dockerClient, force: true).wait()
        } catch {
            let alert = NSAlert(error: error)
            alert.beginSheetModal(for: NSApplication.shared.keyWindow!, completionHandler: nil)
        }
        reload()
    }

}
