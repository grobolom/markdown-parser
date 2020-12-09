type
  Header* = object
    text*: string
    level*: int

  Callout* = object
    text*: string

  Paragraph* = object
    text*: string

  TokenTypes* {.pure.} = enum
    Header, Callout, Paragraph

  Token* = ref object
    case kind*: TokenTypes
    of TokenTypes.Header: headerVal*: Header
    of TokenTypes.Callout: calloutVal*: Callout
    of TokenTypes.Paragraph: paragraphVal*: Paragraph
