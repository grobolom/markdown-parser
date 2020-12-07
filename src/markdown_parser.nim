# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import nre, strformat, strutils

type
  Token = object
    kind: string
    value: string
proc `==`(a, b: Token): bool =
  return (a.kind == b.kind) and (a.value == b.value)

type
  TokenKind = object
    kind: string
    regex: string

proc tokenize(s: string): seq[Token] =
  const tokenKinds: seq[TokenKind] = @[
    TokenKind(kind: "header", regex: "#+"),
    TokenKind(kind: "text", regex: "[\\w\\s]+")
  ]
  var text = s
  var res: seq[Token]

  block matching:
    while text != "":
      for tokenKind in tokenKinds:
        let r = re("\\A({tokenKind.regex})".fmt)
        let m = text.match(r)

        if m != none(RegexMatch):
          let capture = m.get.captures[0]
          let length = len(capture)
          text = text[length..^1]

          res.add(Token(kind: tokenKind.kind, value: strip(capture)))

  return res

when isMainModule:
  import unittest

  suite "tokenization":
    test "tokenizing a header works":
      let header = tokenize("# h1")

      check header[0] == Token(kind: "header", value: "#")
      check header[1] == Token(kind: "text", value: "h1")

    test "tokenizing a long header works":
      let header = tokenize("### some text")

      check header[0] == Token(kind: "header", value: "###")
      check header[1] == Token(kind: "text", value: "some text")