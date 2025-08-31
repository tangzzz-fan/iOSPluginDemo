//
//  ScreenshotService.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/1/27.
//

import UIKit
import Combine

// MARK: - Screenshot Error
enum ScreenshotError: Error {
    case generationFailed
    case viewNotAvailable
    case invalidScrollView
    
    var localizedDescription: String {
        switch self {
        case .generationFailed:
            return "截图生成失败"
        case .viewNotAvailable:
            return "视图不可用"
        case .invalidScrollView:
            return "无效的滚动视图"
        }
    }
}

// MARK: - Screenshot Generating Protocol
/// A protocol for a service that generates a long screenshot from a UIScrollView.
protocol ScreenshotGenerating {
    /// Generates a single image from the entire content of a scroll view.
    /// - Parameter scrollView: The UIScrollView to capture.
    /// - Returns: A publisher that emits the final UIImage or a ScreenshotError.
    func generate(from scrollView: UIScrollView) -> AnyPublisher<UIImage, ScreenshotError>
    
    /// Generates a single image from the entire content of a view.
    /// - Parameter view: The UIView to capture.
    /// - Returns: A publisher that emits the final UIImage or a ScreenshotError.
    func generate(from view: UIView) -> AnyPublisher<UIImage, ScreenshotError>
}

// MARK: - Screenshot Generator Implementation
final class ScreenshotGenerator: ScreenshotGenerating {
    
    // MARK: - Private Properties
    private let maxImageSize: CGFloat = 16384 // Maximum image size to avoid memory issues
    
    func generate(from scrollView: UIScrollView) -> AnyPublisher<UIImage, ScreenshotError> {
        return Future<UIImage, ScreenshotError> { promise in
            DispatchQueue.main.async {
                guard scrollView.window != nil else {
                    promise(.failure(.viewNotAvailable))
                    return
                }
                
                // Validate scroll view
                guard scrollView.contentSize.width > 0 && scrollView.contentSize.height > 0 else {
                    promise(.failure(.invalidScrollView))
                    return
                }
                
                // Try optimized direct approach first
                self.generateOptimizedScreenshot(from: scrollView, promise: promise)
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Generates screenshot using an optimized approach that works for most content sizes
    private func generateOptimizedScreenshot(from scrollView: UIScrollView, promise: @escaping (Result<UIImage, ScreenshotError>) -> Void) {
        // 1. Save all original states
        let originalOffset = scrollView.contentOffset
        let originalFrame = scrollView.frame
        let originalBounds = scrollView.bounds
        let originalClipsToBounds = scrollView.clipsToBounds
        let originalShowsVerticalScrollIndicator = scrollView.showsVerticalScrollIndicator
        let originalShowsHorizontalScrollIndicator = scrollView.showsHorizontalScrollIndicator
        let originalBackgroundColor = scrollView.backgroundColor
        let originalAlpha = scrollView.alpha
        
        // 2. Configure for capture
        scrollView.clipsToBounds = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alpha = 1.0
        
        // Set background color if not set
        if scrollView.backgroundColor == nil || scrollView.backgroundColor == .clear {
            scrollView.backgroundColor = .systemBackground
        }
        
        let contentSize = scrollView.contentSize
        let scale = UIScreen.main.scale
        
        // 3. Temporarily expand the scroll view to show all content
        scrollView.contentOffset = .zero
        scrollView.bounds = CGRect(origin: .zero, size: contentSize)
        
        // 4. Force layout and display
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        scrollView.setNeedsDisplay()
        scrollView.layer.displayIfNeeded()
        
        // 5. Ensure all subviews are also laid out
        for subview in scrollView.subviews {
            subview.setNeedsLayout()
            subview.layoutIfNeeded()
            subview.setNeedsDisplay()
            subview.layer.displayIfNeeded()
        }
        
        // 6. Create the final image
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = true
        
        let renderer = UIGraphicsImageRenderer(size: contentSize, format: format)
        let image = renderer.image { context in
            // Fill with background color first
            if let bgColor = scrollView.backgroundColor {
                bgColor.setFill()
            } else {
                UIColor.systemBackground.setFill()
            }
            context.fill(CGRect(origin: .zero, size: contentSize))
            
            // Render the scroll view content
            scrollView.layer.render(in: context.cgContext)
        }
        
        // 7. Restore all original states
        scrollView.bounds = originalBounds
        scrollView.frame = originalFrame
        scrollView.contentOffset = originalOffset
        scrollView.clipsToBounds = originalClipsToBounds
        scrollView.showsVerticalScrollIndicator = originalShowsVerticalScrollIndicator
        scrollView.showsHorizontalScrollIndicator = originalShowsHorizontalScrollIndicator
        scrollView.backgroundColor = originalBackgroundColor
        scrollView.alpha = originalAlpha
        
        // Force layout restoration
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        
        // 8. Return result
        if image.size.width > 0 && image.size.height > 0 {
            promise(.success(image))
        } else {
            promise(.failure(.generationFailed))
        }
    }
    
    // MARK: - Private Methods
    
    /// Generates screenshot directly by modifying scroll view bounds
    private func generateDirectScreenshot(from scrollView: UIScrollView, promise: @escaping (Result<UIImage, ScreenshotError>) -> Void) {
        // 1. Save original state
        let originalOffset = scrollView.contentOffset
        let originalFrame = scrollView.frame
        let originalBounds = scrollView.bounds
        let originalClipsToBounds = scrollView.clipsToBounds
        let originalShowsVerticalScrollIndicator = scrollView.showsVerticalScrollIndicator
        let originalShowsHorizontalScrollIndicator = scrollView.showsHorizontalScrollIndicator
        
        // 2. Configure for full content capture
        scrollView.clipsToBounds = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        // 3. Set scroll view to show all content
        let contentSize = scrollView.contentSize
        scrollView.contentOffset = .zero
        scrollView.bounds = CGRect(origin: .zero, size: contentSize)
        
        // 4. Force layout to ensure content is properly positioned
        scrollView.layoutIfNeeded()
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        
        // 5. Create image with full content size
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: contentSize, format: format)
        let image = renderer.image { context in
            scrollView.layer.render(in: context.cgContext)
        }
        
        // 6. Restore original state
        scrollView.bounds = originalBounds
        scrollView.frame = originalFrame
        scrollView.contentOffset = originalOffset
        scrollView.clipsToBounds = originalClipsToBounds
        scrollView.showsVerticalScrollIndicator = originalShowsVerticalScrollIndicator
        scrollView.showsHorizontalScrollIndicator = originalShowsHorizontalScrollIndicator
        
        // Force layout again to restore proper appearance
        scrollView.layoutIfNeeded()
        
        // 7. Return result
        if image.size.width > 0 && image.size.height > 0 {
            promise(.success(image))
        } else {
            promise(.failure(.generationFailed))
        }
    }
    
    /// Generates screenshot by capturing segments and combining them
    private func generateSegmentedScreenshot(from scrollView: UIScrollView, promise: @escaping (Result<UIImage, ScreenshotError>) -> Void) {
        // 1. Save original state
        let originalOffset = scrollView.contentOffset
        let originalBounds = scrollView.bounds
        let originalClipsToBounds = scrollView.clipsToBounds
        let originalShowsVerticalScrollIndicator = scrollView.showsVerticalScrollIndicator
        let originalShowsHorizontalScrollIndicator = scrollView.showsHorizontalScrollIndicator
        let originalBackgroundColor = scrollView.backgroundColor
        
        // 2. Configure scroll view for optimal capturing
        scrollView.clipsToBounds = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        // Ensure background color is set properly
        if scrollView.backgroundColor == nil || scrollView.backgroundColor == .clear {
            scrollView.backgroundColor = .white
        }
        
        let contentSize = scrollView.contentSize
        let frameSize = scrollView.bounds.size
        let scale = UIScreen.main.scale
        
        // 3. Calculate segments with proper overlap
        let segmentHeight = frameSize.height
        let totalHeight = contentSize.height
        let numberOfSegments = Int(ceil(totalHeight / segmentHeight))
        
        var images: [UIImage] = []
        
        // 4. Capture each segment synchronously
        for i in 0..<numberOfSegments {
            let yOffset = CGFloat(i) * segmentHeight
            let remainingHeight = totalHeight - yOffset
            let actualSegmentHeight = min(segmentHeight, remainingHeight)
            
            // Set scroll position and force layout
            scrollView.contentOffset = CGPoint(x: 0, y: yOffset)
            scrollView.setNeedsLayout()
            scrollView.layoutIfNeeded()
            
            // Force a display update to ensure content is rendered
            scrollView.setNeedsDisplay()
            scrollView.layer.displayIfNeeded()
            
            // Create the segment image
            let format = UIGraphicsImageRendererFormat()
            format.scale = scale
            format.opaque = true
            
            let segmentSize = CGSize(width: frameSize.width, height: actualSegmentHeight)
            let renderer = UIGraphicsImageRenderer(size: segmentSize, format: format)
            
            let segmentImage = renderer.image { context in
                // Set white background
                UIColor.white.setFill()
                context.fill(CGRect(origin: .zero, size: segmentSize))
                
                // Render only the visible content area
                context.cgContext.saveGState()
                
                // Clip to the segment area
                context.cgContext.clip(to: CGRect(origin: .zero, size: segmentSize))
                
                // Translate to show the correct portion
                context.cgContext.translateBy(x: 0, y: -yOffset)
                
                // Render the scroll view layer
                scrollView.layer.render(in: context.cgContext)
                
                context.cgContext.restoreGState()
            }
            
            images.append(segmentImage)
        }
        
        // 5. Restore original state
        scrollView.bounds = originalBounds
        scrollView.contentOffset = originalOffset
        scrollView.clipsToBounds = originalClipsToBounds
        scrollView.showsVerticalScrollIndicator = originalShowsVerticalScrollIndicator
        scrollView.showsHorizontalScrollIndicator = originalShowsHorizontalScrollIndicator
        scrollView.backgroundColor = originalBackgroundColor
        scrollView.layoutIfNeeded()
        
        // 6. Combine all segments
        self.combineSegmentedImages(images, contentSize: contentSize, scale: scale, promise: promise)
    }
    
    /// Combines segmented images into a single long screenshot
    private func combineSegmentedImages(_ images: [UIImage], contentSize: CGSize, scale: CGFloat, promise: @escaping (Result<UIImage, ScreenshotError>) -> Void) {
        let finalFormat = UIGraphicsImageRendererFormat()
        finalFormat.scale = scale
        finalFormat.opaque = true
        
        let finalSize = contentSize
        let finalRenderer = UIGraphicsImageRenderer(size: finalSize, format: finalFormat)
        
        let combinedImage = finalRenderer.image { context in
            // Fill with white background
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: finalSize))
            
            // Calculate segment height from actual content
            let segmentHeight = images.first?.size.height ?? 0
            
            // Draw segments sequentially without overlap for simplicity
            var currentY: CGFloat = 0
            
            for (index, segmentImage) in images.enumerated() {
                let isLastSegment = (index == images.count - 1)
                let drawHeight = isLastSegment ? min(segmentImage.size.height, finalSize.height - currentY) : segmentImage.size.height
                
                let drawRect = CGRect(
                    x: 0,
                    y: currentY,
                    width: min(segmentImage.size.width, finalSize.width),
                    height: drawHeight
                )
                
                // Only draw if there's space left
                if currentY < finalSize.height {
                    segmentImage.draw(in: drawRect)
                }
                
                currentY += segmentHeight
                
                // Stop if we've filled the final image
                if currentY >= finalSize.height {
                    break
                }
            }
        }
        
        // Return result
        if combinedImage.size.width > 0 && combinedImage.size.height > 0 {
            promise(.success(combinedImage))
        } else {
            promise(.failure(.generationFailed))
        }
    }
    
    func generate(from view: UIView) -> AnyPublisher<UIImage, ScreenshotError> {
        return Future<UIImage, ScreenshotError> { promise in
            DispatchQueue.main.async {
                guard view.window != nil else {
                    promise(.failure(.viewNotAvailable))
                    return
                }
                
                guard view.bounds.width > 0 && view.bounds.height > 0 else {
                    promise(.failure(.generationFailed))
                    return
                }
                
                let renderer = UIGraphicsImageRenderer(size: view.bounds.size, format: .default())
                let image = renderer.image { context in
                    view.layer.render(in: context.cgContext)
                }
                
                if image.size.width > 0 && image.size.height > 0 {
                    promise(.success(image))
                } else {
                    promise(.failure(.generationFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
