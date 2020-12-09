from tokens import Token, TokenTypes, Header, Callout, Paragraph

import nre, strformat, strutils

type
  ParseError = object of ValueError

const matchRules = [
  TokenTypes.Header: r"(#{1,6}) *(\w+)",
  TokenTypes.Callout: r"```([\w\s]+)```",
  TokenTypes.Paragraph: r"([\w ]+\n{0,1})+((\n\n){0,1})",
]

proc findToken(text: string, start: var int, tokenType: TokenTypes, matcher: string): Token =
  let regex = re(&"\\A{matcher}")
  let match = text[start..^1].match(regex)

  if match == none(RegexMatch):
    return nil

  var length: int = 0

  case tokenType
  of TokenTypes.Header:
    let val = Header(level: len(match.get.captures[0]), text: match.get.captures[1])
    length = len(match.get.captures[-1])
    result = Token(kind: TokenTypes.Header, headerVal: val)
  of TokenTypes.Callout:
    let val = Callout(text: match.get.captures[0])
    length = len(match.get.captures[-1])
    result = Token(kind: TokenTypes.Callout, calloutVal: val)
  of TokenTypes.Paragraph:
    let val = Paragraph(text: match.get.captures[0])
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

    for tokenType, matcher in matchRules:
      token = findToken(text, start, tokenType, matcher)

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