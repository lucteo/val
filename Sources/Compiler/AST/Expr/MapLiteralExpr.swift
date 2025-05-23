/// A map literal expression.
public struct MapLiteralExpr: Expr {

  public static let kind = NodeKind.mapLiteralExpr

  /// A key-value pair in a map literal.
  public struct Element: Codable {

    var key: AnyExprID

    var value: AnyExprID

  }

  /// The key-value pairs of the literal.
  public var elements: [Element]

  public init(elements: [Element]) {
    self.elements = elements
  }

}
