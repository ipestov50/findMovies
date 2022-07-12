//
//  Movie.swift
//  headwaySearchMovies
//
//  Created by Ivan Pestov on 12.07.2022.
//

import Foundation

struct MovieResponse: Decodable {
    let results: [Movie]
}


struct Movie: Decodable, Identifiable, Hashable {
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: Int
    let title: String
    let backdropPath: String?
    let posterPath: String?
    let overview: String
    let voteAverage: Double
    let voteCount: Int
    let runtime: Int?
    let releaseDate: String?
    
    
    
}

