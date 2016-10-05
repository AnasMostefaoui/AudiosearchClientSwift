//
//  Audiosearch.swift
//  AudiosearchClientSwift
//
//  Created by Anders Howerton on 1/28/16.
//  Copyright © 2016 Pop Up Archive. All rights reserved.
//

import Foundation
import Alamofire
import p2_OAuth2

public typealias ServiceResponseAny = (Any?, Error?) -> Void

open class Audiosearch {
    
    var oauth2: OAuth2ClientCredentials?
    var settings: OAuth2JSON
    
    public init (id: String, secret: String, redirect_urls:[String]) {
        self.settings = [
            "client_id": id,
            "client_secret": secret,
            "authorize_uri": "https://audiosear.ch/oauth/authorize",
            "token_uri": "https://audiosear.ch/oauth/token", // code grant only!
            "scope": "",
            "redirect_uris": redirect_urls,  // Don't forget to register this scheme. Format here should be: ["<com.your-org-name.your-org-name>://oauth/callback"]
            "keychain": false,     // if you DON'T want keychain integration
            "secret_in_body": "true" //important to have this for client credential type oauth2 -- aka entire app rather than individual user
            ] as OAuth2JSON
        
        self.oauth2 = OAuth2ClientCredentials(settings: self.settings)
        print(self.oauth2)
        
        self.oauth2!.onAuthorize = { parameters in
            print("Did authorize with parameters: \(parameters)")
            self.oauth2!.clientConfig.accessToken = parameters["access_token"] as? String
        }
        self.oauth2!.onFailure = { error in
            if nil != error {
                print("Authorization went wrong: \(error)")
            }
        }
        
        self.oauth2!.authorize()
    }
    
    open func getShowById(_ id: Int, onCompletion: @escaping ServiceResponseAny ) -> Void {
        let stringId = String(id)
        self.oauth2!.request(.get, "https://www.audiosear.ch/api/shows/\(stringId)", encoding:JSONEncoding.default)
            .responseJSON {response in
                if response.result.isSuccess {
                    if let json = response.result.value {
                        onCompletion(json, nil)
                    }
                }
                else{
                    if let error = response.result.error {
                        onCompletion(nil, error)
                    }
 
                }
            }
    }
    
    open func getShowBySearchString(_ words: String, onCompletion: @escaping ServiceResponseAny) -> Void {
        let podcastWordsEncoded = words.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    
        self.oauth2!.request(.get, "https://www.audiosear.ch/api/search/shows/\(podcastWordsEncoded!)"
            , encoding:JSONEncoding.default)
            .responseJSON {response in
                if response.result.isSuccess {
                    if let json = response.result.value {
                        onCompletion(json, nil)
                    }
                }
                else{
                    if let error = response.result.error {
                        onCompletion(nil, error)
                    }
                    
                }
        }
    }

    open func getEpisodeById(_ epId: Int, onCompletion: @escaping ServiceResponseAny) -> Void {
        let stringID = String(epId)
        
        self.oauth2!.request(.get, "https://www.audiosear.ch/api/episodes/\(stringID)", encoding:JSONEncoding.default)
            .responseJSON {response in
                if response.result.isSuccess {
                    if let json = response.result.value {
                        onCompletion(json, nil)
                    }
                }
                else{
                    if let error = response.result.error {
                        onCompletion(nil, error)
                    }
                    
                }
        }
    }
    
    open func search(_ query: String, params: Dictionary<String,String>?, type: String, onCompletion: @escaping ServiceResponseAny) -> Void  {
        var queryItems: [URLQueryItem] = []
        let query:NSString = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! as NSString
        let queryString = "https://www.audiosear.ch/api/search/\(type)/\(query)"
        var components = URLComponents(string: queryString)
        if params != nil {
            for (key, value) in params! {
                queryItems.append(URLQueryItem(name: key , value: value as String))
            }
        }
        components?.queryItems = queryItems
        let finalSearchString = components!.string!
        self.oauth2!.request(.get, finalSearchString, encoding:JSONEncoding.default)
            .responseJSON {response in
                if response.result.isSuccess {
                    if let json = response.result.value {
                        onCompletion(json, nil)
                    }
                }
                else{
                    if let error = response.result.error {
                        onCompletion(nil, error)
                    }
                    
                }
        }
    }

    open func getTrending(_ onCompletion: @escaping ServiceResponseAny) -> Void {
        self.oauth2!.request(.get, "https://www.audiosear.ch/api/trending", encoding:JSONEncoding.default)
            .responseJSON {response in
                if response.result.isSuccess {
                    if let json = response.result.value {
                        onCompletion(json, nil)
                    }
                }
                else{
                    if let error = response.result.error {
                        onCompletion(nil, error)
                    }
                    
                }
        }
    }
    
    open func getTastemakers(_ type: String, number: Int, onCompletion: @escaping ServiceResponseAny) -> Void {
        let stringNum = String(number)
        self.oauth2!.request(.get, "https://www.audiosear.ch/api/tastemakers/\(type)/\(stringNum)", encoding:JSONEncoding.default)
            .responseJSON {response in
                if response.result.isSuccess {
                    if let json = response.result.value {
                        onCompletion(json, nil)
                    }
                }
                else{
                    if let error = response.result.error {
                        onCompletion(nil, error)
                    }
                    
                }
        }
    }
    
    open func getPersonById(_ id: Int, onCompletion: @escaping ServiceResponseAny) -> Void  {
        let stringId = String(id)
        print("https://www.audiosear.ch/api/people/\(stringId)")
        self.oauth2!.request(.get, "https://www.audiosear.ch/api/people/\(stringId)", encoding:JSONEncoding.default)
            .responseJSON {response in
                if response.result.isSuccess {
                    if let json = response.result.value {
                        onCompletion(json, nil)
                    }
                }
                else{
                    if let error = response.result.error {
                        onCompletion(nil, error)
                    }
                    
                }
        }
        
    }
    
    open func getPersonByName(_ name: String, onCompletion: @escaping ServiceResponseAny) -> Void  {
        let personNameEncoded = name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        self.oauth2!.request(.get, "https://www.audiosear.ch/api/search/people/\(personNameEncoded!)"
            , encoding:JSONEncoding.default)
            .responseJSON {response in
                if response.result.isSuccess {
                    if let json = response.result.value {
                        onCompletion(json, nil)
                    }
                }
                else{
                    if let error = response.result.error {
                        onCompletion(nil, error)
                    }
                    
                }
        }
    }
    
    open func getRelated(_ type: String, id: Int, onCompletion: @escaping ServiceResponseAny) -> Void {
        let stringId = String(id)
        self.oauth2!.request(.get, "https://www.audiosear.ch/api/\(type)/\(stringId)/related", encoding:JSONEncoding.default)
            .responseJSON {response in
                if response.result.isSuccess {
                    if let json = response.result.value {
                        onCompletion(json, nil)
                    }
                }
                else{
                    if let error = response.result.error {
                        onCompletion(nil, error)
                    }
                    
                }
        }
    }
    
    open func getTastemakersBySource(_ type: String, number: Int, tasteMakerId: Int, onCompletion: @escaping ServiceResponseAny) -> Void {
        let stringTasteMakerID = String(tasteMakerId)
        let stringNum = String(number)
        
        self.oauth2!.request(.get, "https://www.audiosear.ch/api/tastemakers/\(type)/source/\(stringTasteMakerID)/\(stringNum)", encoding:JSONEncoding.default)
            .responseJSON {response in
                if response.result.isSuccess {
                    if let json = response.result.value {
                        onCompletion(json, nil)
                    }
                }
                else{
                    if let error = response.result.error {
                        onCompletion(nil, error)
                    }
                    
                }
        }
    }
    
    open func getEpisodeSnippet(_ episodeId: Int, timestampInSecs: Int, onCompletion: @escaping ServiceResponseAny) -> Void {
        let stringEpId = String(episodeId)
        let stringTimestamp = String(timestampInSecs)
        
        self.oauth2!.request(.get, "https://www.audiosear.ch/api/episodes/\(stringEpId)/snippet/\(stringTimestamp)", encoding:JSONEncoding.default)
            .responseJSON {response in
                if response.result.isSuccess {
                    if let json = response.result.value {
                        onCompletion(json, nil)
                    }
                }
                else{
                    if let error = response.result.error {
                        onCompletion(nil, error)
                    }
                    
                }
        }
    }
        
}

public extension OAuth2 {
    public func request(
        _ method: HTTPMethod,
        _ URLString: URLConvertible,
        parameters: [String: AnyObject]? = nil,
        encoding: Alamofire.ParameterEncoding =  URLEncoding.default,
        headers: [String: String]? = nil)
        -> Alamofire.DataRequest
    {
 
        var hdrs = headers ?? [:]
        if let token = accessToken {
            hdrs["Authorization"] = "Bearer \(token)"
        }

        return Alamofire.request(URLString, method: .get, parameters: parameters, encoding: JSONEncoding.default,headers:hdrs)
    }
}
