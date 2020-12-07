# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import nre, strformat

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
    TokenKind(kind: "header", regex: "[\\n]?#+"),
    TokenKind(kind: "text", regex: "[A-Za-z0-9 ]+"),
    TokenKind(kind: "asterisk", regex: "\\*"),
    TokenKind(kind: "underscore", regex: "_"),
    TokenKind(kind: "lineEnding", regex: "\\n"),
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

          res.add(Token(kind: tokenKind.kind, value: capture))

  return res

# proc generate(tokens: seq[Token]): string =
#   for token in tokens:
#     result &= renderToken(token)
#   return "<h1>foo</h1>"

when isMainModule:
  import unittest

  suite "generation":
    test "generating header html":
      let tokens = @[
        Token(kind: "header", value: "#"),
        Token(kind: "text", value: " foo")
        ]

      let html = generate(tokens)

      check html == "<h1>foo</h1>"

    test "generating bold text":
      let tokens = @[
        Token(kind: "asterisk", value: "*"),
        Token(kind: "text", value: "foo"),
        Token(kind: "asterisk", value: "*"),
      ]

      let html = generate(tokens)

      check html == "<p><em>foo</em></p>"

  suite "tokenization":
    test "tokenizing a header":
      let header = tokenize("# h1")

      check header[0] == Token(kind: "header", value: "#")
      check header[1] == Token(kind: "text", value: " h1")

    test "tokenizing a long header":
      let header = tokenize("### some text")

      check header[0] == Token(kind: "header", value: "###")
      check header[1] == Token(kind: "text", value: " some text")

    test "tokenizing an asterisk":
      let asterisk = tokenize("some words * some other words")

      check asterisk[0] == Token(kind: "text", value: "some words ")
      check asterisk[1] == Token(kind: "asterisk", value: "*")
      check asterisk[2] == Token(kind: "text", value: " some other words")

    test "tokenizing an underscore":
      let underscore = tokenize("some words _word_")

      check underscore[0] == Token(kind: "text", value: "some words ")
      check underscore[1] == Token(kind: "underscore", value: "_")
      check underscore[2] == Token(kind: "text", value: "word")
      check underscore[3] == Token(kind: "underscore", value: "_")

    test "tokenizing line endings":
      let ending = tokenize("some words\nsome more words")

      check ending[0] == Token(kind: "text", value: "some words")
      check ending[1] == Token(kind: "lineEnding", value: "\n")
      check ending[2] == Token(kind: "text", value: "some more words")