//
//  APIRequest.swift
//  API
//
//  Created by Nudzejma Kezo on 10/1/20.
//
import Foundation

enum APIError:Error{
    case noDataAvailable
    case cannotProcessData
    case haveNoMore
}

struct APIRequest {
    var resourceString:String
    let resourceURL:URL
    let API_KEY = "2696829a81b1b5827d515ff121700838"
    init(movieName:String, page:String) {
        resourceString = "https://api.themoviedb.org/3/search/movie?api_key=\(API_KEY)&query=\(movieName)&page=\(page)"
        
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        
        self.resourceURL = resourceURL
    }
    
    func getAPI(completion: @escaping(Result<[APIObject], APIError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: resourceURL)
        { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noDataAvailable))
                return
            }
            do{
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(APIResult.self, from: jsonData)
                let details = apiResponse.results
                if !details.isEmpty{
                    completion(.success(details))
                }
                else{
                    completion(.failure(.haveNoMore))
                }
            }catch{
                completion(.failure(.cannotProcessData))
            }
        }
        dataTask.resume()
    }
}
