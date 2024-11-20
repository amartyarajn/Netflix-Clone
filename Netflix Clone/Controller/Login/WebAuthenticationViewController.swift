//
//  WebAuthenticationViewController.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 14/05/23.
//

import UIKit
import WebKit

class WebAuthenticationViewController: UIViewController {
    
    var viewModel: WebAuthenticationViewModel? {
        didSet {
            viewModel?.delegate = self
        }
    }
    
    private let titleWebView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleWebView.navigationDelegate = self
        view.addSubview(titleWebView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleWebView.frame = view.bounds
    }
}

extension WebAuthenticationViewController: WebAuthenticationViewModelDelegate {
    
    func loadRequest() {
        DispatchQueue.main.async {[weak self] in
            guard let urlRequest = self?.viewModel?.getRequest() else { return }
            self?.titleWebView.load(urlRequest)
        }
    }
}

extension WebAuthenticationViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.url?.absoluteString.contains("/allow") == true {
            self.dismiss(animated: true) {
                self.viewModel?.sessionDelegate?.getSessionId()
            }
        }
    }
}
