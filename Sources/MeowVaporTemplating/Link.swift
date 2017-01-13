/**
    A link in a chain. Used for link list
*/
public final class Link<Value> { // TODO: Rename Context
    /**
        The immediate parent of this link. `nil` if current branch is tip
    */
    public private(set) weak var parent: Link?

    /**
        The child of this link, `nil` if tail
    */
    public private(set) var child: Link?

    /**
        Underlying Value associated with link
    */
    public let value: Value

    /**
        Create a new link
    */
    public required init(_ output: Value) {
        self.value = output
    }

    /**
        Add a new Link to the end of the chain.
    */
    public func extend(_ output: Value) {
        let tail = self.tail()
        let new = Link(output)
        new.parent = tail
        tail.child = new
    }

    /**
        The tip of the chain associated with this link
    */
    public func tip() -> Link {
        var tip = self
        while let next = tip.parent {
            tip = next
        }
        return tip
    }

    /**
        The tail of the chain associated with this link
    */
    public func tail() -> Link {
        var tail = self
        while let next = tail.child {
            tail = next
        }
        return tail
    }

    /**
        Sever the child of this Link. This will also lose all children of that link.
    */
    @discardableResult
    public func dropChild() -> Link? {
        let child = self.child
        self.child = nil
        child?.parent = nil
        return child
    }

    /**
        Sever the child of this Link. This will also lose all children of that link.
    */
    @discardableResult
    public func dropParent() -> Link? {
        let parent = self.parent
        self.parent = nil
        parent?.child = nil
        return parent
    }

    /**
     Adds a new, or replaces the existing child associated with this link
     */
    public func addChild(_ link: Link?) {
        if let existingChild = child { existingChild.parent = nil }
        self.child = link
        link?.parent = self
    }

    /**
        Adds a new, or replaces the existing parent associated with this link
    */
    public func addParent(_ link: Link?) {
        if let existingParent = parent { existingParent.child = nil }
        self.parent = link
        link?.child = self
    }
}

extension Link: Sequence {
    public typealias Iterator = AnyIterator<Value>

    public func makeIterator() -> AnyIterator<Value> {
        var tip = Optional(self)
        return AnyIterator {
            let next = tip
            tip = next?.child
            return next?.value
        }
    }
}
