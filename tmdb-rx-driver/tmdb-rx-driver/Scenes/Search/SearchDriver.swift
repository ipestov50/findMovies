//
//  SearchViewModel.swift
//  tmdb-mvvm-pure
//
//  Created by krawiecp-home on 29/01/2019.
//  Copyright © 2019 tailec. All rights reserved.
//

import RxSwift
import RxCocoa
import RxSwiftExt

protocol SearchDriving {
    var isSwitchHidden: Driver<Bool> { get }
    var isLoading: Driver<Bool> { get }
    var results: Driver<[SearchResultItem]> { get }
    var didSelect: Driver<SearchResultItem> { get }
    
    func search(_ query: String)
    func select(_ model: SearchResultItem)
}

final class SearchDriver: SearchDriving {
    private let activityIndicator = ActivityIndicator()
    
    private let isSwitchHiddenRelay = BehaviorRelay<Bool?>(value: nil)
    private let resultsRelay = BehaviorRelay<[SearchResultItem]?>(value: nil)
    private let didSelectRelay = BehaviorRelay<SearchResultItem?>(value: nil)
    
    private var searchBag = DisposeBag()

    private let api: TMDBApiProvider
    
    var isSwitchHidden: Driver<Bool> { isSwitchHiddenRelay.unwrap().asDriver() }
    var isLoading: Driver<Bool> { activityIndicator.asDriver() }
    var results: Driver<[SearchResultItem]> { resultsRelay.unwrap().asDriver() }
    var didSelect: Driver<SearchResultItem> { didSelectRelay.unwrap().asDriver() }
    
    init(api: TMDBApiProvider) {
        self.api = api
    }
    
    func search(_ query: String) {
        searchBag = DisposeBag()
        let searchQuery = query.replacingOccurrences(of: " ", with: "+")
        let isValid = searchQuery.count >= 3
        
        isSwitchHiddenRelay.accept(isValid)
        
        guard isValid else {
            resultsRelay.accept([])
            return
        }

        let searchResult: Observable<[SearchResultItem]> = Observable.combineLatest(
            api.searchMovies(forQuery: searchQuery)
                .map({ $0 ?? [] })
                .mapMany(SearchResultItem.init),
            api.searchPeople(forQuery: searchQuery)
                .map({ $0 ?? [] })
                .mapMany(SearchResultItem.init)
        )
        .map { $0.0 + $0.1 }
        
        
        
        searchResult
            .trackActivity(activityIndicator)
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(onNext: resultsRelay.accept)
            .disposed(by: searchBag)
    }
    
    func select(_ model: SearchResultItem) {
        didSelectRelay.accept(model)
    }
}

extension SearchDriver: StaticFactory {
    enum Factory {
        static var `default`: SearchDriving {
            SearchDriver(api: TMDBApi.Factory.default)
        }
    }
}
