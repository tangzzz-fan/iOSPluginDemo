//
//  ProfileViewController.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import UIKit
import Combine
import Anchorage

class ProfileViewController: UIViewController, ViewControllable, ViewControllerHelper, NavigationBarConfigurable {
    
    var cancellables = Set<AnyCancellable>()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "个人资料"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        
        titleLabel.centerAnchors == view.centerAnchors
    }
    
    func bindViewModel() {
        // Profile 页面暂时不需要绑定
    }
    
    func setupNavigationBar() {
        configureNavigationBar(title: "个人资料", prefersLargeTitles: true, largeTitleDisplayMode: .always)
    }
} 
