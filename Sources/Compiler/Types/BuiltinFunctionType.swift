/// A namespace containing the types of the built-in functions.
public enum BuiltinFunctionType {

  /// Uncondtionally stops the program.
  public static let terminate = LambdaType(to: .never)

  /// 1-bit integer copy.
  public static let i1_copy = LambdaType(
    from: (.let, .i(1)),
    to: .builtin(.i(1)))

  /// 64-bit integer copy.
  public static let i64_copy = LambdaType(
    from: (.let, .i(64)),
    to: .builtin(.i(64)))

  /// 64-bit integer multiplication.
  public static let i64_mul = LambdaType(
    from: (.let, .i(64)), (.let, .i(64)),
    to: .builtin(.i(64)))

  /// 64-bit integer addition.
  public static let i64_add = LambdaType(
    from: (.let, .i(64)), (.let, .i(64)),
    to: .builtin(.i(64)))

  /// 64-bit integer subtraction.
  public static let i64_sub = LambdaType(
    from: (.let, .i(64)), (.let, .i(64)),
    to: .builtin(.i(64)))

  /// 64-bit integer "less than" comparison.
  public static let i64_lt = LambdaType(
    from: (.let, .i(64)), (.let, .i(64)),
    to: .builtin(.i(1)))

  // 64-bit print.
  public static let i64_print = LambdaType(
    from: (.let, .i(64)),
    to: .unit)

  /// Returns the type of the built-in function with the given name.
  public static subscript(_ name: String) -> LambdaType? {
    switch name {
    case "terminate": return Self.terminate

    case "i1_copy"  : return Self.i1_copy

    case "i64_copy" : return Self.i64_copy
    case "i64_mul"  : return Self.i64_mul
    case "i64_add"  : return Self.i64_add
    case "i64_sub"  : return Self.i64_sub
    case "i64_lt"   : return Self.i64_lt
    case "i64_print": return Self.i64_print

    default:
      return nil
    }
  }

}

extension LambdaType {

  fileprivate init(from inputs: (PassingConvention, BuiltinType)..., to output: Type) {
    self.init(
      inputs: inputs.map({ (convention, type) in
        CallableTypeParameter(
          type: .parameter(ParameterType(convention: convention, bareType: .builtin(type))))
      }),
      output: output)
  }

}
