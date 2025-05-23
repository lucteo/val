/// A pattern that introduces new variables.
///
/// This pattern alters the semantics of its sub-pattern. Nested name patterns create new variable
/// bindings, instead of referring to existing declarations.
public struct BindingPattern: Pattern {

  public static let kind = NodeKind.bindingPattern

  public enum Introducer: Codable {

    case `let`

    case `var`

    case sinklet

    case `inout`

  }

  /// The introducer of the pattern.
  public var introducer: SourceRepresentable<Introducer>

  /// The sub-pattern.
  ///
  /// - Requires: `subpattern` may not contain other binding patterns.
  public var subpattern: AnyPatternID

  /// The type annotation of the pattern, if any.
  public var annotation: AnyTypeExprID?

  public init(
    introducer: SourceRepresentable<BindingPattern.Introducer>,
    subpattern: AnyPatternID,
    annotation: AnyTypeExprID? = nil
  ) {
    self.introducer = introducer
    self.subpattern = subpattern
    self.annotation = annotation
  }

}
