//
//  CollectionViewTableViewCell.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 29/04/23.
//

import UIKit

class CollectionViewTableViewCell: UITableViewCell {
    
    var viewModel: HomeSectionViewModel? {
        didSet {
            viewModel?.delegate = self
        }
    }
    static let identifier = "CollectionViewTableViewCell"
    
    private let moviesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 140, height: 200)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        moviesCollectionView.dataSource = self
        moviesCollectionView.delegate = self
        
        contentView.addSubview(moviesCollectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        moviesCollectionView.frame = contentView.bounds
    }
}

extension CollectionViewTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.getNoOfItems() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as? TitleCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(posterURL: viewModel?.getPosterPath(for: indexPath))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.handleCellTap(for: indexPath)
    }
}

extension CollectionViewTableViewCell: HomeSectionViewModelDelegate {
    func handleTitleUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.moviesCollectionView.reloadData()
        }
    }
}
