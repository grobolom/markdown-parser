# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import nre, strformat, strutils

# so, we have learned some stuff. Let's start by testing a conversion of the
# header token into a proper piece of html
type
  Header = object
    text: string
    level: int

  Callout = object
    text: string

  Paragraph = object
    text: string

  TokenTypes {.pure.} = enum
    Header, Callout, Paragraph

  Token = ref object
    case kind: TokenTypes
    of TokenTypes.Header: headerVal: Header
    of TokenTypes.Callout: calloutVal: Callout
    of TokenTypes.Paragraph: paragraphVal: Paragraph

  MatchRule = object
    token: TokenTypes
    regex: string

  ParseError = object of ValueError

const matchRules = [
  MatchRule(token: TokenTypes.Header, regex: r"(#{1,6}) *(\w+)"),
  MatchRule(token: TokenTypes.Callout, regex: r"```([\w\s]+)```"),
  MatchRule(token: TokenTypes.Paragraph, regex: r"([\w ]+\n{0,1})+((\n\n){0,1})"),
]

proc findToken(text: string, start: var int, matcher: MatchRule): Token =
  let regex = re(&"\\A{matcher.regex}")
  let match = text[start..^1].match(regex)

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
  of TokenTypes.Callout:
    var val: Callout
    val.text = match.get.captures[0]
    length = len(match.get.captures[-1])
    result = Token(kind: TokenTypes.Callout, calloutVal: val)
  of TokenTypes.Paragraph:
    var val: Paragraph
    val.text = match.get.captures[0]
    length = len(val.text) + 1
    result = Token(kind: TokenTypes.Paragraph, paragraphVal: val)

  start += length

proc renderToken(token: Token): string =
  case token.kind
  of TokenTypes.Header:
    let val = token.headerVal
    result &= &"<h{val.level}>{val.text}</h{val.level}>"
  of TokenTypes.Callout:
    let val = token.calloutVal
    result &= &"<div class='callout'><p>{val.text}</p></div>"
  of TokenTypes.Paragraph:
    let val = token.paragraphVal
    result &= &"<p>{val.text.strip}</p>"

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

    # remember, this is de-dented because it should be
    # only if we couldn't match anything
    if token == nil:
      raise newException(ParseError, &"we couldn't match from: {text}")

  for tok in tokens:
    result &= renderToken(tok)

when isMainModule:
  import unittest

  suite "basic integration":
    test "converts paragraphs":
      var text = "some text\n\nsome other text\n\nsome more text"
      var res = parse(text)
      check res == "<p>some text</p><p>some other text</p><p>some more text</p>"

    test "converts h6s":
      var text = "###### h6"
      var res = parse(text)
      check res == "<h6>h6</h6>"

    test "converts h1s":
      var text = "# h1"
      var res = parse(text)
      check res == "<h1>h1</h1>"

    test "converts callouts":
      var text = "```something\nsomething else```"
      var res = parse(text)
      check res == "<div class='callout'><p>something\nsomething else</p></div>"
