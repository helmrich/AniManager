//
//  WebViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 19.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    // MARK: - Properties
    
    var url: URL!
    let errorMessageView = ErrorMessageView()
    var loadingStatusView = LoadingStatusView()
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var reloadButton: UIButton!
    
    // MARK: - Action
    
    @IBAction func cancel() {
        NetworkActivityManager.shared.numberOfActiveConnections = 0
        NetworkActivityManager.shared.setupStatusBarActivityIndicator()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reload(_ sender: Any) {
        UIView.animate(withDuration: 0.25) {
            self.reloadButton.alpha = 0.0
            self.errorMessageView.alpha = 0.0
        }
        load()
    }
    
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorMessageView.addToBottom(of: view)
        view.addSubview(loadingStatusView)
        loadingStatusView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: loadingStatusView, attribute: .top, relatedBy: .equal, toItem: toolbar, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: loadingStatusView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: loadingStatusView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: loadingStatusView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0)
            ])
        toolbar.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        load()
    }
    
    func load() {
        let request = URLRequest(url: url)
        webView.loadRequest(request)
    }
}

extension WebViewController: UIWebViewDelegate {
    /*
        Stop animating the activity indicator and hide it, when the web
        view did finish loading
     */
    func webViewDidFinishLoad(_ webView: UIWebView) {
        NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
        loadingStatusView.setVisibilityDependingOnNetworkStatus()
    }
    
    /*
        Every time the web view starts loading a page,
        check its request's URL's string and see if it
        contains "?code=" which implies, that the user
        approved the authorization request or if contains
        "?error=access_denied" which implies that the
        user denied the request.

        This solution is not very clean but the only other
        way would be to execute the authorization request
        in the device's default browser instead of in the
        application itself, so that the redirect URI would
        open the application again. But because it feels
        more natural when the process happens in a web view
        inside of the app this solution is used for now.
     */
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        NetworkActivityManager.shared.increaseNumberOfActiveConnections()
        loadingStatusView.setVisibilityDependingOnNetworkStatus()
        
        guard let request = webView.request,
            let mainDocumentURLString = request.mainDocumentURL?.absoluteString else {
                return
        }
        
        if mainDocumentURLString.contains("?code=") {
            NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
            loadingStatusView.setVisibilityDependingOnNetworkStatus()
            /*
                If the URL string contains "?code=" the URL's string should be split
                up in two components of which the second one will contain the
                authorization code. Afterwards the shared AniListClient's authorizationCode
                property should be set to the received authorization code and the
                web view controller should be dismissed.
             */
            let components = mainDocumentURLString.components(separatedBy: "?code=")
            guard let authorizationCode = components.last else {
                errorMessageView.showAndHide(withMessage: "Couldn't get Authorization Code")
                return
            }
            AniListClient.shared.authorizationCode = authorizationCode
            dismiss(animated: true, completion: nil)
        } else if mainDocumentURLString.contains("?error=access_denied") {
            NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
            self.loadingStatusView.setVisibilityDependingOnNetworkStatus()
            /*
                If the URL string contains "?error=access_denied" the WebViewController
                should be dismissed
             */
            dismiss(animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        errorMessageView.showAndHide(withMessage: error.localizedDescription)
        NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
        loadingStatusView.setVisibilityDependingOnNetworkStatus()
        UIView.animate(withDuration: 0.25) {
            self.reloadButton.alpha = 1.0
        }
    }
}
