//
//  AlertBar.swift
//
//  Created by Jin Sasaki on 2016/01/01.
//  Copyright © 2016年 Jin Sasaki. All rights reserved.
//

import UIKit

public enum AlertBarType {
    case success
    case error
    case notice
    case warning
    case info
    case custom(UIColor, UIColor)
    
    var backgroundColor: UIColor {
        switch self {
        case .success: return UIColor(0x4CAF50)
        case .error: return UIColor(0xf44336)
        case .notice: return UIColor(0x2196F3)
        case .warning: return UIColor(0xFFC107)
        case .info: return UIColor(0x009688)
        case .custom(let backgroundColor, _): return backgroundColor
        }
    }
    var textColor: UIColor {
        switch self {
        case .custom(_, let textColor): return textColor
        default: return UIColor(0xFFFFFF)
        }
    }
}

public final class AlertBar {
    public static let shared = AlertBar()
    private static let kWindowLevel: CGFloat = UIWindow.Level.statusBar.rawValue + 1
    private var alertBarViews: [AlertBarView] = []
    private var options = Options(shouldConsiderSafeArea: true, isStretchable: false, textAlignment: .left)
    
    public struct Options {
        let shouldConsiderSafeArea: Bool
        let isStretchable: Bool
        let textAlignment: NSTextAlignment
        
        public init(
            shouldConsiderSafeArea: Bool = true,
            isStretchable: Bool = false,
            textAlignment: NSTextAlignment = .left) {
            
            self.shouldConsiderSafeArea = shouldConsiderSafeArea
            self.isStretchable = isStretchable
            self.textAlignment = textAlignment
        }
    }
    
    public func setDefault(options: Options) {
        self.options = options
    }
    
    public func show(type: AlertBarType, message: String, duration: TimeInterval = 2, options: Options? = nil, completion: (() -> Void)? = nil) {
        // Hide all before new one is shown.
        alertBarViews.forEach({ $0.hide() })
        
        let currentOptions = options ?? self.options
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        let baseView = UIView(frame: UIScreen.main.bounds)
        let window: UIWindow
        let orientation = UIApplication.shared.statusBarOrientation
        let userInterfaceIdiom = UIDevice.current.userInterfaceIdiom
        if orientation.isLandscape {
            window = UIWindow(frame: CGRect(x: 0, y: 0, width: height, height: width))
            if userInterfaceIdiom == .phone {
                let sign: CGFloat = orientation == .landscapeLeft ? -1 : 1
                let d = abs(width - height) / 2
                baseView.transform = CGAffineTransform(rotationAngle: sign * CGFloat.pi / 2).translatedBy(x: sign * d, y: sign * d)
            }
        } else {
            window = UIWindow(frame: CGRect(x: 0, y: 0, width: width, height: height))
            if userInterfaceIdiom == .phone && orientation == .portraitUpsideDown {
                baseView.transform = CGAffineTransform(rotationAngle: .pi)
            }
        }
        //self.alertBarViews
        window.isUserInteractionEnabled = true
        window.windowLevel = UIWindow.Level(rawValue: AlertBar.kWindowLevel)
        window.makeKeyAndVisible()
        baseView.isUserInteractionEnabled = true
        window.addSubview(baseView)
        
        let safeArea: UIEdgeInsets
        if #available(iOS 11.0, *) {
            safeArea = window.safeAreaInsets
        } else {
            safeArea = .zero
        }
        let alertBarView = AlertBarView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0))
        alertBarView.delegate = self
        alertBarView.backgroundColor = type.backgroundColor
        alertBarView.messageLabel.textColor = type.textColor
        alertBarView.messageLabel.text = """
        \n\(message)\n
        """
        alertBarView.messageLabel.numberOfLines = 0
        alertBarView.messageLabel.textAlignment = .center
        alertBarView.fit(safeArea: currentOptions.shouldConsiderSafeArea ? safeArea : .zero)
        alertBarViews.append(alertBarView)
        
        window.frame.size.height = alertBarView.frame.height + 50
        baseView.frame.size.height = window.frame.size.height
        
        
        let scale = true
        alertBarView.layer.masksToBounds = false
        alertBarView.layer.shadowColor = UIColor.darkGray.cgColor
        alertBarView.layer.shadowOpacity = 0.25
        alertBarView.layer.shadowOffset = CGSize(width: 1, height: 3)
        alertBarView.layer.shadowRadius = 1
        
        //alertBarView.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        alertBarView.layer.shouldRasterize = true
        alertBarView.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        
        baseView.addSubview(alertBarView)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(windowTapped(tapGestureRecognizer:)))
        window.addGestureRecognizer(tapGestureRecognizer)
        
        
        let statusBarHeight: CGFloat = max(UIApplication.shared.statusBarFrame.height, safeArea.top)
        let alertBarHeight: CGFloat = max(statusBarHeight, alertBarView.frame.height)
        alertBarView.show(duration: 2, translationY: -alertBarHeight) {
            if let index = self.alertBarViews.index(of: alertBarView) {
                self.alertBarViews.remove(at: index)
            }
            // To hold window instance
            window.isHidden = true
            completion?()
        }
    }
    
    @objc func windowTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
            alertBarViews.forEach({ $0.hide() })
    }
    public func show(error: Error, duration: TimeInterval = 2, options: Options? = nil, completion: (() -> Void)? = nil) {
        let code = (error as NSError).code
        let localizedDescription = error.localizedDescription
        show(type: .error, message: "(\(code)) \(localizedDescription)", duration: duration, options: options, completion: completion)
    }
}

extension AlertBar: AlertBarViewDelegate {
    func alertBarViewHandleRotate(_ alertBarView: AlertBarView) {
        alertBarView.removeFromSuperview()
        alertBarViews.forEach({ $0.hide() })
        alertBarViews = []
    }
}

// MARK: - Static helpers

public extension AlertBar {
    public static func setDefault(options: Options) {
        shared.options = options
    }
    
    public static func show(type: AlertBarType, message: String, duration: TimeInterval = 2, options: Options? = nil, completion: (() -> Void)? = nil) {
        shared.show(type: type, message: message, duration: duration, options: options, completion: completion)
    }
    
    public static func show(error: Error, duration: TimeInterval = 2, options: Options? = nil, completion: (() -> Void)? = nil) {
        shared.show(error: error, duration: duration, options: options, completion: completion)
    }
}

protocol AlertBarViewDelegate: class {
    func alertBarViewHandleRotate(_ alertBarView: AlertBarView)
}

internal class AlertBarView: UIView {
    internal let messageLabel = UILabel()
    internal weak var delegate: AlertBarViewDelegate?
    
    private enum State {
        case showing
        case shown
        case hiding
        case hidden
    }
    
    private static let kMargin: CGFloat = 2
    private static let kAnimationDuration: TimeInterval = 0.2
    
    private var translationY: CGFloat = 0
    private var completion: (() -> Void)?
    private var state: State = .hidden
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame.origin.y = 40
        self.frame.origin.x = 20
        self.frame.size.width = self.frame.size.width - 40
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(alertTapped(tapGestureRecognizer:)))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGestureRecognizer)
        
        let margin = AlertBarView.kMargin
        messageLabel.frame = CGRect(x: margin, y: margin, width: frame.width - margin*2, height: frame.height - margin*2)
        messageLabel.font = UIFont.systemFont(ofSize: 15)
        addSubview(messageLabel)
        self.layer.cornerRadius = 20
        //self.clipsToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleRotate(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    @objc func alertTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.hide()
        // Your action
    }
    func fit(safeArea: UIEdgeInsets) {
        _ = AlertBarView.kMargin
        messageLabel.sizeToFit()
        messageLabel.frame.origin.x = 0
        messageLabel.frame.origin.y = 0
        messageLabel.frame.size.width = frame.size.width
        frame.size.height = messageLabel.frame.origin.y + messageLabel.frame.height
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func show(duration: TimeInterval, translationY: CGFloat, completion: (() -> Void)?) {
        self.state = .showing
        self.translationY = translationY
        self.completion = completion
        
        transform = CGAffineTransform(translationX: 0, y: translationY)
        UIView.animate(
            withDuration: AlertBarView.kAnimationDuration,
            animations: { () -> Void in
                self.transform = .identity
        }, completion: { _ in
            self.state = .shown
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(duration))) {
                self.hide()
            }
        })
    }
    
    func hide() {
        guard state == .showing || state == .shown else {
            return
        }
        self.state = .hiding
        // Hide animation
        UIView.animate(
            withDuration: AlertBarView.kAnimationDuration,
            animations: { () -> Void in
                self.transform = CGAffineTransform(translationX: 0, y: self.translationY)
        },
            completion: { (animated: Bool) -> Void in
                self.removeFromSuperview()
                self.state = .hidden
                self.completion?()
                self.completion = nil
        })
    }
    
    @objc private func handleRotate(_ notification: Notification) {
        delegate?.alertBarViewHandleRotate(self)
    }
}

internal extension UIColor {
    convenience init(_ rgbValue: UInt) {
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

