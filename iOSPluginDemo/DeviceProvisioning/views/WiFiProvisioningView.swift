//
//  WiFiProvisioningView.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import UIKit

/// WiFi配网视图
class WiFiProvisioningView: UIView {
    // MARK: - Properties
    
    // UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "WiFi配网"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "正在搜索可用的WiFi网络..."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NetworkCell")
        return tableView
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("重新搜索", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // 添加UI元素
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(tableView)
        addSubview(refreshButton)
        
        // 设置约束
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: refreshButton.topAnchor, constant: -20),
            
            refreshButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            refreshButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            refreshButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            refreshButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 配置表格视图
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Public Methods
    
    /// 更新网络列表
    /// - Parameter networks: 网络列表
    func updateNetworks(_ networks: [NetworkInfo]) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    /// 更新描述文本
    /// - Parameter text: 描述文本
    func updateDescription(_ text: String) {
        DispatchQueue.main.async {
            self.descriptionLabel.text = text
        }
    }
    
    /// 设置刷新按钮事件处理
    /// - Parameter handler: 事件处理闭包
    func setRefreshButtonHandler(_ handler: @escaping () -> Void) {
        refreshButton.addTarget(for: .touchUpInside) { _ in
            handler()
        }
    }
}

// MARK: - UITableViewDataSource

extension WiFiProvisioningView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 在实际实现中，这里会返回网络列表的数量
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkCell", for: indexPath)
        
        // 在实际实现中，这里会配置单元格显示网络信息
        cell.textLabel?.text = "Network \(indexPath.row)"
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension WiFiProvisioningView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 在实际实现中，这里会处理网络选择事件
    }
}