from markdown_parser import parse

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
