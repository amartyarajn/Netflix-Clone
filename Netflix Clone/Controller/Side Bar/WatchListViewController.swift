//
//  WatchListViewController.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 21/05/23.
//

import UIKit

class WatchListViewController: UIViewController, ErrorViewControllerProtocol {
    
    var viewModel: WatchListViewModel? {
        didSet {
            viewModel?.delegate = self
        }
    }
    
    private let watchListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UpcomingTableViewCell.self, forCellReuseIdentifier: UpcomingTableViewCell.identifier)
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private let mediaTypeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["",""])
        segmentedControl.backgroundColor = .systemBackground
        segmentedControl.selectedSegmentTintColor = .tertiaryLabel
        segmentedControl.setTitle("Movie", forSegmentAt: 0)
        segmentedControl.setTitle("TV", forSegmentAt: 1)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        configureNavBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateWatchList(_:)), name: NSNotification.Name(rawValue: "WatchList"), object: nil)
        
        watchListTableView.dataSource = self
        watchListTableView.delegate = self
        
        mediaTypeSegmentedControl.addTarget(self, action: #selector(mediaTypeSelected(_:)), for: .valueChanged)

        view.addSubview(watchListTableView)

        
        viewModel?.selectedMediaType = .Movie
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel?.selectedMediaType == .Movie && viewModel?.isMoviesLoadRequired == true {
            viewModel?.getWatchList()
        } else if viewModel?.selectedMediaType == .TV && viewModel?.isTVsLoadRequired == true {
            viewModel?.getWatchList()
        }
    }
    
    @objc func updateWatchList(_ notification: NSNotification) {
        if let mediaType = notification.userInfo?["media-type"] as? String {
            if mediaType == MediaType.Movie.rawValue {
                viewModel?.isMoviesLoadRequired = true
            } else {
                viewModel?.isTVsLoadRequired = true
            }
        }
    }
    
    private func configureNavBar() {
        title = "Watch List"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = .label
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        watchListTableView.frame = view.bounds
    }
    
    @objc func mediaTypeSelected(_ sender: UISegmentedControl) {
        viewModel?.selectedMediaType = sender.selectedSegmentIndex == 0 ? .Movie : .TV
    }
}

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.getNoOfTitles() ?? 0
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            return mediaTypeSegmentedControl
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.handleCellTap(for: indexPath)
    }
}

extension WatchListViewController: WatchListViewModelDelegate, NavigateToVideoPreviewVCProtocol {
    func handleTitlesUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.watchListTableView.reloadData()
        }
    }
}

