//
//  VideoPreviewViewController.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 05/05/23.
//

import UIKit
import WebKit

class VideoPreviewViewController: UIViewController, ErrorViewControllerProtocol {
    
    var viewModel: VideoPreviewViewModel? {
        didSet {
            viewModel?.delegate = self
        }
    }
    private var videoURL: URL?
    
    private let titleWebView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let overviewLabel: UITextView = {
        let label = UITextView()
        label.contentInsetAdjustmentBehavior = .never
        label.isEditable = false
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let likeButton: UIButton = {
        
        let button = UIButton(frame: .zero)
        button.tag = 1
        button.setImage(UIImage(systemName: "hand.thumbsup", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
        button.setImage(UIImage(systemName: "hand.thumbsup.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .disabled)
        button.tintColor = .label
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let watchListButton: UIButton = {
        
        let button = UIButton(frame: .zero)
        button.tag = 2
        let insetAmount = 2.0;
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount);
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount);
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount);
        button.setTitle("Add To\nWatchlist", for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setImage(UIImage(systemName: "arrow.down.to.line.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
        button.setTitle("Added To\nWatchlist", for: .disabled)
        button.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .disabled)
        button.backgroundColor = .systemRed
        button.titleLabel?.textColor = .label
        button.tintColor = button.titleLabel?.textColor ?? .label
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 22
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let downloadButton: UIButton = {
        
        let button = UIButton(frame: .zero)
        button.tag = 3
        let insetAmount = 2.0;
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount);
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount);
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount);
        button.setTitle("Download", for: .normal)
        button.setImage(UIImage(systemName: "arrow.down.to.line.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
        button.setTitle("Downloaded", for: .disabled)
        button.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .disabled)
        button.backgroundColor = .systemRed
        button.titleLabel?.textColor = .label
        button.tintColor = button.titleLabel?.textColor ?? .label
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 22
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.transform = .init(translationX: 0, y: 0)
        view.backgroundColor = .systemBackground
        
        downloadButton.addTarget(self, action: #selector(titleAction(_:)), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(titleAction(_:)), for: .touchUpInside)
        watchListButton.addTarget(self, action: #selector(titleAction(_:)), for: .touchUpInside)
        
        view.addSubview(titleWebView)
        view.addSubview(likeButton)
        
        buttonsStackView.addArrangedSubview(watchListButton)
        buttonsStackView.addArrangedSubview(downloadButton)
        view.addSubview(buttonsStackView)
        
        view.addSubview(titleLabel)
        view.addSubview(overviewLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupConstraints()
    }
    
    private func setupConstraints() {
        let height = (navigationController?.navigationBar.frame.origin.y ?? 0.0) + (navigationController?.navigationBar.frame.height ?? 0.0)

        let webViewConstraints = [
            titleWebView.topAnchor.constraint(equalTo: view.topAnchor, constant: height),
            titleWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleWebView.heightAnchor.constraint(equalToConstant: 300)
        ]
        
        let likeButtonConstraints = [
            likeButton.topAnchor.constraint(equalTo: titleWebView.bottomAnchor, constant: 10),
            likeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            likeButton.widthAnchor.constraint(equalToConstant: 50),
            likeButton.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        let buttonsStackViewConstraints = [
            buttonsStackView.topAnchor.constraint(equalTo: titleWebView.bottomAnchor, constant: 10),
            buttonsStackView.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 10),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 45)
        ]
        
        let titleLabelConstraints = [
            titleLabel.topAnchor.constraint(equalTo: buttonsStackView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ]
        
        let overviewLabelConstraints = [
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            overviewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            overviewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            overviewLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(webViewConstraints)
        NSLayoutConstraint.activate(likeButtonConstraints)
        NSLayoutConstraint.activate(buttonsStackViewConstraints)
        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(overviewLabelConstraints)
    }
    
    @objc func titleAction(_ sender: UIButton) {
        if UserSession.shared.userDetails == nil {
            showLoginAlert(with: "Please login to continue", actionTitle: "Login") {
                self.viewModel?.loginAction()
            }
        } else {
            switch sender.tag {
            case 1:
                viewModel?.addFavouriteAction()
            case 2:
                viewModel?.addToWatchListAction()
            default:
                viewModel?.downloadAction()
            }
        }
    }

    deinit {
        print("video preview deinit")
    }
}

extension VideoPreviewViewController: VideoPreviewViewModelDelegate {
    func configureLikeButton() {
        DispatchQueue.main.async {[weak self] in
            let isFavourite = self?.viewModel?.isFavourite ?? false
            self?.likeButton.isEnabled = !isFavourite
        }
    }
    
    func configureWatchListButton() {
        DispatchQueue.main.async {[weak self] in
            let isWatchListed = self?.viewModel?.isWatchListed ?? false
            self?.watchListButton.isEnabled = !isWatchListed
            self?.watchListButton.backgroundColor = !isWatchListed ? .systemRed : .systemGray
        }
    }
    
    func loadVideo() {
        DispatchQueue.main.async {[weak self] in
            if let videoURL = self?.viewModel?.videoURL {
                self?.titleWebView.load(URLRequest(url: videoURL))
            }
        }
    }
    
    func configureDownloadButton() {
        DispatchQueue.main.async {[weak self] in
            let isDownloaded = self?.viewModel?.isDownloaded ?? false
            self?.downloadButton.isEnabled = !isDownloaded
            self?.downloadButton.backgroundColor = !isDownloaded ? .systemRed : .systemGray
        }
    }
    
    func handleResultUpdate() {
        DispatchQueue.main.async {[weak self] in
            self?.titleLabel.text =  self?.viewModel?.getTitle()
            self?.overviewLabel.text = self?.viewModel?.getOverview()
        }
    }
    
    func loginCompletionAction() {
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: false, completion: {
                self?.viewModel?.reloadTitleState()
            })
        }
    }
}
