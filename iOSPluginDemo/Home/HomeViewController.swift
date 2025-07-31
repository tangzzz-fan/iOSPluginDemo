//
//  HomeViewController.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/7/31.
//

import UIKit
import Combine
import Anchorage

// MARK: - Home View Controller
class HomeViewController: UIViewController, ViewControllable, ViewControllerHelper, NavigationBarConfigurable {
    
    // MARK: - Properties
    var cancellables = Set<AnyCancellable>()
    private let viewModel: HomeViewModel
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "HomeCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    // MARK: - Initialization
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Setup
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 添加子视图
        view.addSubview(tableView)
        view.addSubview(loadingView)
        
        // 设置约束
        tableView.edgeAnchors == view.edgeAnchors
        
        loadingView.centerAnchors == view.centerAnchors
    }
    
    func bindViewModel() {
        // 绑定标题
        viewModel.$title
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.title = title
            }
            .store(in: &cancellables)
        
        // 绑定加载状态
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        // 绑定错误消息
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
            }
            .store(in: &cancellables)
        
        // 绑定数据
        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    func setupNavigationBar() {
        configureNavigationBar(title: viewModel.title, prefersLargeTitles: true, largeTitleDisplayMode: .always)
    }
    
    // MARK: - Actions
    @objc private func refreshData() {
        viewModel.refreshData()
    }
    
    // MARK: - Helper Methods
    func showLoading() {
        loadingView.startAnimating()
    }
    
    func hideLoading() {
        loadingView.stopAnimating()
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeTableViewCell
        let item = viewModel.items[indexPath.row]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = viewModel.items[indexPath.row]
        viewModel.selectItem(item)
    }
}

// MARK: - Home Table View Cell
class HomeTableViewCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        titleLabel.topAnchor == contentView.topAnchor + 12
        titleLabel.leadingAnchor == contentView.leadingAnchor + 16
        titleLabel.trailingAnchor == contentView.trailingAnchor - 16
        
        subtitleLabel.topAnchor == titleLabel.bottomAnchor + 4
        subtitleLabel.leadingAnchor == titleLabel.leadingAnchor
        subtitleLabel.trailingAnchor == titleLabel.trailingAnchor
        subtitleLabel.bottomAnchor == contentView.bottomAnchor - 12
    }
    
    func configure(with item: HomeItem) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
    }
} 