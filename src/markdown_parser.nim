# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

proc printSomething(s: string): string =
  var foo = "bar"
  foo.add(s)
  foo.add("baz")
  return foo

when isMainModule:
  echo printSomething("whee")
