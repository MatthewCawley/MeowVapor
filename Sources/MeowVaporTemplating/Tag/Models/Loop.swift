import BSON

public final class Loop: Tag {
    public enum Error: LeafError {
        case expectedTwoArguments(have: [Argument])
        case expectedVariable(have: Argument)
        case expectedConstant(have: Argument)
    }

    public let name = "loop"

    public func run(
        stem: Stem,
        context: Context,
        tagTemplate: TagTemplate,
        arguments: [Argument]
    ) throws -> ValueConvertible? {
        guard arguments.count == 2 else { throw Error.expectedTwoArguments(have: arguments) }
        let variable = arguments[0]
        guard case let .variable(path: _, value: value) = variable else {
            throw Error.expectedVariable(have: variable)
        }
        let constant = arguments[1]
        guard case let .constant(value: innername) = constant else {
            throw Error.expectedConstant(have: constant)
        }

        guard let unwrapped = value else { return nil }
        let array = unwrapped.documentValue?.arrayValue ?? [unwrapped]
        return Document(array: array.map { [innername: $0] as Document })
    }

    public func render(
        stem: Stem,
        context: Context,
        value: ValueConvertible?,
        leaf: Leaf
    ) throws -> Bytes {
        guard let array = value?.documentValue?.arrayValue else { fatalError("run function MUST return an array") }
        func renderItem(_ item: ValueConvertible) throws -> Bytes {
            context.push(item)
            let rendered = try stem.render(leaf, with: context)
            context.pop()
            return rendered
        }
        return try array
            .map(renderItem)
            .flatMap { $0 + [.newLine] }
    }
}
