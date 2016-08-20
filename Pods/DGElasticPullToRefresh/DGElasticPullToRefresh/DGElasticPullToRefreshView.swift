/*

The MIT License (MIT)

Copyright (c) 2015 Danil Gontovnik

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

import UIKit

// MARK: -
// MARK: DGElasticPullToRefreshState

public
enum DGElasticPullToRefreshState: Int {
    case stopped
    case dragging
    case animatingBounce
    case loading
    case animatingToStopped
    
    func isAnyOf(_ values: [DGElasticPullToRefreshState]) -> Bool {
        return values.contains({ $0 == self })
    }
}

// MARK: -
// MARK: DGElasticPullToRefreshView

public class DGElasticPullToRefreshView: UIView {
    
    // MARK: -
    // MARK: Vars
    
    private var _state: DGElasticPullToRefreshState = .stopped
    private(set) var state: DGElasticPullToRefreshState {
        get { return _state }
        set {
            let previousValue = state
            _state = newValue
            
            if previousValue == .dragging && newValue == .animatingBounce {
                loadingView?.startAnimating()
                animateBounce()
            } else if newValue == .loading && actionHandler != nil {
                actionHandler()
            } else if newValue == .animatingToStopped {
                resetScrollViewContentInset(shouldAddObserverWhenFinished: true, animated: true, completion: { [weak self] () -> () in self?.state = .stopped })
            } else if newValue == .stopped {
                loadingView?.stopLoading()
            }
        }
    }
    
    private var originalContentInsetTop: CGFloat = 0.0 { didSet { layoutSubviews() } }
    private let shapeLayer = CAShapeLayer()
    
    private var displayLink: CADisplayLink!
    
    var actionHandler: (() -> Void)!
    
    var loadingView: DGElasticPullToRefreshLoadingView? {
        willSet {
            loadingView?.removeFromSuperview()
            if let newValue = newValue {
                addSubview(newValue)
            }
        }
    }
    
    var observing: Bool = false {
        didSet {
            guard let scrollView = scrollView() else { return }
            if observing {
                scrollView.dg_addObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.ContentOffset)
                scrollView.dg_addObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.ContentInset)
                scrollView.dg_addObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.Frame)
                scrollView.dg_addObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.PanGestureRecognizerState)
            } else {
                scrollView.dg_removeObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.ContentOffset)
                scrollView.dg_removeObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.ContentInset)
                scrollView.dg_removeObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.Frame)
                scrollView.dg_removeObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.PanGestureRecognizerState)
            }
        }
    }
    
    var fillColor: UIColor = .clear() { didSet { shapeLayer.fillColor = fillColor.cgColor } }
    
    // MARK: Views
    
    private let bounceAnimationHelperView = UIView()
    
    private let cControlPointView = UIView()
    private let l1ControlPointView = UIView()
    private let l2ControlPointView = UIView()
    private let l3ControlPointView = UIView()
    private let r1ControlPointView = UIView()
    private let r2ControlPointView = UIView()
    private let r3ControlPointView = UIView()
    
    // MARK: -
    // MARK: Constructors
    
    init() {
        super.init(frame: CGRect.zero)
        
        displayLink = CADisplayLink(target: self, selector: Selector("displayLinkTick"))
        displayLink.add(to: RunLoop.main(), forMode: RunLoopMode.commonModes.rawValue)
        displayLink.isPaused = true
        
        shapeLayer.backgroundColor = UIColor.clear().cgColor
        shapeLayer.fillColor = UIColor.black().cgColor
        shapeLayer.actions = ["path" : NSNull(), "position" : NSNull(), "bounds" : NSNull()]
        layer.addSublayer(shapeLayer)
        
        addSubview(bounceAnimationHelperView)
        addSubview(cControlPointView)
        addSubview(l1ControlPointView)
        addSubview(l2ControlPointView)
        addSubview(l3ControlPointView)
        addSubview(r1ControlPointView)
        addSubview(r2ControlPointView)
        addSubview(r3ControlPointView)
        
        NotificationCenter.default().addObserver(self, selector: Selector("applicationWillEnterForeground"), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
    deinit {
        observing = false
        NotificationCenter.default().removeObserver(self)
    }

    // MARK: -
    // MARK: Observer
    
    override public func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<Void>?) {
        if keyPath == DGElasticPullToRefreshConstants.KeyPaths.ContentOffset {
            if let newContentOffsetY = change?[NSKeyValueChangeKey.newKey]?.cgPointValue.y, let scrollView = scrollView() {
                if state.isAnyOf([.loading, .animatingToStopped]) && newContentOffsetY < -scrollView.contentInset.top {
                    scrollView.dg_stopScrollingAnimation()
                    scrollView.contentOffset.y = -scrollView.contentInset.top
                } else {
                    scrollViewDidChangeContentOffset(dragging: scrollView.isDragging)
                }
                layoutSubviews()
            }
        } else if keyPath == DGElasticPullToRefreshConstants.KeyPaths.ContentInset {
            if let newContentInsetTop = change?[NSKeyValueChangeKey.newKey]?.uiEdgeInsetsValue().top {
                originalContentInsetTop = newContentInsetTop
            }
        } else if keyPath == DGElasticPullToRefreshConstants.KeyPaths.Frame {
            layoutSubviews()
        } else if keyPath == DGElasticPullToRefreshConstants.KeyPaths.PanGestureRecognizerState {
            if let gestureState = scrollView()?.panGestureRecognizer.state where gestureState.dg_isAnyOf([.ended, .cancelled, .failed]) {
                scrollViewDidChangeContentOffset(dragging: false)
            }
        }
    }
    
    // MARK: -
    // MARK: Notifications
    
    func applicationWillEnterForeground() {
        if state == .loading {
            layoutSubviews()
        }
    }
    
    // MARK: -
    // MARK: Methods (Public)
    
    private func scrollView() -> UIScrollView? {
        return superview as? UIScrollView
    }
    
    func stopLoading() {
        // Prevent stop close animation
        if state == .animatingToStopped {
            return
        }
        state = .animatingToStopped
    }
    
    // MARK: Methods (Private)
    
    private func isAnimating() -> Bool {
        return state.isAnyOf([.animatingBounce, .animatingToStopped])
    }
    
    private func actualContentOffsetY() -> CGFloat {
        guard let scrollView = scrollView() else { return 0.0 }
        return max(-scrollView.contentInset.top - scrollView.contentOffset.y, 0)
    }
    
    private func currentHeight() -> CGFloat {
        guard let scrollView = scrollView() else { return 0.0 }
        return max(-originalContentInsetTop - scrollView.contentOffset.y, 0)
    }
    
    private func currentWaveHeight() -> CGFloat {
        return min(bounds.height / 3.0 * 1.6, DGElasticPullToRefreshConstants.WaveMaxHeight)
    }
    
    private func currentPath() -> CGPath {
        let width: CGFloat = scrollView()?.bounds.width ?? 0.0
        
        let bezierPath = UIBezierPath()
        let animating = isAnimating()
        
        bezierPath.move(to: CGPoint(x: 0.0, y: 0.0))
        bezierPath.addLine(to: CGPoint(x: 0.0, y: l3ControlPointView.dg_center(animating).y))
        bezierPath.addCurve(to: l1ControlPointView.dg_center(animating), controlPoint1: l3ControlPointView.dg_center(animating), controlPoint2: l2ControlPointView.dg_center(animating))
        bezierPath.addCurve(to: r1ControlPointView.dg_center(animating), controlPoint1: cControlPointView.dg_center(animating), controlPoint2: r1ControlPointView.dg_center(animating))
        bezierPath.addCurve(to: r3ControlPointView.dg_center(animating), controlPoint1: r1ControlPointView.dg_center(animating), controlPoint2: r2ControlPointView.dg_center(animating))
        bezierPath.addLine(to: CGPoint(x: width, y: 0.0))
        
        bezierPath.close()
        
        return bezierPath.cgPath
    }
    
    private func scrollViewDidChangeContentOffset(dragging: Bool) {
        let offsetY = actualContentOffsetY()
        
        if state == .stopped && dragging {
            state = .dragging
        } else if state == .dragging && dragging == false {
            if offsetY >= DGElasticPullToRefreshConstants.MinOffsetToPull {
                state = .animatingBounce
                scrollView()?.dg_stopScrollingAnimation()
            } else {
                state = .stopped
            }
        } else if state.isAnyOf([.dragging, .stopped]) {
            let pullProgress: CGFloat = offsetY / DGElasticPullToRefreshConstants.MinOffsetToPull
            loadingView?.setPullProgress(pullProgress)
        }
    }
    
    private func resetScrollViewContentInset(shouldAddObserverWhenFinished: Bool, animated: Bool, completion: (() -> ())?) {
        guard let scrollView = scrollView() else { return }
        
        var contentInset = scrollView.contentInset
        contentInset.top = originalContentInsetTop
        
        if state == .animatingBounce {
            contentInset.top += currentHeight()
        } else if state == .loading {
            contentInset.top += DGElasticPullToRefreshConstants.LoadingContentInset
        }
        
        scrollView.dg_removeObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.ContentInset)
        
        let animationBlock = { scrollView.contentInset = contentInset }
        let completionBlock = { () -> Void in
            if shouldAddObserverWhenFinished {
                scrollView.dg_addObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.ContentInset)
            }
            completion?()
        }
        
        if animated {
            startDisplayLink()
            UIView.animate(withDuration: 0.4, animations: animationBlock, completion: { _ in
                self.stopDisplayLink()
                completionBlock()
            })
        } else {
            animationBlock()
            completionBlock()
        }
    }
    
    private func animateBounce() {
        guard let scrollView = scrollView() else { return }
        
        resetScrollViewContentInset(shouldAddObserverWhenFinished: false, animated: false, completion: nil)
        
        let centerY = DGElasticPullToRefreshConstants.LoadingContentInset
        let duration = 0.9
        
        scrollView.isScrollEnabled = false
        startDisplayLink()
        scrollView.dg_removeObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.ContentOffset)
        scrollView.dg_removeObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.ContentInset)
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.43, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
            self.cControlPointView.center.y = centerY
            self.l1ControlPointView.center.y = centerY
            self.l2ControlPointView.center.y = centerY
            self.l3ControlPointView.center.y = centerY
            self.r1ControlPointView.center.y = centerY
            self.r2ControlPointView.center.y = centerY
            self.r3ControlPointView.center.y = centerY
            }, completion: { _ in
                self.stopDisplayLink()
                self.resetScrollViewContentInset(shouldAddObserverWhenFinished: true, animated: false, completion: nil)
                scrollView.dg_addObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.ContentOffset)
                scrollView.isScrollEnabled = true
                self.state = .loading
        })
        
        bounceAnimationHelperView.center = CGPoint(x: 0.0, y: originalContentInsetTop + currentHeight())
        UIView.animate(withDuration: duration * 0.4, animations: { () -> Void in
            self.bounceAnimationHelperView.center = CGPoint(x: 0.0, y: self.originalContentInsetTop + DGElasticPullToRefreshConstants.LoadingContentInset)
            }, completion: nil)
    }
    
    // MARK: -
    // MARK: CADisplayLink
    
    private func startDisplayLink() {
        displayLink.isPaused = false
    }
    
    private func stopDisplayLink() {
        displayLink.isPaused = true
    }
    
    func displayLinkTick() {
        let width = bounds.width
        var height: CGFloat = 0.0
        
        if state == .animatingBounce {
            guard let scrollView = scrollView() else { return }
        
            scrollView.contentInset.top = bounceAnimationHelperView.dg_center(isAnimating()).y
            scrollView.contentOffset.y = -scrollView.contentInset.top
            
            height = scrollView.contentInset.top - originalContentInsetTop
            
            frame = CGRect(x: 0.0, y: -height - 1.0, width: width, height: height)
        } else if state == .animatingToStopped {
            height = actualContentOffsetY()
        }
    
        shapeLayer.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        shapeLayer.path = currentPath()
        
        layoutLoadingView()
    }
    
    // MARK: -
    // MARK: Layout
    
    private func layoutLoadingView() {
        let width = bounds.width
        let height: CGFloat = bounds.height
        
        let loadingViewSize: CGFloat = DGElasticPullToRefreshConstants.LoadingViewSize
        let minOriginY = (DGElasticPullToRefreshConstants.LoadingContentInset - loadingViewSize) / 2.0
        let originY: CGFloat = max(min((height - loadingViewSize) / 2.0, minOriginY), 0.0)
        
        loadingView?.frame = CGRect(x: (width - loadingViewSize) / 2.0, y: originY, width: loadingViewSize, height: loadingViewSize)
        loadingView?.maskLayer.frame = convert(shapeLayer.frame, to: loadingView)
        loadingView?.maskLayer.path = shapeLayer.path
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if let scrollView = scrollView() where state != .animatingBounce {
            let width = scrollView.bounds.width
            let height = currentHeight()
            
            frame = CGRect(x: 0.0, y: -height, width: width, height: height)
            
            if state.isAnyOf([.loading, .animatingToStopped]) {
                cControlPointView.center = CGPoint(x: width / 2.0, y: height)
                l1ControlPointView.center = CGPoint(x: 0.0, y: height)
                l2ControlPointView.center = CGPoint(x: 0.0, y: height)
                l3ControlPointView.center = CGPoint(x: 0.0, y: height)
                r1ControlPointView.center = CGPoint(x: width, y: height)
                r2ControlPointView.center = CGPoint(x: width, y: height)
                r3ControlPointView.center = CGPoint(x: width, y: height)
            } else {
                let locationX = scrollView.panGestureRecognizer.location(in: scrollView).x
                
                let waveHeight = currentWaveHeight()
                let baseHeight = bounds.height - waveHeight
                
                let minLeftX = min((locationX - width / 2.0) * 0.28, 0.0)
                let maxRightX = max(width + (locationX - width / 2.0) * 0.28, width)
                
                let leftPartWidth = locationX - minLeftX
                let rightPartWidth = maxRightX - locationX
                
                cControlPointView.center = CGPoint(x: locationX , y: baseHeight + waveHeight * 1.36)
                l1ControlPointView.center = CGPoint(x: minLeftX + leftPartWidth * 0.71, y: baseHeight + waveHeight * 0.64)
                l2ControlPointView.center = CGPoint(x: minLeftX + leftPartWidth * 0.44, y: baseHeight)
                l3ControlPointView.center = CGPoint(x: minLeftX, y: baseHeight)
                r1ControlPointView.center = CGPoint(x: maxRightX - rightPartWidth * 0.71, y: baseHeight + waveHeight * 0.64)
                r2ControlPointView.center = CGPoint(x: maxRightX - (rightPartWidth * 0.44), y: baseHeight)
                r3ControlPointView.center = CGPoint(x: maxRightX, y: baseHeight)
            }
            
            shapeLayer.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            shapeLayer.path = currentPath()
            
            layoutLoadingView()
        }
    }
    
}