//
//  APIManager.swift
//  Complete Data and API
//
//  Created by Pedja Jevtic on 11/22/17.
//  Copyright © 2017 Pedja Jevtic. All rights reserved.
//

import Foundation

class APIManager {
    
    // Declare class instance property
    static let sharedInstance = APIManager()
    
    // MARK: - Configuration
    
    func baseURL(path: API_Paths)->String{
        if let apiURL = Bundle.main.object(forInfoDictionaryKey: "Base API URL") as? String{
            
            return apiURL+path.rawValue
        }
        
        return ""
    }
    
    // MARK: - Communication with API
    func get(path: API_Paths){
        
        if(1 > self.baseURL(path: path).count){
            return;
        }
        
        guard let usableURL =  URL(string: self.baseURL(path: path)) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: usableURL) { (data, response, error) in
            
            if error == nil && data != nil {
                do {
                    
                    if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [AnyObject]{
                        
                        self.parseResponse(path: path, responseArray:json)
                    }
                    
                } catch {
                    return
                }
            }
        }
        task.resume()
    }
    
    func post(path: API_Paths, request: [String:String]){
        
        //        self.dispatchResponse(response:, path: path)
    }
    
    
    // Parsing response methods
    func parseResponse(path: API_Paths, responseArray: [AnyObject]){
        switch path {
            
        case API_Paths.music_albums:
            let albumsList = ["data": responseArray]
            DispatchQueue.main.async {
                self.dispatchResponse(response: albumsList, path: path)
            }
        }
    }
    
    // MARK: - Internal notification to observers
    
    func dispatchResponse(response: [String: [Any]], path: API_Paths){
        
        let notification = Notification.init(name: Notification.Name(path.rawValue), object: nil, userInfo: response)
        
        NotificationCenter.default.post(notification)
    }
    
}
