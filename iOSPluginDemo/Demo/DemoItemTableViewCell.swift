//
//  DemoItemTableViewCell.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/1/27.
//

import UIKit
import Anchorage

// MARK: - Demo Item Table View Cell
final class DemoItemTableViewCell: UITableViewCell {
    
    // MARK: - Constants
    static let identifier = "DemoItemTableViewCell"
    
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var categoryBadge: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .systemBlue
        return view
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .tertiaryLabel
        return imageView
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Add container view
        contentView.addSubview(containerView)
        containerView.edgeAnchors == contentView.edgeAnchors + UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        
        // Add icon image view
        containerView.addSubview(iconImageView)
        iconImageView.leadingAnchor == containerView.leadingAnchor + 16
        iconImageView.centerYAnchor == containerView.centerYAnchor
        iconImageView.sizeAnchors == CGSize(width: 40, height: 40)
        
        // Add category badge
        containerView.addSubview(categoryBadge)
        categoryBadge.topAnchor == containerView.topAnchor + 12
        categoryBadge.trailingAnchor == containerView.trailingAnchor - 40
        categoryBadge.heightAnchor == 16
        
        categoryBadge.addSubview(categoryLabel)
        categoryLabel.edgeAnchors == categoryBadge.edgeAnchors + UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        
        // Add chevron
        containerView.addSubview(chevronImageView)
        chevronImageView.trailingAnchor == containerView.trailingAnchor - 16
        chevronImageView.centerYAnchor == containerView.centerYAnchor
        chevronImageView.sizeAnchors == CGSize(width: 12, height: 12)
        
        // Add title label
        containerView.addSubview(titleLabel)
        titleLabel.leadingAnchor == iconImageView.trailingAnchor + 12
        titleLabel.topAnchor == containerView.topAnchor + 12
        titleLabel.trailingAnchor == categoryBadge.leadingAnchor - 8
        
        // Add description label
        containerView.addSubview(descriptionLabel)
        descriptionLabel.leadingAnchor == titleLabel.leadingAnchor
        descriptionLabel.topAnchor == titleLabel.bottomAnchor + 4
        descriptionLabel.trailingAnchor == chevronImageView.leadingAnchor - 8
        descriptionLabel.bottomAnchor <= containerView.bottomAnchor - 12
    }
    
    // MARK: - Configuration
    func configure(with demo: DemoItem) {
        titleLabel.text = demo.title
        descriptionLabel.text = demo.description
        iconImageView.image = demo.icon
        categoryLabel.text = demo.category.rawValue
        categoryBadge.backgroundColor = demo.category.color
        
        // Update category badge width constraint
        categoryBadge.widthAnchor == categoryLabel.intrinsicContentSize.width + 16
    }
    
    // MARK: - Cell Selection Animation
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.2) {
            self.containerView.backgroundColor = highlighted ? .tertiarySystemGroupedBackground : .secondarySystemGroupedBackground
            self.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        descriptionLabel.text = nil
        iconImageView.image = nil
        categoryLabel.text = nil
        categoryBadge.backgroundColor = .systemBlue
    }
}
