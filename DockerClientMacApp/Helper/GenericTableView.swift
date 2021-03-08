//
//  GenericTableView.swift
//  DockerClientMacApp
//
//  Created by Alexander Steiner on 04.03.21.
//

import Foundation
import AppKit
import Cocoa
import Quartz
import SwiftUI
import QuickLook
import StoreKit
import SwiftUI

struct GenericTableView<T>: NSViewControllerRepresentable {

    @Binding var items: Array<T>?
    var columns: [TableColumnBuilder<T>]

    typealias NSViewControllerType = GenericNSTableView

    func makeNSViewController(context: Context) -> GenericNSTableView<T> {
        let vc = GenericNSTableView<T>()
        return vc
    }

    func updateNSViewController(_ nsViewController: GenericNSTableView<T>, context: Context) {
        nsViewController.refresh(items ?? [], columns: columns)
    }
    init(items: Binding<Array<T>?>, @TableCellBuilder<T> columns: () -> [TableColumnBuilder<T>]) {
        self._items = items
        self.columns = columns()
    }
}

struct TableColumnBuilder<T> {
    var name: String
    var builder: (T) -> AnyView
}

@resultBuilder struct TableCellBuilder<T> {
    static func buildBlock(_ components: TableColumnBuilder<T>...) -> [TableColumnBuilder<T>] {
        return components
    }
    
    static func buildBlock(_ components: [TableColumnBuilder<T>]...) -> [TableColumnBuilder<T>] {
        return components.flatMap({$0})
    }
}


class GenericNSTableView<T>: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    func refresh(_ sizes: [T], columns: [TableColumnBuilder<T>]) {
        self.sizes = sizes
        self.columns = columns
        self.tableView.reloadData()
    }
    
    var sizes: [T] = []
    var columns: [TableColumnBuilder<T>] = []
    
    var initialized = false
    let scrollView = NSScrollView()
    let tableView = NSTableView()
    var panel: QLPreviewPanel!
    
    override func loadView() {
        self.view = NSView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayout() {
        if !initialized {
            initialized = true
            setupView()
            setupTableView()
        }
    }
    
    func setupView() {
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupTableView() {
        self.view.addSubview(scrollView)
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: self.scrollView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.scrollView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 23))
        self.view.addConstraint(NSLayoutConstraint(item: self.scrollView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.scrollView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
        tableView.frame = scrollView.bounds
        tableView.delegate = self
        tableView.dataSource = self
        scrollView.backgroundColor = NSColor.clear
        scrollView.drawsBackground = false
        tableView.columnAutoresizingStyle = .sequentialColumnAutoresizingStyle
        tableView.backgroundColor = NSColor.clear
        tableView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        tableView.allowsEmptySelection = true
        
        for column in columns {
            let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "col_\(column.name)"))
            col.title = column.name
            tableView.addTableColumn(col)
        }
        
        scrollView.documentView = tableView
        scrollView.hasHorizontalScroller = false
        scrollView.hasVerticalScroller = true
    }
    func numberOfRows(in tableView: NSTableView) -> Int {
        return sizes.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let size = sizes[row]
        
        guard let column = columns.first(where: { "col_\($0.name)" == tableColumn?.identifier.rawValue }) else { return nil }
        
        let view = column.builder(size).frame(maxWidth: .infinity, alignment: .leading)
        let hostingView = NSHostingView(rootView: view)
        return hostingView
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = NSTableRowView()
        rowView.isEmphasized = false
        return rowView
    }
}
