//
//  AirbnbPresentationController.swift
//  AirbnbDatePicker
//
//  Created by mrfour on 2018/4/14.
//

import UIKit

public class AirbnbPresentationController: UIPresentationController {

    // MARK: - Views

    lazy var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    var presentationWrappingView: UIView?

    // MARK: - Overrides

    public override var presentedView: UIView? {
        return presentationWrappingView
    }

    public override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        presentedViewController.modalPresentationStyle = .custom
        presentedViewController.modalPresentationCapturesStatusBarAppearance = true
    }

    public override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)

        guard let container = container as? UIViewController, container == presentedViewController else { return }
        containerView?.setNeedsLayout()
        UIView.animate(withDuration: Const.transitionDuration, delay: 0, options: [.curveEaseOut], animations: { [weak self] in
            self?.containerView?.layoutIfNeeded()
            }, completion: nil)
    }

    public override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        let horizontalPadding: CGFloat = 16

        var size = parentSize
        size.width -= horizontalPadding*2
        size.height = size.height * 2 / 3

        return size
    }

    public override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero}

        let containerViewBounds = containerView.bounds
        let presentedViewContentSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerViewBounds.size)

        // The presented view extends presentedViewContentSize.height points from the bottom edge of the screen.
        var presentedViewControllerFrame = containerViewBounds
        presentedViewControllerFrame.size.height = presentedViewContentSize.height
        presentedViewControllerFrame.size.width = presentedViewContentSize.width
        presentedViewControllerFrame.origin.y = (containerViewBounds.maxY - presentedViewContentSize.height) / 2
        presentedViewControllerFrame.origin.x = (containerViewBounds.maxX - presentedViewContentSize.width) / 2

        return presentedViewControllerFrame
    }

    public override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()

        blurView.frame = containerView!.bounds
        presentationWrappingView?.frame = frameOfPresentedViewInContainerView
    }

    public override func presentationTransitionWillBegin() {
        preparePresentationWrappingView()
        prepareBlurView()

        let transitionCoordinator = presentingViewController.transitionCoordinator
        self.blurView.alpha = 0

        transitionCoordinator?.animate(alongsideTransition: { _ in
            self.blurView.alpha = 1
        })
    }

    public override func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else { return }
        transitionCoordinator.animate(alongsideTransition: { [weak self] _ in
            self?.blurView.alpha = 0
        })
    }

    public override func presentationTransitionDidEnd(_ completed: Bool) {
        // The system removes the presented view controller's view from its
        // superview and disposes of the containerView.  This implicitly
        // removes the views created in -presentationTransitionWillBegin: from
        // the view hierarchy. However, we still need to relinquish our strong
        // references to those view.
        guard !completed else { return }
        presentationWrappingView = nil
    }
}

// MARK: - Prepare views

fileprivate extension AirbnbPresentationController {
    func prepareBlurView() {
        guard let containerView = containerView else { return }

        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(blurViewTapped)))

        containerView.addSubview(blurView)
    }

    // Wrap the presented view controller's view in an intermediate hierarchy
    // that applies a shadow and rounded corners to the top-left and top-right
    // edges.  The final effect is built using three intermediate views.
    //
    // presentationWrapperView <- shadow
    //   |- presentationRoundedCornerView   <- rounded corners (masksToBounds)
    //        |- presentedViewControllerWrapperView
    //             |- presentedViewControllerView (presentedViewController.view)
    //
    func preparePresentationWrappingView() {
        guard let presentedViewControllerView = super.presentedView else { return }

        let presentationWrapperView = UIView(frame: frameOfPresentedViewInContainerView)
        presentationWrappingView = presentationWrapperView
        presentationWrapperView.layer.shadowColor = UIColor.black.cgColor
        presentationWrapperView.layer.shadowOffset = CGSize(width: 0, height: 4)
        presentationWrapperView.layer.shadowOpacity = 0.2
        presentationWrapperView.layer.shadowRadius = 6

        // presentationRoundedCornerView is CORNER_RADIUS points taller than the
        // height of the presented view controller's view.  This is because
        // the cornerRadius is applied to all corners of the view.  Since the
        // effect calls for only the top two corners to be rounded we size
        // the view such that the bottom CORNER_RADIUS points lie below
        // the bottom edge of the screen.
        let presentationRoundedCornerView = UIView(frame: presentationWrapperView.bounds)
        presentationRoundedCornerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentationRoundedCornerView.layer.cornerRadius = 4
        presentationRoundedCornerView.clipsToBounds = true

        // To undo the extra height added to presentationRoundedCornerView,
        // presentedViewControllerWrapperView is inset by CORNER_RADIUS points.
        // This also matches the size of presentedViewControllerWrapperView's
        // bounds to the size of -frameOfPresentedViewInContainerView.
        let presentedViewControllerWrapperView = UIView(frame: presentationRoundedCornerView.bounds)
        presentedViewControllerWrapperView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Add presentedViewControllerView -> presentedViewControllerWrapperView.
        presentedViewControllerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentedViewControllerView.frame = presentedViewControllerWrapperView.bounds
        presentedViewControllerWrapperView.addSubview(presentedViewControllerView)

        // Add presentedViewControllerWrapperView -> presentationRoundedCornerView.
        presentationRoundedCornerView.addSubview(presentedViewControllerWrapperView)

        // Add presentationRoundedCornerView -> presentationWrapperView.
        presentationWrapperView.addSubview(presentationRoundedCornerView)
    }
}

// MARK: - Selectors

fileprivate extension AirbnbPresentationController {
    @objc func blurViewTapped(_ blurView: UIView) {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension AirbnbPresentationController: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Double(UINavigationControllerHideShowBarDuration)
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to), let fromVC = transitionContext.viewController(forKey: .from)  else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }

        // If `false` is returned from -shouldRemovePresentersView, the view associated
        // with UITransitionContextViewKey.from is nil during presentation.  This
        // intended to be a hint that your animator should NOT be manipulating the
        // presenting view controller's view.  For a dismissal, the -presentedView
        // is returned.
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)

        let isPresenting = presentingViewController == fromVC
        let containerView = transitionContext.containerView

        if isPresenting {
            containerView.addSubview(toView!)
            toView?.frame = transitionContext.finalFrame(for: toVC)
            toView?.alpha = 0
            toView?.transform = CGAffineTransform(translationX: 0, y: 10)
        } else {

        }

        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: [isPresenting ? .curveEaseOut : .curveEaseIn], animations: {
            if isPresenting {
                toView?.alpha = 1
                toView?.transform = .identity
            } else {
                fromView?.alpha = 0
                fromView?.transform = CGAffineTransform(translationX: 0, y: 10)
            }
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

// MARK: -

extension AirbnbPresentationController: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        assert(presentedViewController == presented, String(format: "You didn't initialize %@ with the correct presentedViewController.  Expected %@, got %@.", String(describing: self), presented, presentedViewController))
        return self
    }

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}
