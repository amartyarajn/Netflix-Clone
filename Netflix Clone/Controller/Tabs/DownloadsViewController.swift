//
//  DownloadsViewController.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 29/04/23.
//

import UIKit

class DownloadsViewController: UIViewController {

    var viewModel: DownloadsViewModel? {
        didSet {
            viewModel?.delegate = self
        }
    }
    
    private let downloadTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UpcomingTableViewCell.self, forCellReuseIdentifier: UpcomingTableViewCell.identifier)
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        NotificationCenter.default.addObserver(forName: NSNotification.Name("Downloaded"), object: nil, queue: nil) { [weak self] _ in
            self?.viewModel?.isMoviesLoadingRequired = true
        }
        configureNavBar()
        view.addSubview(downloadTableView)
        downloadTableView.dataSource = self
        downloadTableView.delegate = self
        
        viewModel?.getDownloadedMovies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel?.isMoviesLoadingRequired == true {
            viewModel?.getDownloadedMovies()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        downloadTableView.frame = view.bounds
    }

    private func configureNavBar() {
        title = "Downloads"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = .label
    }
}

extension DownloadsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.getNoOfItems() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UpcomingTableViewCell.identifier, for: indexPath) as? UpcomingTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(viewModel: viewModel?.getTitle(for: indexPath))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.handleCellTap(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel?.deleteTitle(for: indexPath)
        }
    }
}

extension DownloadsViewController: DownloadsViewModelDelegate, NavigateToVideoPreviewVCProtocol {
    func handleDeleteAction(for indexPaths: [IndexPath]) {
        DispatchQueue.main.async {[weak self] in
            self?.downloadTableView.deleteRows(at: indexPaths, with: .automatic)
        }
    }
    
    func handleTitleUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel?.isMoviesLoadingRequired = false
            self?.downloadTableView.reloadData()
        }
    }
}
