//
//  FeedbackVC.swift
//  Dante Staff
//
//  Created by Hung Phan on 8/11/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit
import WebKit

class FeedbackVC: UIViewController, WKNavigationDelegate {
    
    var webView : WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSfvRtJ9slWhf4Wt1RbMnB-ZC6qdHE5rRemr3s1U8Ge8iorHzA/viewform?usp=sf_link")
        webView.load(URLRequest(url: url!))
    
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = "Feedback"
    }
    
}
