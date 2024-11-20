//
//  SearchResultsViewController.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 02/05/23.
//

import UIKit

protocol SearchResultsViewControllerDelegate:AnyObject {
    func titleCellTapAction(title: TitleMOProtocol)
}

class SearchResultsViewController: UIViewController {
    
    var viewModel: SearchResultsViewModel? {
        didSet {
            viewModel?.delegate = self
        }
    }
    weak var delegate: SearchResultsViewControllerDelegate?
    
    private let searchCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 20) / 3, height: 200)
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        
        searchCollectionView.dataSource = self
        searchCollectionView.delegate = self
        view.addSubview(searchCollectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchCollectionView.frame = view.bounds
    }
}

extension SearchResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.getNoOfItems() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as? TitleCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(posterURL: viewModel?.getItem(for: indexPath))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.handleCellTap(for: indexPath)
    }
}

extension SearchResultsViewController: SearchResultsViewModelDelegate {
    
    func handleResultsUpdate() {
        DispatchQueue.main.async {[weak self] in
            self?.searchCollectionView.reloadData()
        }
    }
}
