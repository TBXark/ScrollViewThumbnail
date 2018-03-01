//
//  ScrollViewThumbnailView.swift
//  ScrollViewThumbnailView
//
//  Created by Tbxark on 01/03/2018.
//  Copyright © 2018 Tbxark. All rights reserved.
//

import UIKit


@IBDesignable public class ScrollViewThumbnailView: UIView {
    
    @IBInspectable public var autoHide: Bool = true {
        didSet {
            updateTimer()
        }
    }
    @IBInspectable public var autoHideZoomScale: CGFloat = 1
    @IBInspectable public var autoHideDuration: TimeInterval = 2
    @IBInspectable public var fadeAnimationDuration: TimeInterval = 1
    
    public let backView = UIView()
    public let controlView = UIView()

    private var scrollView: UIScrollView?
    private var autoHideTimer: Timer?
    private var isAnimation = (status: false, nextVisable: false)
    private var observers: (offset: NSKeyValueObservation?, zoom: NSKeyValueObservation?)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        shareInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shareInit()
    }
    
    deinit {
        observers.offset?.invalidate()
        observers.zoom?.invalidate()
        autoHideTimer?.invalidate()
    }
    
    private func shareInit() {
        addSubview(backView)
        addSubview(controlView)
        
        backView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backView.layer.borderColor = UIColor.black.cgColor
        backView.layer.borderWidth = 1
        controlView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        controlView.layer.borderColor = UIColor.white.cgColor
        controlView.layer.borderWidth = 1
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ScrollViewThumbnailView.handlePanGesc(_:)))
        controlView.addGestureRecognizer(pan)
        
        isUserInteractionEnabled = true
        controlView.isUserInteractionEnabled = true
    }
    
    
    public func bindScrollView(_ sv: UIScrollView) {
        scrollView = sv
        observers.offset = sv.observe(\.contentOffset, changeHandler: {[weak self] view, value in
            self?.updateScrollViewStatus()
        })
        observers.zoom = sv.observe(\.zoomScale, changeHandler: {[weak self] view, value in
            self?.updateScrollViewStatus()
        })
        updateScrollViewStatus()
    }
    
    

    
    @objc public func updateScrollViewStatus() {
        
        guard let sv = scrollView,
            let zView = sv.delegate?.viewForZooming?(in: sv),
            let spView = sv.superview else { return }
        
        
        let size = zView.frame.size
        let startPoint = spView.convert(CGPoint.zero, to: sv)
        let endPoint = spView.convert(CGPoint(x: spView.frame.width, y: spView.frame.height), to: sv)
        
        // Magic code 
        var w = min((endPoint.x - startPoint.x) / size.width * bounds.width, bounds.width)
        var h = min((endPoint.y - startPoint.y) / size.height * bounds.height, bounds.height)
        var x = startPoint.x / size.width * bounds.width
        var y = startPoint.y / size.height * bounds.height
        w = x < 0 ? w + x : (x + w > bounds.width  ? bounds.width - x : w)
        h = y < 0 ? h + y : (y + h > bounds.height  ? bounds.height - y : h)
        x = min(max(0, x), bounds.width)
        y = min(max(0, y), bounds.height)
        
        backView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.width / zView.frame.width * zView.frame.height)
        controlView.frame = CGRect(x: x, y: y, width: w, height: h)
        changeThumbnailVisable(sv.zoomScale > autoHideZoomScale, animation: true)
        
        updateTimer()
    }
    
    
    
    private func updateTimer() {
        guard autoHide else {
            autoHideTimer?.invalidate()
            autoHideTimer = nil
            return
        }
        if let t = autoHideTimer {
            t.fireDate = Date(timeIntervalSinceNow: autoHideDuration)
        } else {
            autoHideTimer = Timer.scheduledTimer(timeInterval: autoHideDuration,
                                                 target: self,
                                                 selector: #selector(ScrollViewThumbnailView.handleAutoHideTimer(_:)),
                                                 userInfo: nil,
                                                 repeats: false)
        }
    }
    
    
    private func changeThumbnailVisable(_ visable: Bool, animation: Bool) {
        if animation {
            // Check
            if isAnimation.status, isAnimation.nextVisable == visable {
                return
            }
            isAnimation = (true, visable)
            if visable {
                if isHidden {
                    alpha = 0
                    isHidden = false
                }
                UIView.animate(withDuration: fadeAnimationDuration, animations: {
                    self.alpha = 1
                }, completion: { _ in
                    self.isAnimation.status = false
                })
            } else {
                if isHidden {
                    alpha = 0
                } else {
                    UIView.animate(withDuration: fadeAnimationDuration, animations: {
                        self.alpha = 0
                    }, completion: { _ in
                        self.isHidden = true
                        self.isAnimation.status = false
                    })
                }
            }
        } else {
            isAnimation = (false, visable)
            if visable {
                isHidden = false
                alpha = 1
            } else {
                isHidden = true
                alpha = 0
            }
        }
    }
    
    @objc private func handleAutoHideTimer(_ timer: Timer) {
        changeThumbnailVisable(false, animation: true)
        autoHideTimer?.invalidate()
        autoHideTimer = nil
    }
    
    @objc private func handlePanGesc(_ pan: UIPanGestureRecognizer) {
        
        guard let sv = scrollView else { return }
        
        // Cache value
        var offset = controlView.frame.origin
        let point = pan.translation(in: controlView)
        
        do {
            // Update controlView position
            var newCenter = CGPoint(x: controlView.center.x + point.x, y: controlView.center.y + point.y)
            newCenter.x = min(bounds.width - controlView.bounds.width/2, max(controlView.bounds.width/2, newCenter.x))
            newCenter.y = min(bounds.height - controlView.bounds.height/2, max(controlView.bounds.height/2, newCenter.y))
            controlView.center =  newCenter
        }
        
        
        do {
            // Update scrollview offset
            offset = CGPoint(x: controlView.frame.origin.x - offset.x ,
                             y: controlView.frame.origin.y - offset.y )
            pan.setTranslation(CGPoint.zero, in: controlView)
            
            let scale = controlView.bounds.width / sv.bounds.width
            offset = CGPoint(x: offset.x / scale + sv.contentOffset.x,
                             y: offset.y / scale + sv.contentOffset.y)
            
            
            sv.contentOffset = offset
        }
        
        do {
            // Update Timer
            updateTimer()
        }
    }
    
}
