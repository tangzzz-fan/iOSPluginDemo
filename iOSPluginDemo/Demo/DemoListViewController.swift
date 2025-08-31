//
//  DemoListViewController.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/1/27.
//

import UIKit
import Combine
import Anchorage

// MARK: - Demo List View Controller
final class DemoListViewController: UIViewController, ViewControllable, NavigationBarConfigurable {
    
    // MARK: - Properties
    private let viewModel: DemoListViewModel
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "搜索演示功能..."
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DemoItemTableViewCell.self, forCellReuseIdentifier: DemoItemTableViewCell.identifier)
        tableView.refreshControl = refreshControl
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
        return control
    }()
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        let label = UILabel()
        label.text = "暂无演示功能"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        view.addSubview(label)
        label.centerAnchors == view.centerAnchors
        return view
    }()
    
    // MARK: - Data
    private var sections: [DemoSection] = []
    
    // MARK: - Initialization
    init(viewModel: DemoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.input.viewDidLoad.send()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    // MARK: - ViewControllable Implementation
    func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "功能演示"
        
        // Setup search controller
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        // Setup table view
        view.addSubview(tableView)
        tableView.edgeAnchors == view.safeAreaLayoutGuide.edgeAnchors
        
        // Setup loading view
        view.addSubview(loadingView)
        loadingView.centerAnchors == view.centerAnchors
        
        // Setup empty state view
        view.addSubview(emptyStateView)
        emptyStateView.edgeAnchors == view.safeAreaLayoutGuide.edgeAnchors
        emptyStateView.isHidden = true
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    // MARK: - Navigation Bar Configuration
    func configureNavigationBar() {
        setupNavigationBar()
    }
    
    func bindViewModel() {
        // Bind sections
        viewModel.output.sections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sections in
                self?.updateSections(sections)
            }
            .store(in: &cancellables)
        
        // Bind loading state
        viewModel.output.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.updateLoadingState(isLoading)
            }
            .store(in: &cancellables)
        
        // Bind error state
        viewModel.output.error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showError(errorMessage)
            }
            .store(in: &cancellables)
        
        // Bind demo selection
        viewModel.output.showDemo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] demo in
                self?.handleDemoSelection(demo)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Updates
    private func updateSections(_ sections: [DemoSection]) {
        self.sections = sections
        tableView.reloadData()
        
        emptyStateView.isHidden = !sections.isEmpty
        tableView.isHidden = sections.isEmpty
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            loadingView.startAnimating()
        } else {
            loadingView.stopAnimating()
            refreshControl.endRefreshing()
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    private func handleDemoSelection(_ demo: DemoItem) {
        // 可以在这里添加选择反馈，比如轻微震动
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - Actions
    @objc private func refreshTriggered() {
        viewModel.input.refreshTriggered.send()
    }
}

// MARK: - UITableView DataSource
extension DemoListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DemoItemTableViewCell.identifier, for: indexPath) as! DemoItemTableViewCell
        let demo = sections[indexPath.section].items[indexPath.row]
        cell.configure(with: demo)
        return cell
    }
}

// MARK: - UITableView Delegate
extension DemoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let demo = sections[indexPath.section].items[indexPath.row]
        viewModel.input.itemSelected.send(demo)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - UISearchResultsUpdating
extension DemoListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        viewModel.input.searchTextChanged.send(searchText)
    }
}

