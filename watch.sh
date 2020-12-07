fswatch ./src --event Updated | xargs -n1 -I{} nim c -r --verbosity:0 src/markdown_parser.nim
