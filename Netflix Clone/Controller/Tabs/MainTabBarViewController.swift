//
//  ViewController.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 29/04/23.
//

import UIKit
import WebKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("Logout"), object: nil, queue: nil) { [weak self] _ in
            self?.dismiss(animated: true, completion: {
                let loginVC = LoginViewController()
                loginVC.viewModel = LoginViewModel(manager: LoginManager(repository: UserSessionRepository()))
                UIApplication.shared.windows.first?.rootViewController = loginVC
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            })
        }
        
        let vc1 = HomeViewController()
        vc1.viewModel = HomeViewModel(repository: TitlesRepository())
        
        let vc2 = UpcomingViewController()
        vc2.viewModel = UpcomingTabViewModel(repository: TitlesRepository())
        
        let vc3 = SearchViewController()
        vc3.viewModel = SearchViewModel(repository: TitlesRepository())
        
        let vc4 = DownloadsViewController()
        vc4.viewModel = DownloadsViewModel(repository: AccountListsRepository())
        
        let nVc1 = UINavigationController(rootViewController: vc1)
        nVc1.navigationBar.backgroundColor = .clear
        let nVc2 = UINavigationController(rootViewController: vc2)
        let nVc3 = UINavigationController(rootViewController: vc3)
        let nVc4 = UINavigationController(rootViewController: vc4)
        
        nVc1.tabBarItem.image = UIImage(systemName: "house")
        nVc2.tabBarItem.image = UIImage(systemName: "play.circle")
        nVc3.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        nVc4.tabBarItem.image = UIImage(systemName: "arrow.down.to.line")
        
        nVc1.title = "Home"
        nVc2.title = "Upcoming"
        nVc3.title = "Search"
        nVc4.title = "Downloads"
        
        tabBar.tintColor = .label
        
        setViewControllers([nVc1, nVc2, nVc3, nVc4], animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    deinit {
        print("Tab bar deinit")
    }
    
}

