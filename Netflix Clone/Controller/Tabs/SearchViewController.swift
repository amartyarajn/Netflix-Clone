//
//  SearchViewController.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 29/04/23.
//

import UIKit

class SearchViewController: UIViewController, ErrorViewControllerProtocol {
    
    var viewModel: SearchViewModel? {
        didSet {
            viewModel?.delegate = self
        }
    }
    
    private let searchController: UISearchController = {
        let searchVC = UISearchController(searchResultsController: SearchResultsViewController())
        searchVC.searchBar.placeholder = "Search Movie or TV"
        searchVC.searchBar.searchBarStyle = .minimal
        return searchVC
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        
        configureNavBar()
        searchController.searchResultsUpdater = self
        if let searchResultsVC = searchController.searchResultsController as? SearchResultsViewController {
            searchResultsVC.viewModel = viewModel?.assignSearchResultViewModel()
            searchResultsVC.viewModel?.tapDelegate = self.viewModel
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.searchBar.text = nil
        searchController.dismiss(animated: false)
    }
    
    private func configureNavBar() {
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.searchController = searchController
        navigationController?.navigationBar.tintColor = .label
    }

}

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        guard let query = searchBar.text,
              let searchResultVC = searchController.searchResultsController as? SearchResultsViewController  else {
            return
        }
        self.viewModel?.getSearchResults(for: query, viewModel: searchResultVC.viewModel)
    }

}

extension SearchViewController: SearchViewModelDelegate, NavigateToVideoPreviewVCProtocol {

}
