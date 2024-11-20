//
//  HomeViewController.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 29/04/23.
//

import UIKit

class HomeViewController: UIViewController, ErrorViewControllerProtocol, SideBarViewControllerDelegate {
    
    var viewModel: HomeViewModel? {
        didSet {
            viewModel?.delegate = self
        }
    }
    
    private let homeFeedTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Do any additional setup after loading the view.
        viewModel?.delegate = self
        
        configureNavBar()
        
        homeFeedTable.dataSource = self
        homeFeedTable.delegate = self
        
        homeFeedTable.tableHeaderView = HeroHeaderUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 500))
        view.addSubview(homeFeedTable)
        
        viewModel?.getHeaderImage()

    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        let defaultOffset = view.safeAreaInsets.top
//        let offset = homeFeedTable.contentOffset.y + defaultOffset
//        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        homeFeedTable.frame = view.bounds
        homeFeedTable.frame = CGRect(x: 0, y: -1.0 * (view.safeAreaInsets.top), width: view.bounds.width, height: view.bounds.height + view.safeAreaInsets.top)
    }
    
    private func configureNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        
        var netflixLogo = UIImage(named: "NetflixLogo")
        netflixLogo = netflixLogo?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItems = [UIBarButtonItem(image: netflixLogo, style: .done, target: self, action: nil)]
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person", withConfiguration: UIImage.SymbolConfiguration(weight:  UIImage.SymbolWeight.bold)), style: .done, target: self, action: #selector(openProfileSideBar(_:))),
            UIBarButtonItem(image: UIImage(systemName: "play.rectangle", withConfiguration: UIImage.SymbolConfiguration(weight:  UIImage.SymbolWeight.bold)), style: .done, target: self, action: nil)
        ]
        
        navigationController?.navigationBar.tintColor = .label
    }
    
    @objc func openProfileSideBar(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {[weak self] in
            let vc = SideBarViewController()
            vc.delegate = self
            vc.viewModel = self?.viewModel?.assignSideBarViewModel()
            vc.modalPresentationStyle = .overFullScreen
            self?.present(vc, animated: false)
        }
    }

}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.getNoOfSections() ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel?.getSection(for: section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.noOfItemsInSection() ?? 0
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        headerView.textLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        headerView.textLabel?.textColor = .label
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.identifier, for: indexPath) as? CollectionViewTableViewCell else {
            return UITableViewCell()
        }
        cell.viewModel = viewModel?.assignCellViewModel()
        cell.viewModel?.tapDelegate = viewModel

        viewModel?.fetchTitles(for: indexPath, viewModel: cell.viewModel!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let defaultOffset = view.safeAreaInsets.top
//        let offset = scrollView.contentOffset.y + defaultOffset
//        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
//    }
    
}

extension HomeViewController: HomeViewModelDelegate, NavigateToVideoPreviewVCProtocol {
    func configureHeaderImage(with posterURL: URL?) {
        DispatchQueue.main.async {[weak self] in
            if let headerView = self?.homeFeedTable.tableHeaderView as? HeroHeaderUIView {
                headerView.configure(posterURL: posterURL)
            }
        }
    }
}

