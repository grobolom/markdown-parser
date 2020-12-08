# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import nre, strformat

# so, we have learned some stuff. Let's start by testing a conversion of the
# header token into a proper piece of html
type
  Header = object
    text: string
    level: int

  TokenTypes {.pure.} = enum
    Header

  Token = ref object
    case kind: TokenTypes
    of TokenTypes.Header: headerVal: Header

  MatchRule = object
    token: TokenTypes
    regex: string

  ParseError = object of ValueError

const matchRules = [
  MatchRule(token: TokenTypes.Header, regex: "\\A(#{0,6}) *(\\w+)")
]

proc findToken(text: string, matcher: MatchRule): Token =
  const value = Header(text: "h1", level: 1);
  return Token(kind: TokenTypes.Header, headerVal: value)

proc parse*(text: var string): seq[Token] =
  while len(text) > 0:
    var token: Token

    for matcher in matchRules:
      token = findToken(text, matcher)

      if token != nil:
        result &= token
        break

      if token == nil:
        raise newException(ParseError, "we got a bad token for {text}")


when isMainModule:
  import unittest

  suite "basic integration":
    test "converts h6s":
      var text = "###### h6"
      var result = parse(text)
      check result == "<h6>h6</h6>"

    test "converts h1s":
      var text = "# h1"
      var result = parse(text)
      check result == "<h1>h1</h1>"