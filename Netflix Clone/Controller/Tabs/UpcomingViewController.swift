//
//  UpcomingViewController.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 29/04/23.
//

import UIKit

class UpcomingViewController: UIViewController, ErrorViewControllerProtocol {
    
    var viewModel: UpcomingTabViewModel? {
        didSet {
            viewModel?.delegate = self
        }
    }
    
    private let upcomingTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UpcomingTableViewCell.self, forCellReuseIdentifier: UpcomingTableViewCell.identifier)
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        
        configureNavBar()
        
        upcomingTableView.dataSource = self
        upcomingTableView.delegate = self
        view.addSubview(upcomingTableView)
        
        viewModel?.getUpcomingMovies()
    }
    
    private func configureNavBar() {
        title = "Upcoming"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = .label
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        upcomingTableView.frame = view.bounds
    }
}

extension UpcomingViewController: UITableViewDelegate, UITableViewDataSource {
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
}

extension UpcomingViewController: UpcomingTabViewModelDelegate, NavigateToVideoPreviewVCProtocol {
    func handleTitleUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.upcomingTableView.reloadData()
        }
    }
}

protocol BaseViewControllerProtocol: UIViewController {
    associatedtype T: BaseViewModel
    var viewModel: T? {get set}
}

protocol ErrorViewControllerProtocol: BaseViewControllerProtocol {
    
}

extension ErrorViewControllerProtocol {
    func handleError(with errorMsg: String) {
        viewModel?.isError = true
        DispatchQueue.main.async {[weak self] in
            self?.showErrorAlert(with: errorMsg, handler: {
                self?.viewModel?.isError = false
            })
        }
    }
}

protocol NavigateToVideoPreviewVCProtocol: BaseViewControllerProtocol {
    
}

extension NavigateToVideoPreviewVCProtocol {
    func navigateToVideoPreviewVC(with title: TitleMOProtocol) {
        DispatchQueue.main.async {[weak self] in
            let vc = VideoPreviewViewController()
            vc.viewModel = self?.viewModel?.assignVideoPreviewViewModel()
            vc.viewModel?.configure(title: title)
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: false)
        }
    }
}


