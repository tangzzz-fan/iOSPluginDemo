//
//  QRCodeProvisioningView.swift
//  iOSPluginDemo
//
//  Created by Qwen on 2025/9/8.
//

import UIKit

/// 二维码配网视图
class QRCodeProvisioningView: UIView {
    // MARK: - Properties
    
    // UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "扫码配网"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "请将摄像头对准设备上的二维码"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scanView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.layer.borderWidth = 2
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let scanLine: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let manualInputButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("手动输入", for: .normal)
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
        addSubview(scanView)
        addSubview(scanLine)
        addSubview(manualInputButton)
        
        // 设置约束
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            scanView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            scanView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            scanView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            scanView.heightAnchor.constraint(equalTo: scanView.widthAnchor),
            
            scanLine.topAnchor.constraint(equalTo: scanView.topAnchor),
            scanLine.leadingAnchor.constraint(equalTo: scanView.leadingAnchor),
            scanLine.trailingAnchor.constraint(equalTo: scanView.trailingAnchor),
            scanLine.heightAnchor.constraint(equalToConstant: 2),
            
            manualInputButton.topAnchor.constraint(equalTo: scanView.bottomAnchor, constant: 40),
            manualInputButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            manualInputButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            manualInputButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 开始扫描线动画
        startScanLineAnimation()
    }
    
    // MARK: - Animation
    
    private func startScanLineAnimation() {
        // 重置扫描线位置
        scanLine.transform = CGAffineTransform(translationX: 0, y: 0)
        
        // 创建动画
        UIView.animate(withDuration: 2.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.scanLine.transform = CGAffineTransform(translationX: 0, y: self.scanView.frame.height - 2)
        })
    }
    
    // MARK: - Public Methods
    
    /// 更新描述文本
    /// - Parameter text: 描述文本
    func updateDescription(_ text: String) {
        DispatchQueue.main.async {
            self.descriptionLabel.text = text
        }
    }
    
    /// 设置手动输入按钮事件处理
    /// - Parameter handler: 事件处理闭包
    func setManualInputHandler(_ handler: @escaping () -> Void) {
        manualInputButton.addTarget(for: .touchUpInside) { _ in
            handler()
        }
    }
    
    /// 设置二维码扫描结果处理
    /// - Parameter handler: 事件处理闭包
    func setQRCodeScanHandler(_ handler: @escaping (String) -> Void) {
        // 在实际实现中，这里会集成二维码扫描库并处理扫描结果
        // 例如使用AVFoundation框架
    }
}