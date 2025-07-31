//
//  NavigationBarConfigurable.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import UIKit

// MARK: - Navigation Bar Configuration Protocol
protocol NavigationBarConfigurable {
    func configureNavigationBar(title: String, prefersLargeTitles: Bool, largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode)
}

// MARK: - Default Implementation
extension NavigationBarConfigurable where Self: UIViewController {
    func configureNavigationBar(title: String, prefersLargeTitles: Bool = true, largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode = .always) {
        // 确保导航栏可见
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        // 设置标题
        self.title = title
        
        // 设置大标题样式
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
        navigationItem.largeTitleDisplayMode = largeTitleDisplayMode
        
        // 设置导航栏外观
        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.backgroundColor = .systemBackground
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
} 
