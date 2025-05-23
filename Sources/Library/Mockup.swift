import Compiler

/// Creates a mockup of the standard library into `ast` and returns its identifier.
@discardableResult
public func insertStandardLibraryMockup(into ast: inout AST) -> NodeID<ModuleDecl> {
  precondition(ast.stdlib == nil)
  let stdlib = ast.insert(ModuleDecl(name: "Val"))
  let source = ast.insert(TopLevelDeclSet())
  ast[stdlib].sources.append(source)

  // fun fatal_error() -> Never {}
  ast[source].decls.append(AnyDeclID(ast.insert(FunDecl(
    introducer: SourceRepresentable(value: .fun),
    identifier: SourceRepresentable(value: "fatal_error"),
    output: AnyTypeExprID(ast.insert(NameTypeExpr(
      identifier: SourceRepresentable(value: "Never")))),
    body: .block(ast.insert(BraceStmt()))))))

  // trait ExpressibleByIntegerLiteral { ... }
  ast[source].decls.append(AnyDeclID(ast.insert(TraitDecl(
    identifier: SourceRepresentable(value: "ExpressibleByIntegerLiteral"),
    members: [
      // init(integer_literal: Builtin.IntegerLiteral)
      AnyDeclID(ast.insert(FunDecl(
        introducer: SourceRepresentable(value: .`init`),
        parameters: [
          ast.insert(ParameterDecl(
            identifier: SourceRepresentable(value: "integer_literal"),
            annotation: ast.insert(ParameterTypeExpr(
              convention: SourceRepresentable(value: .let),
              bareType: AnyTypeExprID(ast.insert(NameTypeExpr(
                domain: AnyTypeExprID(ast.insert(NameTypeExpr(
                  identifier: SourceRepresentable(value: "Builtin")))),
                identifier: SourceRepresentable(value: "IntegerLiteral")))))))),
        ])))
    ]
  ))))

  // public type Bool { ... }
  ast[source].decls.append(AnyDeclID(ast.insert(ProductTypeDecl(
    accessModifier: SourceRepresentable(value: .public),
    identifier: SourceRepresentable(value: "Bool"),
    members: [
      // var value: Builtin.i1
      AnyDeclID(ast.insert(BindingDecl(
        pattern: ast.insert(BindingPattern(
          introducer: SourceRepresentable(value: .var),
          subpattern: AnyPatternID(ast.insert(NamePattern(
            decl: ast.insert(VarDecl(
              identifier: SourceRepresentable(value: "value")))))),
          annotation: AnyTypeExprID(ast.insert(NameTypeExpr(
            domain: AnyTypeExprID(ast.insert(NameTypeExpr(
              identifier: SourceRepresentable(value: "Builtin")))),
            identifier: SourceRepresentable(value: "i1"))))))))),

      // public fun copy() -> Self {
      //   Bool(value: Builtin.i1_copy(value))
      // }
      AnyDeclID(ast.insert(FunDecl(
        introducer: SourceRepresentable(value: .fun),
        accessModifier: SourceRepresentable(value: .public),
        identifier: SourceRepresentable(value: "copy"),
        output: AnyTypeExprID(ast.insert(NameTypeExpr(
          identifier: SourceRepresentable(value: "Self")))),
        body: .expr(
          AnyExprID(ast.insert(FunCallExpr(
            callee: AnyExprID(ast.insert(NameExpr(
              name: SourceRepresentable(value: "Bool")))),
          arguments: [
            CallArgument(
              label: SourceRepresentable(value: "value"),
              value: AnyExprID(ast.insert(FunCallExpr(
                callee: AnyExprID(ast.insert(NameExpr(
                  domain: .expr(AnyExprID(ast.insert(NameExpr(
                    name: SourceRepresentable(value: "Builtin"))))),
                  name: SourceRepresentable(value: "i1_copy")))),
              arguments: [
                CallArgument(
                  value: AnyExprID(ast.insert(NameExpr(
                    name: SourceRepresentable(value: "value"))))),
                ])))),
          ]))))))),
    ]))))

  // public type Int { ... }
  ast[source].decls.append(AnyDeclID(ast.insert(ProductTypeDecl(
    accessModifier: SourceRepresentable(value: .public),
    identifier: SourceRepresentable(value: "Int"),
    conformances: [
      ast.insert(NameTypeExpr(
        identifier: SourceRepresentable(value: "ExpressibleByIntegerLiteral"))),
    ],
    members: [
      // public init(integer_literal: Builtin.IntegerLiteral) { fatal_error() }
      AnyDeclID(ast.insert(FunDecl(
        introducer: SourceRepresentable(value: .`init`),
        accessModifier: SourceRepresentable(value: .public),
        parameters: [
          ast.insert(ParameterDecl(
            identifier: SourceRepresentable(value: "integer_literal"),
            annotation: ast.insert(ParameterTypeExpr(
              convention: SourceRepresentable(value: .let),
              bareType: AnyTypeExprID(ast.insert(NameTypeExpr(
                domain: AnyTypeExprID(ast.insert(NameTypeExpr(
                  identifier: SourceRepresentable(value: "Builtin")))),
                identifier: SourceRepresentable(value: "IntegerLiteral")))))))),
        ],
        body: .expr(
          AnyExprID(ast.insert(FunCallExpr(
            callee: AnyExprID(ast.insert(NameExpr(
              name: SourceRepresentable(value: "fatal_error"))))))))))),

      // public fun copy() -> Self { fatal_error() }
      AnyDeclID(ast.insert(FunDecl(
        introducer: SourceRepresentable(value: .fun),
        accessModifier: SourceRepresentable(value: .public),
        identifier: SourceRepresentable(value: "copy"),
        output: AnyTypeExprID(ast.insert(NameTypeExpr(
          identifier: SourceRepresentable(value: "Self")))),
        body: .expr(
          AnyExprID(ast.insert(FunCallExpr(
            callee: AnyExprID(ast.insert(NameExpr(
              name: SourceRepresentable(value: "fatal_error"))))))))))),
    ]
  ))))

  // public type Double { ... }
  ast[source].decls.append(AnyDeclID(ast.insert(ProductTypeDecl(
    accessModifier: SourceRepresentable(value: .public),
    identifier: SourceRepresentable(value: "Double"),
    conformances: [
      ast.insert(NameTypeExpr(
        identifier: SourceRepresentable(value: "ExpressibleByIntegerLiteral"))),
    ],
    members: [
      // public init(integer_literal: Builtin.IntegerLiteral) { fatal_error() }
      AnyDeclID(ast.insert(FunDecl(
        introducer: SourceRepresentable(value: .`init`),
        accessModifier: SourceRepresentable(value: .public),
        parameters: [
          ast.insert(ParameterDecl(
            identifier: SourceRepresentable(value: "integer_literal"),
            annotation: ast.insert(ParameterTypeExpr(
              convention: SourceRepresentable(value: .let),
              bareType: AnyTypeExprID(ast.insert(NameTypeExpr(
                domain: AnyTypeExprID(ast.insert(NameTypeExpr(
                  identifier: SourceRepresentable(value: "Builtin")))),
                identifier: SourceRepresentable(value: "IntegerLiteral")))))))),
        ],
        body: .expr(
          AnyExprID(ast.insert(FunCallExpr(
            callee: AnyExprID(ast.insert(NameExpr(
              name: SourceRepresentable(value: "fatal_error")))))))))))
    ]
  ))))

  ast.stdlib = stdlib
  return stdlib
}
