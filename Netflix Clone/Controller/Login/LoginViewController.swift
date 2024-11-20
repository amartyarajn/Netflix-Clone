//
//  LoginViewController.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 14/05/23.
//

import UIKit

class LoginViewController: UIViewController, ErrorViewControllerProtocol {
    
    var viewModel: LoginViewModel? {
        didSet {
            viewModel?.delegate = self
        }
    }
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "NetflixLarge")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .label
        button.setTitleColor(.systemBackground, for: .normal)
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let guestButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.setTitle("Continue as guest", for: .normal)
        button.backgroundColor = .systemBackground
        button.setTitleColor(.label, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.label.cgColor
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let actInd = UIActivityIndicatorView(style: .large)
        actInd.hidesWhenStopped = true
        actInd.translatesAutoresizingMaskIntoConstraints = false
        return actInd
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        loginButton.addTarget(self, action: #selector(loginAction(_:)), for: .touchUpInside)
        guestButton.addTarget(self, action: #selector(guestAction(_:)), for: .touchUpInside)
        
        view.addSubview(loginButton)
        view.addSubview(logoImageView)
        view.addSubview(guestButton)
        view.addSubview(activityIndicator)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addConstraints()
    }
    
    func addConstraints() {
        
        let logoImageViewConstraints = [
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 50),
            logoImageView.heightAnchor.constraint(equalToConstant: 96),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80)
        ]
        
        let loginButtonConstraints = [
            loginButton.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 50),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        let guestButtonConstraints = [
            guestButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10),
            guestButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guestButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            guestButton.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        let activityIndicatorConstraints = [
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            activityIndicator.widthAnchor.constraint(equalToConstant: 50),
            activityIndicator.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(logoImageViewConstraints)
        NSLayoutConstraint.activate(loginButtonConstraints)
        NSLayoutConstraint.activate(guestButtonConstraints)
        NSLayoutConstraint.activate(activityIndicatorConstraints)
        
    }
    
    @objc private func loginAction(_ sender: UIButton) {
        activityIndicator.startAnimating()
        viewModel?.loginAction()
    }
    
    @objc private func guestAction(_ sender: UIButton) {
        dismiss(animated: false, completion: {
            let tabVC = MainTabBarViewController()
            UIApplication.shared.windows.first?.rootViewController = tabVC
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        })
    }
}

extension LoginViewController: LoginViewModelDelegate {
    
    func loginCompletionAction() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.dismiss(animated: false, completion: {
                let tabVC = MainTabBarViewController()
                UIApplication.shared.windows.first?.rootViewController = tabVC
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            })
        }
    }
}
