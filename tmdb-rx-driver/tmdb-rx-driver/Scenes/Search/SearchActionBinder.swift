//
//  SearchViewControllerActionBinder.swift
//  tmdb-rx-driver
//
//  Created by Dmytro Shulzhenko on 20.09.2020.
//

import Foundation

final class SearchActionBinder: ViewControllerBinder {
    unowned let viewController: SearchViewController
    private let driver: SearchDriving
    
    init(viewController: SearchViewController,
         driver: SearchDriving) {
        self.viewController = viewController
        self.driver = driver
        
        bind()
    }
    
    func dispose() { }
    
    func bindLoaded() {
        let query = viewController.searchTextField.rx.text.orEmpty
        let didSelectItem = viewController.tableView.rx.modelSelected(SearchResultItem.self)
                
        viewController.bag.insert(
            query
                .bind(onNext: driver.search),
            didSelectItem
                .bind(onNext: driver.select)
        )
    }
}
