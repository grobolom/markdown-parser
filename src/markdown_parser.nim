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
  MatchRule(token: TokenTypes.Header, regex: "(#{0,6}) *(\\w+)")
]

proc findToken(text: string, start: var int, matcher: MatchRule): Token =
  let regex = re(&"\\A{matcher.regex}")
  let match = text.match(regex)

  if match == none(RegexMatch):
    return nil

  var length: int = 0

  case matcher.token
  of TokenTypes.Header:
    var val: Header
    val.level = len(match.get.captures[0])
    val.text = match.get.captures[1]
    length = len(match.get.captures[-1])
    result = Token(kind: TokenTypes.Header, headerVal: val)

  start += length

proc renderToken(token: Token): string =
  case token.kind
  of TokenTypes.Header:
    let val = token.headerVal
    result &= &"<h{val.level}>{val.text}</h{val.level}>"

proc parse*(text: var string): string =
  var tokens: seq[Token]
  var start = 0;

  while start < len(text):
    var token: Token

    for matcher in matchRules:
      token = findToken(text, start, matcher)

      if token != nil:
        tokens &= token
        break

      if token == nil:
        raise newException(ParseError, &"we got a bad token for {text}")

  for tok in tokens:
    result &= renderToken(tok)

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