
extension Array where Element: NSLayoutConstraint {
    public func activate() {
        NSLayoutConstraint.activate(self)
    }
}

extension UIScrollView {
    var maxOffsetY: CGFloat {
        return contentSize.height - frame.size.height
    }
}

extension UIView {
    
    public func embedded(with edgetInsets: UIEdgeInsets) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(self)
        
        let constraints = [
            self.topAnchor.constraint(equalTo: containerView.topAnchor, constant: edgetInsets.top),
            self.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: edgetInsets.left),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: edgetInsets.bottom),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: edgetInsets.right),
            ].activate()
    
        return containerView
    }
}
