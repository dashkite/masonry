import p from "path"
import fglob from "fast-glob"
import * as r from "panda-river"
import * as q from "panda-quill"
import {wrap, curry, flow, wait, identity} from "@pandastrike/garden"
import * as k from "@dashkite/katana"
import ch from "chokidar"
import express from "express"
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
      r.map (path) -> [ root, path: parse path ]
    ]

read = r.wait r.map flow [
  k.read "path"
  k.poke ({path}, root) -> q.read p.join root, path
]

tr = (f) ->
  r.map flow [
    k.read "path"
    k.poke f
  ]

extension = (extension) ->
  r.map flow [
    k.push wrap extension
    k.write "extension"
    k.discard
  ]

write = curry (root) ->
  r.map flow [
    k.read "path"
    k.read "extension"
    k.peek (_extension, {directory, name, extension}, output) ->
      path = p.join root, directory, "#{name}#{_extension ? extension}"
      await q.mkdirp "0777", p.join root, directory
      q.write path, output
  ]

copy = curry (troot) ->
  r.map flow [
    k.read "path"
    k.read "extension"
    k.peek ({directory, path}, sroot) ->
      source = p.join sroot, path
      target = p.join troot, path
      await q.mkdirp "0777", p.join troot, directory
      q.cp source, target
  ]

watch = curry (path, handler) ->
  ch.watch path, ignoreInitial: true
    .on "all", handler

server = curry (root, options) ->
  app = express()
  app.use express.static root
  if options.fallback?
    _path = p.resolve root, options.fallback
    app.get "*", (request, response) ->
      response.sendFile _path
  app.listen 3000

exec = (c, ax) ->
  child = execa c, ax
  child.stdout.pipe process.stdout
  child.stderr.pipe process.stderr

node = (path, ax) ->
  child = execa.node path, ax
  child.stdout.pipe process.stdout
  child.stderr.pipe process.stderr

export {start, glob, read, tr, extension, write, copy,
  watch, server, exec, node}
