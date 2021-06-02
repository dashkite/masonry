import FS from "fs/promises"
import Path from "path"
import * as _ from "@dashkite/joy"
import * as k from "@dashkite/katana/async"
import fglob from "fast-glob"
import ch from "chokidar"
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

transform = tr = (f) ->
  if Array.isArray f
    _.resolve _.map k.assign [
      k.context
      k.push (context) ->
        for g in f
          output = await g {context..., input: output ? context.input}
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

remove = rm = _.curry (target) ->
  ->
    try
      await FS.rm target, recursive: true
    catch error
      unless _.startsWith "ENOENT", error.message
        throw error

watch = _.curry (path, handler) -> ->
  ch.watch path, ignoreInitial: true
    .on "all", handler

exec = (c, ax) -> ->
  try
    child = execa c, ax, stdout: "inherit", stderr: "inherit"
    # await so we catch any exception
    # which we ignore in favor of piping
    # stdout/stderr
    await child

export {
  start
  glob
  read
  tr
  transform
  extension
  write
  copy
  rm
  remove
  watch
  exec
}
