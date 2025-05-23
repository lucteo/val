/// A type that tokenize a source file.
public struct Lexer: IteratorProtocol, Sequence {

  /// The source file being tokenized.
  public let source: SourceFile

  /// The current position in the source file.
  public private(set) var index: String.Index

  /// Creates a lexer generating tokens from the contents of `source`.
  public init(tokenizing source: SourceFile) {
    self.source = source
    self.index = source.contents.startIndex
  }

  /// The current location of the lexer in `source`.
  public var location: SourceLocation { SourceLocation(source: source, index: index) }

  /// Advances to the next token and returns it, or returns `nil` if no next token exists.
  public mutating func next() -> Token? {
    // Skip whitespaces and comments.
    while true {
      if index == source.contents.endIndex { return nil }

      // Skip whitespaces.
      if source.contents[index].isWhitespace {
        discard()
        continue
      }

      // Skip line comments.
      if take(prefix: "//") != nil {
        while (index < source.contents.endIndex) && !source.contents[index].isNewline {
          discard()
        }
        continue
      }

      // Skip block comments.
      if let start = take(prefix: "/*") {
        // Search for the end of the block.
        var open = 1
        while open > 0 {
          if take(prefix: "/*") != nil {
            open += 1
          } else if take(prefix: "*/") != nil {
            open -= 1
          } else if index < source.contents.endIndex {
            discard()
          } else {
            return Token(
              kind: .unterminatedBlockComment,
              range: SourceRange(in: source, from: start, to: index))
          }
        }

        // Found the end of the block.
        continue
      }

      // The next character must be part of a token.
      break
    }

    // Scan a new token.
    let head = source.contents[index]
    var token = Token(kind: .invalid, range: location ..< location)

    // Scan names and keywords.
    if head.isLetter || (head == "_") {
      let word = take(while: { $0.isLetter || $0.isDecDigit })
      token.range = SourceRange(in: source, from: token.range.lowerBound, to: index)

      switch word {
      case "_"          : token.kind = .under
      case "any"        : token.kind = .`any`
      case "async"      : token.kind = .`async`
      case "await"      : token.kind = .`await`
      case "break"      : token.kind = .`break`
      case "catch"      : token.kind = .`catch`
      case "conformance": token.kind = .`conformance`
      case "continue"   : token.kind = .`continue`
      case "deinit"     : token.kind = .`deinit`
      case "do"         : token.kind = .`do`
      case "else"       : token.kind = .`else`
      case "extension"  : token.kind = .`extension`
      case "for"        : token.kind = .`for`
      case "fun"        : token.kind = .`fun`
      case "if"         : token.kind = .`if`
      case "import"     : token.kind = .`import`
      case "in"         : token.kind = .`in`
      case "indirect"   : token.kind = .`indirect`
      case "infix"      : token.kind = .`infix`
      case "init"       : token.kind = .`init`
      case "inout"      : token.kind = .`inout`
      case "let"        : token.kind = .`let`
      case "match"      : token.kind = .`match`
      case "namespace"  : token.kind = .`namespace`
      case "nil"        : token.kind = .`nil`
      case "operator"   : token.kind = .`operator`
      case "postfix"    : token.kind = .`postfix`
      case "prefix"     : token.kind = .`prefix`
      case "property"   : token.kind = .`property`
      case "public"     : token.kind = .`public`
      case "return"     : token.kind = .`return`
      case "set"        : token.kind = .`set`
      case "sink"       : token.kind = .`sink`
      case "some"       : token.kind = .`some`
      case "static"     : token.kind = .`static`
      case "subscript"  : token.kind = .`subscript`
      case "trait"      : token.kind = .`trait`
      case "try"        : token.kind = .`try`
      case "type"       : token.kind = .`type`
      case "typealias"  : token.kind = .`typealias`
      case "var"        : token.kind = .`var`
      case "where"      : token.kind = .`where`
      case "while"      : token.kind = .`while`
      case "yield"      : token.kind = .`yield`
      case "yielded"    : token.kind = .`yielded`

      case "false"      : token.kind = .bool
      case "true"       : token.kind = .bool

      case "is"         : token.kind = .cast

      case "as":
        _ = take("!")
        _ = take("!")
        token.range.upperBound = index
        token.kind = .cast

      default:
        token.kind = .name
      }

      return token
    }

    // Scan a back-quoted names.
    if head == "`" {
      discard()

      if let c = peek(), c.isLetter {
        let i = index
        _ = take(while: { $0.isLetter || $0.isDecDigit })

        if peek() == "`" {
          let start = SourceLocation(
            source: source, index: source.contents.index(after: token.range.lowerBound))
          token.kind = .name
          token.range = start ..< location
          discard()
          return token
        } else {
          index = i
        }
      }

      token.range.upperBound = index
      return token
    }

    // Scan numeric literls
    if head.isDecDigit {
      token.kind = .int

      // Check if the literal is non-decimal.
      if let i = take("0") {
        switch peek() {
        case "x":
          discard()
          if let c = peek(), c.isHexDigit {
            _ = take(while: { $0.isHexDigit })
            token.range.upperBound = index
            return token
          }

        case "o":
          discard()
          if let c = peek(), c.isOctDigit {
            _ = take(while: { $0.isOctDigit })
            token.range.upperBound = index
            return token
          }

        case "b":
          discard()
          if let c = peek(), c.isBinDigit {
            _ = take(while: { $0.isBinDigit })
            token.range.upperBound = index
            return token
          }

        default:
          break
        }

        index = i
      }

      // Consume the integer part.
      _ = take(while: { $0.isDecDigit })

      // Consume the floating-point part, if any.
      if let i = take(".") {
        if (peek() != "_") && !take(while: { $0.isDecDigit }).isEmpty {
          token.kind = .float
        } else {
          index = i
        }
      }

      // Consume the exponent, if any.
      if let i = take("e") ?? take("E") {
        _ = take("+") ?? take("-")

        if (peek() != "_") && !take(while: { $0.isDecDigit }).isEmpty {
          token.kind = .float
        } else {
          index = i
        }
      }

      token.range.upperBound = index
      return token
    }

    // Scan character strings.
    if head == "\"" {
      discard()

      var escape = false
      while index < source.contents.endIndex {
        if !escape && (take("\"") != nil) {
          token.kind = .string
          token.range.upperBound = index
          return token
        } else if take("\\") != nil {
          escape = !escape
        } else {
          discard()
          escape = false
        }
      }

      token.kind = .unterminatedString
      token.range.upperBound = index
      return token
    }

    // Scan attributes.
    if head == "@" {
      discard()
      let word = take(while: { $0.isLetter || ($0 == "_") })

      switch word {
      case "implicitcopy"   : token.kind = .implicitCopyAttribute
      case "implicitpublic" : token.kind = .implicitPublicAttribute
      case "type"           : token.kind = .typeAttribute
      case "value"          : token.kind = .valueAttribute
      default               : token.kind = .unrecognizedAttribute
      }

      token.range.upperBound = index
      return token
    }

    // Scan operators.
    if head.isOperator {
      let oper: Substring
      switch head {
      case "<", ">":
        // Leading angle brackets are tokenized individually, to parse generic clauses.
        discard()
        oper = source.contents[token.range.lowerBound ..< index]

      default:
        oper = take(while: { $0.isOperator })
      }

      switch oper {
      case "<" : token.kind = .lAngle
      case ">" : token.kind = .rAngle
      case "->": token.kind = .arrow
      case "&" : token.kind = .ampersand
      case "|" : token.kind = .pipe
      case "=" : token.kind = .assign
      case "==": token.kind = .equal
      default  : token.kind = .oper
      }

      token.range.upperBound = index
      return token
    }

    // Scan punctuation.
    switch head {
    case ".": token.kind = .dot
    case ",": token.kind = .comma
    case ";": token.kind = .semi
    case "(": token.kind = .lParen
    case ")": token.kind = .rParen
    case "{": token.kind = .lBrace
    case "}": token.kind = .rBrace
    case "[": token.kind = .lBrack
    case "]": token.kind = .rBrack

    case ":":
      // Scan double colons.
      if take(prefix: "::") != nil {
        token.kind = .twoColons
        token.range.upperBound = index
        return token
      }

      // Fall back to a simple colon.
      token.kind = .colon

    default:
      break
    }

    // Either the token is punctuation, or it's kind is `invalid`.
    discard()
    token.range.upperBound = index
    return token
  }

  /// Discards `count` characters from the stream.
  private mutating func discard(_ count: Int = 1) {
    index = source.contents.index(index, offsetBy: count)
  }

  /// Returns the next character in the stream without consuming it, if any.
  private func peek() -> Character? {
    if index == source.contents.endIndex { return nil }
    return source.contents[index]
  }

  /// Returns the current index and consumes `character` from the stream, or returns `nil` if the
  /// stream starts with a different character.
  public mutating func take(_ character: Character) -> String.Index? {
    if peek() != character { return nil }
    defer { index = source.contents.index(after: index) }
    return index
  }

  /// Returns the current index and consumes `prefix` from the stream, or returns `nil` if the
  /// stream starts with a different prefix.
  private mutating func take<T: Sequence>(prefix: T) -> String.Index?
  where T.Element == Character
  {
    var newIndex = index
    for ch in prefix {
      if newIndex == source.contents.endIndex || source.contents[newIndex] != ch { return nil }
      newIndex = source.contents.index(after: newIndex)
    }

    defer { index = newIndex }
    return index
  }

  /// Consumes the longest substring that satisfies the given predicate.
  private mutating func take(while predicate: (Character) -> Bool) -> Substring {
    let start = index
    while let ch = peek(), predicate(ch) {
      index = source.contents.index(after: index)
    }

    return source.contents[start ..< index]
  }

}

fileprivate extension Character {

  /// Indicates whether `self` character represents a decimal digit.
  var isDecDigit: Bool {
    guard let ascii = asciiValue else { return false }
    return (0x30 ... 0x39) ~= ascii // 0 ... 9
        || 0x5f == ascii            // _
  }

  /// Indicates whether `self` represents an hexadecimal digit.
  var isHexDigit: Bool {
    guard let ascii = asciiValue else { return false }
    return (0x30 ... 0x39) ~= ascii // 0 ... 9
        || (0x41 ... 0x46) ~= ascii // A ... F
        || (0x61 ... 0x66) ~= ascii // a ... f
        || 0x5f == ascii            // _
  }

  /// /// Indicates whether `self` represents an octal digit.
  var isOctDigit: Bool {
    guard let ascii = asciiValue else { return false }
    return (0x30 ... 0x37) ~= ascii // 0 ... 7
        || 0x5f == ascii            // _
  }

  /// Indicates whether `self` represents a binary digit.
  var isBinDigit: Bool {
    self == "0" || self == "1" || self == "_"
  }

  /// Indicates whether `self` represents an operator.
  var isOperator: Bool {
    "<>=+-*/%&|!?^~".contains(self)
  }

}
