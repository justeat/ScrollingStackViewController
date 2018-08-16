
extension UIViewController {
    func view(withEdgeInsets edgeInsets: UIEdgeInsets?) -> UIView {
        guard let edgeInsets = edgeInsets else { return view }
        return view.embedded(with: edgeInsets)
    }
    
    func add(_ child: UIViewController, addingView: Bool = true) {
        addChildViewController(child)
        if addingView {
            view.addSubview(child.view)
        }
        child.didMove(toParentViewController: self)
    }
    
    func removeAsChild(removingView: Bool = true) {
        guard parent != nil else {
            return
        }
        
        willMove(toParentViewController: nil)
        removeFromParentViewController()
        if removingView {
            view.removeFromSuperview()
        }
    }
}
