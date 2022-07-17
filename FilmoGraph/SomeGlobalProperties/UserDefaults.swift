//
//  UserDefaults.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 14/07/2022.
//
//
//import Foundation
//
//final class SaveEverythingOnFirstLaunch {
//    
//    static func loadViewModel(completion: @escaping (MainTableViewModelProtocol?) -> Void) {
//        
//        let viewModel = MainTableViewModel()
//        
//        if !UserDefaults.standard.bool(forKey: "First Launch") {
//            StartFetch.shared.fetchGameListForMainView { result in
//                
//                let encoder = JSONEncoder()
//                do {
//                    
//                    viewModel.games.value = (result?.games.value ?? []) as! [Game]
//                    viewModel.prevPage = result?.nextPage
//                    viewModel.nextPage = result?.prevPage
//                    
//                    let gamesData = try encoder.encode(result?.games.value)
//                    let nextPageData = try encoder.encode(result?.nextPage)
//                    let prevPageData = try encoder.encode(result?.prevPage)
//                    
//                    UserDefaults.standard.set(gamesData, forKey: "Games")
//                    UserDefaults.standard.set(nextPageData, forKey: "Next")
//                    UserDefaults.standard.set(prevPageData, forKey: "Prev")
//                    
//                    UserDefaults.standard.set(true, forKey: "First Launch")
//                    completion(viewModel)
//                    
//                } catch let error {
//                    print(error)
//                }
//            }
//        } else {
//            let decoder = JSONDecoder()
//            
//            do {
//                
//                let games = try decoder.decode([Game].self, from: UserDefaults.standard.data(forKey: "Games") ?? Data())
//                let next = try decoder.decode(String?.self, from: UserDefaults.standard.data(forKey: "Next") ?? Data())
//                let prev = try decoder.decode(String?.self, from: UserDefaults.standard.data(forKey: "Prev") ?? Data())
//                
//                viewModel.games.value = games
//                viewModel.prevPage = prev
//                viewModel.nextPage = next
//                
//                completion(viewModel)
//                
//            } catch let error {
//                print(error)
//            }
//            
//        }
//    }
//    
//    static func loadGenresAndSave(completion: @escaping (Genres?) -> Void) {
//        
//        var genres: Genres?
//        
//        if !UserDefaults.standard.bool(forKey: "First Launch Genres") {
//            
//            let encoder = JSONEncoder()
//            
//            FetchSomeFilm.shared.fetchGenres { genreses in
//                do {
//                    genres = genreses
//                    let genresData = try encoder.encode(genreses)
//                    
//                    UserDefaults.standard.set(genresData, forKey: "Genres")
//                    UserDefaults.standard.set(true, forKey: "First Launch Genres")
//                    
//                    completion(genres)
//                    
//                } catch let error {
//                    print(error)
//                }
//            }
//        } else {
//            let decoder = JSONDecoder()
//            
//            do {
//                let genreses = try decoder.decode(Genres?.self, from: UserDefaults.standard.data(forKey: "Genres") ?? Data())
//                
//                genres = genreses
//                
//                completion(genres)
//                
//            } catch let error {
//                print(error)
//            }
//        }
//    }
//}
