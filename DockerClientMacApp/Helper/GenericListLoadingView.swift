//
//  GenericListLoadingView.swift
//  DockerClientMacApp
//
//  Created by Alexander Steiner on 08.03.21.
//

import SwiftUI
import Combine

struct GenericListLoadingView<T, U: GenericTableViewProtocol>: View {
    @State var result: Result<[T], Error>? = nil
    var loading: (@escaping(Result<[T], Error>) -> Void) -> Void
    var changeSubject: PassthroughSubject<Void, Never>?
    var content: ([T]) -> U
    
    @State var bag = Set<AnyCancellable>()
    
    var body: some View {
        resultView
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            loading { completion in
                self.result = completion
            }
            changeSubject?
                .sink(receiveValue: { _ in
                loading { completion in
                    self.result = completion
                }
                })
            .store(in: &bag)
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
