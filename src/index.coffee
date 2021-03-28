import p from "path"
import fglob from "fast-glob"
import * as r from "panda-river"
import {wrap, curry, flow, wait, identity} from "@pandastrike/garden"
import * as q from "panda-quill"
import * as k from "@dashkite/katana"
import ch from "chokidar"
import express from "express"
import morgan from "morgan"
import execa from "execa"

parse = parse = (path) ->
  {dir, name, ext} = p.parse path
  path: path
  directory: dir
  name: name
  extension: ext

start = (fx) -> flow [ fx..., r.start ]

glob = curry (pattern, root) ->
  flow [
      -> fglob pattern, cwd: root
      r.map (path) ->  [{root, source: parse path }]
    ]

read = r.wait r.map flow [
  k.push ({source, root}) ->
    q.read p.join root, source.path
  k.write "input"
  k.discard
]

tr = (f) ->
  r.wait r.map flow [
    k.push f
    k.write "output"
    k.discard
  ]

extension = (extension) ->
  r.wait r.map flow [
    k.push wrap extension
    k.write "extension"
    k.discard
  ]

write = curry (root) ->
  r.wait r.map k.peek ({extension, source, output}) ->
    path = p.join root, source.directory,
      "#{source.name}#{extension ? source.extension}"
    await q.mkdirp "0777", p.join root, source.directory
    q.write path, output

copy = curry (target) ->
  r.wait r.map flow [
    k.peek ({source, root}) ->
      await q.mkdirp "0777", p.join target, source.directory
      q.cp (p.join root, source.path), p.join target, source.path
  ]

rm = curry (target) -> q.rmr target

watch = curry (path, handler) ->
  ch.watch path, ignoreInitial: true
    .on "all", handler

server = curry (root, options) ->
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

node = (path, ax) ->
  child = execa.node path, ax
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
  node
}
