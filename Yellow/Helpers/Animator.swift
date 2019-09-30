//
//  Animator.swift
//  Yellow
//
//  Created by Lyle on 22/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

enum Animator {
    enum Duration {
        case zero, short, normal, long
        case variable(Double)
        
        var rawValue: Double {
            switch self {
            case .zero:
                return 0
            case .short:
                return 0.15
            case .normal:
                return 0.35
            case .long:
                return 0.55
            case .variable(let value):
                return max(0, value)
            }
        }
    }
    enum Damping {
        case low, medium, high
        case variable(CGFloat)
        
        var rawValue: CGFloat {
            switch self {
            case .low:
                return 0.72
            case .medium:
                return 0.85
            case .high:
                return 1
            case .variable(let value):
                return max(0, value)
            }
        }
    }
    enum Velocity {
        case low, medium, high
        case variable(CGFloat)
        
        var rawValue: CGFloat {
            switch self {
            case .low:
                return 0.65
            case .medium:
                return 0.85
            case .high:
                return 0.95
            case .variable(let value):
                return max(0, value)
            }
        }
    }
    
    struct View {
        private weak var view: UIView?
        init(view: UIView) {
            self.view = view
        }
        public func color(_ toColor: UIColor, duration: Duration = .normal, delay: Double = 0, curve: UIView.AnimationOptions = .curveEaseOut, completion: ((_ success: Bool) -> Void)? = nil) {
            UIView.animate(withDuration: duration.rawValue,
                           delay: delay,
                           options: curve,
                           animations: {
                            self.view?.backgroundColor = toColor
            },
                           completion: { finished in
                            completion?(finished)
            })
        }
        
        public func splash(withWhiteAlpha whiteAlpha: CGFloat = 0.4, duration: Duration = .long) {
            if #available(iOS 10.0, *) {
                guard let view = self.view else { return }
                let splashView = UIView(frame: view.bounds)
                splashView.backgroundColor = UIColor.white.withAlphaComponent(whiteAlpha)
                splashView.alpha = 0
                view.addSubview(splashView)
                let propertyAnimator = UIViewPropertyAnimator(duration: duration.rawValue, curve: .easeOut) {
                    splashView.alpha = 1
                }
                
                propertyAnimator.addAnimations({
                    splashView.alpha = 0
                }, delayFactor: 0.2)
                
                propertyAnimator.addCompletion({ position in
                    if position == .end {
                        splashView.removeFromSuperview()
                    }
                })
                propertyAnimator.startAnimation()
            }
        }
        
        public func custom(duration: Duration = .variable(0.45), delay: Double = 0, damping: Damping = .variable(0.95), velocity: Velocity = .variable(0.65), curve: UIView.AnimationOptions = .curveEaseInOut, animations:@escaping () -> Void, completion: ((_ success: Bool) -> Void)? = nil) {
            UIView.animate(withDuration: duration.rawValue, delay: delay, usingSpringWithDamping: damping.rawValue, initialSpringVelocity: velocity.rawValue, options: curve,
                           animations: {
                            animations()
            },
                           completion: { finished in
                            completion?(finished)
            })
        }

    }
}

extension UIView {
    var animator: Animator.View {
        return Animator.View(view: self)
    }
}
