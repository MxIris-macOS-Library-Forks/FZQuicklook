import AppKit


internal extension NSView {
    enum ConstraintValueMode {
        case relative
        case absolute
        case full
        case insets(NSEdgeInsets)
    }

    @discardableResult
    func addSubview(withConstraint view: NSView) -> [NSLayoutConstraint] {
        return addSubview(withConstraint: view, .full)
    }

    @discardableResult
    func addSubview(withConstraint view: NSView, _ mode: ConstraintValueMode) -> [NSLayoutConstraint] {
        addSubview(view)
        return view.constraint(to: self, mode)
    }

    @discardableResult
    func insertSubview(withConstraint view: NSView, at index: Int) -> [NSLayoutConstraint] {
        return insertSubview(withConstraint: view, .full, at: index)
    }

    @discardableResult
    func insertSubview(withConstraint view: NSView, _ mode: ConstraintValueMode, at index: Int) -> [NSLayoutConstraint] {
        guard index < subviews.count else { return [] }
        insertSubview(view, at: index)
        return view.constraint(to: self, mode)
    }
    
    func insertSubview(_ view: NSView, at index: Int) {
        guard index < self.subviews.count else { return }
        var subviews = self.subviews
        subviews.insert(view, at: index)
        self.subviews = subviews
    }

    @discardableResult
    func constraint(to view: NSView, _ mode: ConstraintValueMode = .full) -> [NSLayoutConstraint] {
        let constants: [CGFloat]
        switch mode {
        case .absolute:
            constants = calculateConstants(view)
        case let .insets(insets):
            constants = [insets.left, insets.bottom, 0.0 - insets.right, 0.0 - insets.top]
        default:
            constants = [0, 0, 0, 0]
        }
        let multipliers: [CGFloat]
        switch mode {
        case .relative: multipliers = calculateMultipliers(self)
        default: multipliers = [1.0, 1.0, 1.0, 1.0]
        }

        switch mode {
        case .full: frame = view.bounds
        default: break
        }

        translatesAutoresizingMaskIntoConstraints = false
        let left: NSLayoutConstraint = .init(item: self, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: multipliers[0], constant: constants[0])
        let bottom: NSLayoutConstraint = .init(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: multipliers[1], constant: constants[1])
        let width: NSLayoutConstraint = .init(item: self, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: multipliers[2], constant: constants[2])
        let height: NSLayoutConstraint = .init(item: self, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: multipliers[3], constant: constants[3])
        let constraints = [left, bottom, width, height]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    #if os(macOS)
    func addSubview(withAutoresizing view: NSView) {
        addSubview(withAutoresizing: view, mode: .full)
    }

    func addSubview(withAutoresizing view: NSView, mode: ConstraintValueMode) {
        view.translatesAutoresizingMaskIntoConstraints = true
        addSubview(view)
        view.autoresize(to: view, using: mode)
    }

    func insertSubview(withAutoresizing view: NSView, _ mode: ConstraintValueMode, to index: Int) {
        guard index < subviews.count else { return }
        addSubview(withAutoresizing: view, mode: mode)
        moveSubview(view, to: index)
    }
    
    func moveSubview(_ view: NSView, to toIndex: Int) {
        if let index = subviews.firstIndex(of: view) {
            moveSubview(at: index, to: toIndex)
        }
    }
    
    func moveSubview(at index: Int, to toIndex: Int) {
        moveSubviews(at: IndexSet(integer: index), to: toIndex)
    }
    
    func moveSubviews(at indexes: IndexSet, to toIndex: Int, reorder: Bool = false) {
        let subviewsCount = subviews.count
        if subviews.isEmpty == false {
            if toIndex >= 0, toIndex < subviewsCount {
                let indexes = IndexSet(Array(indexes).filter { $0 < subviewsCount })
                var subviews = self.subviews
                if reorder {
                    for index in indexes.reversed() {
                        subviews.move(from: IndexSet(integer: index), to: toIndex)
                    }
                } else {
                    subviews.move(from: indexes, to: toIndex)
                }
                self.subviews = subviews
            }
        }
    }

    func autoresize(to view: NSView, using mode: ConstraintValueMode) {
        translatesAutoresizingMaskIntoConstraints = true
        switch mode {
        case .full:
            frame = view.bounds
        case let .insets(insets):
            let width = insets.right - insets.left
            let height = insets.top - insets.bottom
            frame = CGRect(x: insets.bottom, y: insets.left, width: width, height: height)
        default:
            break
        }

        if case .relative = mode {
            self.autoresizingMask = [.height, .width]
        } else {
            autoresizingMask = [.width, .height, .minXMargin, .minYMargin, .maxXMargin, .maxYMargin]
        }
    }
    #endif

    func calculateMultipliers(_ view: NSView) -> [CGFloat] {
        let x = view.frame.x / bounds.width
        let y = view.frame.y / bounds.height
        let width = view.frame.width / bounds.width
        let height = view.frame.height / bounds.height
        return [x, y, width, height]
    }

    func calculateConstants(_ view: NSView) -> [CGFloat] {
        let x = view.frame.minX
        let y = -view.frame.minY
        let width = view.frame.width - bounds.width
        let height = view.frame.height - bounds.height
        return [x, y, width, height]
    }
}
