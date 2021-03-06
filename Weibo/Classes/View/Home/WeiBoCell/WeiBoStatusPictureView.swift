//
//  WeiBoStatusPictureView.swift
//  Weibo
//
//  Created by ityike on 2017/1/9.
//  Copyright © 2017年 袁 峰. All rights reserved.
//

import UIKit

class WeiBoStatusPictureView: UIView {
    
    var viewModel: WeiBoStatusViewModel? {
        didSet {
            calcViewSize()
            // 设置urls
            urls = viewModel?.picURLs
        }
    }
    
    // 根据视图模型的配图视图大小，调整显示内容
    private func calcViewSize() {
        // 处理宽度
        // 1 单图
        if viewModel?.picURLs?.count == 1 {
            // 获取图象
            let v = subviews[0]
            let viewSize = viewModel?.pictureViewSize ?? CGSize()
            v.frame = CGRect(x: 0,
                             y: WeiBoStatusPictureViewOutterMargin,
                             width: viewSize.width,
                             height: viewSize.height - WeiBoStatusPictureViewOutterMargin)
        } else {
            // 多图
            let v = subviews[0]
            v.frame = CGRect(x: 0,
                             y: WeiBoStatusPictureViewOutterMargin,
                             width: WeiBoStatusPictureItemWidth,
                             height: WeiBoStatusPictureItemWidth)
        }
        
        // 修改高度约束
        heightCons.constant = (viewModel?.pictureViewSize.height) ?? 0
    }
    
    private var urls: [WeiBoStatusPicture]? {
        didSet {
            // 隐藏所有的imageView
            for v in subviews {
                v.isHidden = true
            }
            // 遍历urls数组
            var index = 0
            for url in urls ?? [] {
                let iv = subviews[index] as! UIImageView
                // 4张图像的处理
                if index == 1 && urls?.count == 4 {
                    index += 1
                }
                
                // 设置图象
                iv.setImage(urlString: url.thumbnail_pic, placeholderImage: nil)
                
                // 是否是 gif
                iv.subviews[0].isHidden = (((url.thumbnail_pic ?? "") as NSString).pathExtension.lowercased() != "gif")
                
                // 显示图像
                iv.isHidden = false
                index += 1
            }
        }
    }

    @IBOutlet weak var heightCons: NSLayoutConstraint!
    

    override func awakeFromNib() {
        setupUI()
    }
    
    
    @objc func tapImageView(tap: UITapGestureRecognizer) {
        
        guard let iv = tap.view,
            let picURLs = viewModel?.picURLs else {
            return
        }
        var selectedIndex = iv.tag
        
        // 针对四张处理
        if picURLs.count == 4 && selectedIndex > 1 {
            selectedIndex -= 1
        }
        
        
        let urls = (picURLs as NSArray).value(forKey: "thumbnail_pic") as! [String]
        
        var imageViewList = [UIImageView]()
        for iv in subviews as! [UIImageView] {
            if iv.isHidden {
                imageViewList.append(iv)
            }
        }
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: WeiBoStatusCellBrowserPhotoNotification),
            object: self,
            userInfo: [
                WeiBoStatusCellBrowserPhotoURLsKey: urls,
                WeiBoStatusCellBrowserPhotoSelectedIndexKey: selectedIndex,
                WeiBoStatusCellBrowserPhotoImageViewsKey: imageViewList
            ])
    }
}


extension WeiBoStatusPictureView {
    // cell中的所有控件都是提前准备好的
    // 设置的时候，根据数组决定是否显示
    fileprivate func setupUI() {
        backgroundColor = superview?.backgroundColor
        // 超出便捷的内容不显示
        clipsToBounds = true
        
        let count = 3
        let rect = CGRect(x: 0, y: WeiBoStatusPictureViewOutterMargin, width: WeiBoStatusPictureItemWidth, height: WeiBoStatusPictureItemWidth)
        for i in 0..<count * count {
            let iv = UIImageView()
            // 设置 contentMode
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            
            // 行
            let row = CGFloat(i / count)
            // 列
            let col = CGFloat(i % count)
            let dx = col * (WeiBoStatusPictureItemWidth + WeiBoStatusPictureViewInnerMargin)
            let dy = row * (WeiBoStatusPictureItemWidth + WeiBoStatusPictureViewInnerMargin)
            iv.frame = rect.offsetBy(dx: dx, dy: dy)
            addSubview(iv)
            
            // 让imageView能够接受用户交互
            iv.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapImageView))
            iv.addGestureRecognizer(tap)
            // 设置imageView的tag
            iv.tag = i
            
            addGifView(iv: iv)
        }
    }
    
    private func addGifView(iv: UIImageView) {
        let gifImageView = UIImageView(image: UIImage(named: "timeline_image_gif"))
        iv.addSubview(gifImageView)
        
        // 自动布局
        gifImageView.translatesAutoresizingMaskIntoConstraints = false
        
        iv.addConstraint(NSLayoutConstraint(
            item: gifImageView,
            attribute: .right,
            relatedBy: .equal,
            toItem: iv,
            attribute: .right,
            multiplier: 1.0,
            constant: 0))
        iv.addConstraint(NSLayoutConstraint(
            item: gifImageView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: iv,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0))
    }
}










