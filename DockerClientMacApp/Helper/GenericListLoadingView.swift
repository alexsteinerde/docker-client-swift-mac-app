//
//  GenericListLoadingView.swift
//  DockerClientMacApp
//
//  Created by Alexander Steiner on 08.03.21.
//

import SwiftUI

struct GenericListLoadingView<T>: View {
    @State private var result: Result<[T], Error>? = nil
    private var loading: (@escaping(Result<[T], Error>) -> Void) -> Void
    private var content: ([T]) -> GenericTableView<T>
    
    
    init(loading: @escaping ( @escaping (Result<[T], Error>) -> Void) -> Void, content: @escaping ([T]) -> GenericTableView<T>) {
        self.loading = loading
        self.content = content
    }
    
    var body: some View {
        resultView
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            loading { completion in
                self.result = completion
            }
        }
    }
    
    @ViewBuilder var resultView: some View {
        if let result = result {
            switch result {
            case .success(let containers):
                content(containers)
            case .failure(let error):
                Text(error.localizedDescription)
            }
        } else {
            ProgressView()
        }
    }
    
}
