//
//  SideBarHeaderView.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 16/05/23.
//

import UIKit

class SideBarHeaderView: UIView {
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Hi, guest!"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileImageView)
        addSubview(usernameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addConstraints()
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
    }
    
    func addConstraints() {
        let profileImageViewConstraints = [
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -(self.bounds.height / 8)),
            profileImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ]
        let usernameLabelConstraints = [
            usernameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            usernameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            usernameLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: 0)
        ]
        NSLayoutConstraint.activate(profileImageViewConstraints)
        NSLayoutConstraint.activate(usernameLabelConstraints)
    }
    
    func configure(with username: String?, avatarURL: URL?) {
        if let username = username {
            usernameLabel.text = "@\(username)"
        }
        guard let avatarURL = avatarURL else { return }
        profileImageView.sd_setImage(with: avatarURL)
    }

}
