//
//  HeroHeaderUIView.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 30/04/23.
//

import UIKit
import SDWebImage

class HeroHeaderUIView: UIView {

    private let heroImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.setTitle("Play", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.label.cgColor
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let downloadButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.setTitle("Download", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.label.cgColor
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let heroStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let heroGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.tertiarySystemBackground.withAlphaComponent(0.8).cgColor, UIColor.clear.cgColor, UIColor.systemBackground.cgColor]
        return gradientLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(heroImageView)
        layer.addSublayer(heroGradientLayer)
        
        heroStackView.addArrangedSubview(playButton)
        heroStackView.addArrangedSubview(downloadButton)
        addSubview(heroStackView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heroImageView.frame = bounds
        heroGradientLayer.frame = bounds
        applyConstraints()
    }

    private func applyConstraints() {
        let heroStackViewConstraints = [
            heroStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            heroStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            heroStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            heroStackView.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        NSLayoutConstraint.activate(heroStackViewConstraints)
    }
    
    func configure(posterURL: URL?) {
        guard let url = posterURL else { return }
        heroImageView.sd_setImage(with: url)
    }
}
