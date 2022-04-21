//
//  APIManager.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/16.
//

import Foundation
import Alamofire
import RxSwift

class APIManager {

    static let shared = APIManager()

    func getAnime(page: String) -> Single<AnimeRespModel> {
        var params = [String: AnyObject]()
        params["page"] = page as AnyObject
        
        return task(apiType: .OPENAPI_GET_ANIME, params: params).flatMap { (data) -> Single<AnimeRespModel> in
            return APIManager.handleDecode(AnimeRespModel.self, from: data)
        }
    }
    
    func getManga(page: String) -> Single<MangaRespModel> {
        var params = [String: AnyObject]()
        params["page"] = page as AnyObject
        
        return task(apiType: .OPENAPI_GET_MANGA, params: params).flatMap { (data) -> Single<MangaRespModel> in
            return APIManager.handleDecode(MangaRespModel.self, from: data)
        }
    }
    
    public enum DecodeError: Error, LocalizedError {
        case dataNull
        public var errorDescription: String? {
            switch self {
            case .dataNull:
                return "Data Null"
            }
        }
    }

    private static func handleDecode<T>(_ type: T.Type, from data: Data?) -> Single<T> where T: Decodable {
        if let strongData = data {
            do {
                let toResponse = try JSONDecoder().decode(T.self ,from: strongData)
                return Single<T>.just(toResponse)
            } catch {
                return Single.error(error)
            }
        } else {
            return Single.error(DecodeError.dataNull)
        }
    }

    private func task(apiType: ApiType, params: [String: AnyObject]? = nil) -> Single<Data?> {
        return Single<Data?>.create { (singleEvent) -> Disposable in
            self.runCommand(apiType: apiType, params: params, completion: { response in
                switch response.result {
                case .success:
                    if let jsonData = response.data , let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                       print("JSONString = " + JSONString)
                    }
                    singleEvent(.success(response.data))
                case .failure(let error):
                    singleEvent(.failure(error))
                }
            })
            return Disposables.create()
        }
    }
    
    func runCommand(apiType: ApiType, params: [String: AnyObject]? = nil, completion: @escaping (DataResponse<Any>) -> Void) {
        Alamofire.request(apiType.host + apiType.path, method: apiType.method, parameters: params, encoding: apiType.encoding, headers: apiType.headers).responseJSON(completionHandler: { response in
            
            completion(response)
        })
    }
    
}

extension APIManager {
    
    enum ApiType {
        case OPENAPI_GET_ANIME
        case OPENAPI_GET_MANGA
        
        var host: String {
            switch self {
            case .OPENAPI_GET_ANIME,
                    .OPENAPI_GET_MANGA:
                return "https://api.jikan.moe"
            }
        }
        
        var path: String {
            switch self {
            case .OPENAPI_GET_ANIME:
                return "/v4/top/anime"
            case .OPENAPI_GET_MANGA:
                return "/v4/top/manga"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .OPENAPI_GET_ANIME,
                    .OPENAPI_GET_MANGA:
                return .get
            }
        }
        
        var headers: [String: String]? {
            switch self {
            case .OPENAPI_GET_ANIME,
                    .OPENAPI_GET_MANGA:
                return nil
            }
        }
        
        var encoding: ParameterEncoding {
            switch self {
            case .OPENAPI_GET_ANIME,
                    .OPENAPI_GET_MANGA:
                return URLEncoding.default
            }
        }
    }

}
