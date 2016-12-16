//
//  AniListClientAuthentication.swift
//  AniManager
//
//  Created by Tobias Helmrich on 15.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

extension AniListClient {
    
    // MARK: - GET
    
    func getAuthenticatedUser(completionHandlerForUser: @escaping (_ user: User?, _ errorMessage: String?) -> Void) {
        validateAccessToken { (errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForUser(nil, errorMessage!)
                return
            }
            
            // URL creation and request configuration
            
            guard let url = self.createAniListUrl(withPath: AniListConstant.Path.UserGet.authenticatedUserModel, andParameters: [:]) else {
                completionHandlerForUser(nil, "Couldn't create AniList URL")
                return
            }
            
            let request = NSMutableURLRequest(url: url)
            request.addValue(AniListConstant.HeaderFieldValue.contentType, forHTTPHeaderField: AniListConstant.HeaderFieldName.contentType)
            request.addValue("Bearer \(UserDefaults.standard.string(forKey: "accessToken")!)", forHTTPHeaderField: AniListConstant.HeaderFieldName.authorization)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                if let errorMessage = self.checkDataTaskResponseForError(data: data, response: response, error: error) {
                    completionHandlerForUser(nil, errorMessage)
                    return
                }
                
                let data = data!
                
                guard let jsonObject = self.deserializeJson(fromData: data) else {
                    completionHandlerForUser(nil, "Couldn't deserialize data into a JSON object")
                    return
                }
                
                guard let userDictionary = jsonObject as? [String:Any],
                    let user = User(fromDictionary: userDictionary) else {
                        completionHandlerForUser(nil, "Couldn't create user object")
                        return
                }
                
                completionHandlerForUser(user, nil)
                
            }
            
            task.resume()
            
        }
    }
    
    
    // MARK: - POST
    
    /*
     This method gets an access token (and also a refresh token if the
     authorization happens with an authorization code) by using either
     an authorization code (for the first authorization) or a refresh token
     */
    func getAccessToken(withAuthorizationCode: Bool = false, withRefreshToken: Bool = false, completionHandlerForTokens: @escaping (_ accessToken: AccessToken?, _ refreshToken: String?, _ errorMessage: String?) -> Void) {
        
        /*
            Create a parameters array with parameters that are necessary to get
            an access token (client ID, client secret)
         */
        var parameters = [
            AniListConstant.ParameterKey.Authentication.clientId: AniListConstant.Account.clientId,
            AniListConstant.ParameterKey.Authentication.clientSecret: AniListConstant.Account.clientSecret
        ]
        
        /*
            Check whether the access token should be requested by using an authorization
            code or a refresh token and add the appropriate parameters to the parameters
            array based on the this
         */
        if withAuthorizationCode == true,
            let authorizationCode = authorizationCode {
            parameters[AniListConstant.ParameterKey.Authentication.grantType] = AniListConstant.ParameterValue.Authentication.grantTypeAuthorizationCode
            parameters[AniListConstant.ParameterKey.Authentication.redirectUri] = AniListConstant.ParameterValue.Authentication.redirectUri
            parameters[AniListConstant.ParameterKey.Authentication.code] = authorizationCode
        }
        
        if withRefreshToken == true,
            let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") {
            parameters[AniListConstant.ParameterKey.Authentication.grantType] = AniListConstant.ParameterValue.Authentication.grantTypeRefreshToken
            parameters[AniListConstant.ParameterKey.Authentication.refreshToken] = refreshToken
        }
        
        // URL creation and request configuration
        
        guard let url = createAniListUrl(withPath: AniListConstant.Path.Authentication.accessToken, andParameters: parameters) else {
            completionHandlerForTokens(nil, nil, "Couldn't create AniList URL")
            return
        }
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let errorMessage = self.checkDataTaskResponseForError(data: data, response: response, error: error) {
                completionHandlerForTokens(nil, nil, errorMessage)
                return
            }
            
            let data = data!
            
            guard let jsonObject = self.deserializeJson(fromData: data) else {
                completionHandlerForTokens(nil, nil, "Error when trying to deserialize JSON")
                return
            }
            
            guard let jsonDictionary = jsonObject as? [String:Any] else {
                completionHandlerForTokens(nil, nil, "Error when trying to cast JSON object to dictionary type")
                return
            }
            
            /*
                Try to extract all values needed to create an access token object
                (access token value, type, expiration timestamp) and create an access
                token object from them
            */
            guard let accessTokenValue = jsonDictionary[AniListConstant.ResponseKey.Authentication.accessToken] as? String,
                let tokenType = jsonDictionary[AniListConstant.ResponseKey.Authentication.tokenType] as? String,
                let expirationTimestamp = jsonDictionary[AniListConstant.ResponseKey.Authentication.expires] as? Int else {
                    completionHandlerForTokens(nil, nil, "Couldn't parse access token values from JSON object")
                    return
            }
            
            let accessToken = AccessToken(accessTokenValue: accessTokenValue, tokenType: tokenType, expirationTimestamp: expirationTimestamp)
            
            /*
                If the authentication is done via an authorization code, the refresh token
                should also be extracted from the dictionary. The completion handler should
                be called and get just the access token as a parameter if the request was
                made with a refresh token OR the access token *and* the refresh token if the
                access token was requested with an authorization code
            */
            if withAuthorizationCode == true {
                guard let refreshTokenValue = jsonDictionary[AniListConstant.ResponseKey.Authentication.refreshToken] as? String else {
                    completionHandlerForTokens(nil, nil, "Couldn't parse refresh token value from JSON object")
                    return
                }
                completionHandlerForTokens(accessToken, refreshTokenValue, nil)
            } else {
                completionHandlerForTokens(accessToken, nil, nil)
            }
        }
        
        task.resume()
        
    }
    
    /*
        This method checks if the current access token is still valid by checking
        the expiration timestamp. If it's not, a new access token should be requested
        and set in the user defaults.
     */
    func validateAccessToken(completionHandlerForValidation: @escaping (_ errorMessage: String?) -> Void) {
        if isAccessTokenValid() {
            completionHandlerForValidation(nil)
            return
        }
        
        getAccessToken(withRefreshToken: true) { (accessToken, _, errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForValidation(errorMessage!)
                return
            }
            
            guard let accessToken = accessToken else {
                completionHandlerForValidation("Couldn't get access token")
                return
            }
            
            UserDefaults.standard.set(accessToken.accessTokenValue, forKey: "accessToken")
            UserDefaults.standard.set(accessToken.expirationTimestamp, forKey: "expirationTimestamp")
            
            completionHandlerForValidation(nil)
            
        }
    }
}