import FS from "fs/promises"
import Path from "path"
import * as _ from "@dashkite/joy"
import * as k from "@dashkite/katana/async"
import fglob from "fast-glob"
import ch from "chokidar"
import express from "express"
import morgan from "morgan"
import execa from "execa"

parse = parse = (path) ->
  {dir, name, ext} = Path.parse path
  path: path
  directory: dir
  name: name
  extension: ext

start = (fx) -> _.flow [ fx..., _.start ]

glob = _.curry (pattern, root) ->
  _.flow [
      -> fglob pattern, cwd: root
      _.map (path) ->  k.Daisho.create {root, source: parse path }
    ]

read = _.resolve _.map k.assign [
  k.context
  k.push ({source, root}) ->
    FS.readFile (Path.join root, source.path), "utf8"
  k.write "input"
]

tr = (f) ->
  if Array.isArray f
    _.resolve _.map k.assign [
      k.context
      k.push (context) ->
        for g in f
          output = g {context..., input: output ? context.input}
        output
      k.write "output"
    ]
  else
    _.resolve _.map k.assign [
      k.context
      k.push f
      k.write "output"
    ]

extension = (extension) ->
  _.wait _.map k.assign [
    k.push _.wrap extension
    k.write "extension"
  ]

write = _.curry (root) ->
  _.resolve _.map k.assign [
    k.context
    k.peek ({extension, source, output}) ->
      path = Path.join root, source.directory,
        "#{source.name}#{extension ? source.extension}"
      await FS.mkdir (Path.join root, source.directory), recursive: true
      FS.writeFile path, output
  ]

copy = _.curry (target) ->
  _.wait _.map k.assign [
    k.context
    k.peek ({source, root}) ->
      FS.copyFile (Path.join root, source.path),
        (Path.join target, source.path)
  ]

rm = _.curry (target) -> FS.rm target, recursive: true

watch = _.curry (path, handler) ->
  ch.watch path, ignoreInitial: true
    .on "all", handler

server = _.curry (root, options) ->
  app = express()
  {fallback, port, files} = options
  app.use morgan "dev"
  app.use express.static root, files ? {}
  if fallback?
    app.get "*", (request, response) ->
      response.sendFile fallback
  app.listen {port}

exec = (c, ax) ->
  child = execa c, ax
  child.stdout.pipe process.stdout
  child.stderr.pipe process.stderr
  child

export {
  start
  glob
  read
  tr
  extension
  write
  copy
  rm,
  watch
  server
  exec
}
