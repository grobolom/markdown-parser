import tokens

import nre, strformat, strutils

type
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
    var val: tokens.Header
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

proc tokenize(text: var string): seq[Token] =
  var start = 0;

  while start < len(text):
    var token: Token

    for matcher in matchRules:
      token = findToken(text, start, matcher)

      if token != nil:
        result &= token
        break

    # remember, this is de-dented because it should be
    # only if we couldn't match anything
    if token == nil:
      raise newException(ParseError, &"we couldn't match from: {text}")

proc parse*(text: var string): string =
  let tokens: seq[Token] = tokenize(text)
  for tok in tokens:
    result &= renderToken(tok)


when isMainModule:
  echo "cool"