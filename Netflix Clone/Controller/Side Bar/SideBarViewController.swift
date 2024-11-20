//
//  SideBarViewController.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 16/05/23.
//

import UIKit
import SDWebImage

protocol SideBarViewControllerDelegate: UIViewController {
    
}

class SideBarViewController: UIViewController, ErrorViewControllerProtocol {
    
    var viewModel: SideBarViewModel? {
        didSet {
            viewModel?.delegate = self
        }
    }
    
    var delegate: SideBarViewControllerDelegate?
    
    private let sideBarView: UIView = {
        let uiview = UIView()
        uiview.backgroundColor = .systemBackground.withAlphaComponent(0.3)
        uiview.translatesAutoresizingMaskIntoConstraints = false
        return uiview
    }()
    
    private let sideBarTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var tableViewTrailingConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        view.addGestureRecognizer(swipe)
        
        logoutButton.setTitle(viewModel?.getLoginLogoutButtonTitle(), for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutAction(_:)), for: .touchUpInside)
        
        sideBarTableView.tableHeaderView = SideBarHeaderView()
        sideBarTableView.dataSource = self
        sideBarTableView.delegate = self
        
        view.backgroundColor = .clear
        view.addSubview(sideBarView)
        view.addSubview(sideBarTableView)
        view.addSubview(logoutButton)
        
//        viewModel?.fetchUserDetails()
        configureHeaderView()
    }
    
    @objc private func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                guard let self = self else { return }
                self.tableViewTrailingConstraint?.constant = self.view.bounds.width * 0.75
                self.view.layoutIfNeeded()
            }) {_ in
                self.dismiss(animated: false)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableViewTrailingConstraint = sideBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: view.bounds.width * 0.75)
        sideBarTableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: sideBarTableView.bounds.width, height: 200)
        print("viewWillAppear")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubviews")
        addConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sideBarView.addBlurEffect(with: .prominent)
        animateSideBar(isExpanding: true, completionBlock: nil)
        print("viewdidappear")
    }
    
    func addConstraints() {
        
        let sideBarViewConstraints = [
            sideBarView.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.75),
            sideBarView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.layoutMargins.top),
            sideBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(view.layoutMargins.bottom)),
            tableViewTrailingConstraint!
        ]
        
        let sideBarTableViewConstraints = [
            sideBarTableView.leadingAnchor.constraint(equalTo: sideBarView.leadingAnchor, constant: 0),
            sideBarTableView.topAnchor.constraint(equalTo: sideBarView.topAnchor, constant: 0),
            sideBarTableView.bottomAnchor.constraint(equalTo: sideBarView.bottomAnchor, constant: -60),
            sideBarTableView.trailingAnchor.constraint(equalTo: sideBarView.trailingAnchor, constant: 0)
        ]
        
        let logoutButtonConstraints = [
            logoutButton.bottomAnchor.constraint(equalTo: sideBarView.bottomAnchor, constant: -10),
            logoutButton.leadingAnchor.constraint(equalTo: sideBarView.leadingAnchor, constant: 10),
            logoutButton.trailingAnchor.constraint(equalTo: sideBarView.trailingAnchor, constant: -10),
            logoutButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        NSLayoutConstraint.activate(sideBarViewConstraints)
        NSLayoutConstraint.activate(sideBarTableViewConstraints)
        NSLayoutConstraint.activate(logoutButtonConstraints)
    }
    
    @objc private func logoutAction(_ sender: UIButton) {
        self.viewModel?.loginLogoutAction()
    }
    
    private func animateSideBar(isExpanding: Bool, completionBlock: ((Bool) -> Void)?) {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else { return }
            self.tableViewTrailingConstraint?.constant = isExpanding ? 0 : self.view.bounds.width * 0.75
            self.view.layoutIfNeeded()
        }, completion: completionBlock)
    }
    
    func configureHeaderView() {
        if let headerview = sideBarTableView.tableHeaderView as? SideBarHeaderView {
            headerview.configure(with: viewModel?.getUsername(), avatarURL: viewModel?.getProfileImageURL())
        }
    }
}

extension SideBarViewController: SideBarViewModelDelegate {
//    func navigateToWebViewVC(with urlRequest: URLRequest?) {
//        DispatchQueue.main.async { [weak self] in
//            let authVC = WebAuthenticationViewController()
//            authVC.viewModel = self?.viewModel?.assignWebAuthenticationViewModel()
//            authVC.viewModel?.loadRequest(with: urlRequest)
//            authVC.modalPresentationStyle = .fullScreen
//            self?.present(authVC, animated: true)
//        }
//    }
    
    func loginCompletionAction() {
        animateSideBar(isExpanding: false) { _ in
            self.dismiss(animated: false) {
                print("Logged in")
            }
        }
    }
    
    func handleLogout() {
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
        animateSideBar(isExpanding: false) { _ in
            self.dismiss(animated: false) {
                NotificationCenter.default.post(name: NSNotification.Name("Logout"), object: nil)
            }
        }
    }
}

extension SideBarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.getNoOfMenus() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = viewModel?.getMenu(for: indexPath)
            content.imageProperties.tintColor = .label
            content.image = UIImage(systemName: viewModel?.getMenuImage(for: indexPath) ?? "")
            cell.contentConfiguration = content

        } else {
            // Fallback on earlier versions
            cell.textLabel?.text = viewModel?.getMenu(for: indexPath)
        }
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        animateSideBar(isExpanding: false) { _ in
            self.dismiss(animated: false) {[weak self] in
                if indexPath.row == 0 {
                    let wlVC = WatchListViewController()
                    wlVC.viewModel = self?.viewModel?.assignWatchListViewModel()
                    self?.delegate?.navigationController?.pushViewController(wlVC, animated: true)
                } else if indexPath.row == 1 {
                    let favVC = FavouritesViewController()
                    favVC.viewModel = self?.viewModel?.assignFavouritesViewModel()
                    self?.delegate?.navigationController?.pushViewController(favVC, animated: true)
                }
            }
        }
    }

}
