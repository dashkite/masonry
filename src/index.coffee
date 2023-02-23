import FS from "node:fs/promises"
import Path from "node:path"
import { createHash } from "node:crypto"
import * as Fn from "@dashkite/joy/function"
import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import * as It from "@dashkite/joy/iterable"
import * as Val from "@dashkite/joy/value"
import * as Text from "@dashkite/joy/text"
import fglob from "fast-glob"
import ch from "chokidar"
import execa from "execa"

parse = parse = (path) ->
  {dir, name, ext} = Path.parse path
  path: path
  directory: dir
  name: name
  extension: ext

assign = ( key, f ) -> 
  ( context ) -> context[ key ] = await f context

start = (fx) -> Fn.flow [ fx..., It.start ]

glob = Fn.curry (pattern, root) ->
  Fn.flow [
    -> fglob pattern, cwd: root
    It.map (path) ->  { root, source: parse path }
  ]

readText = read = It.resolve It.tap assign "input",
  ({ root, source }) -> FS.readFile (Path.join root, source.path), "utf8"

readBinary = It.resolve It.tap assign "input",
  ({ root, source }) -> FS.readFile Path.join root, source.path

hash = It.resolve It.tap assign "hash",
  ({ input }) -> computeHash input

computeHash = ( input ) ->
  _hash = createHash "md5"
  # see: https://nodejs.org/api/buffer.html#buffers-and-character-encodings
  _hash.update input, "binary"
  _hash.digest "hex"

transform = tr = generic name: "transform"

generic transform, Type.isArray, (fx) ->
  It.resolve It.tap assign "output", (context) ->
    { input } = context
    ( input = await f { context..., input } ) for f in fx
    input

generic transform, Type.isFunction, (f) ->
  It.resolve It.tap assign "output", ( context ) -> f context

extension = (extension) ->
  It.tap assign "extension", Fn.wrap extension

sourcePath = ({ root, source }) ->
  Path.join root, source.path

targetPath = (target, { source, extension }) ->
  directory = Path.join target, source.directory
  await FS.mkdir directory, recursive: true
  name = source.name + ( extension ? source.extension )
  Path.join directory, name

write = ( target ) ->
  It.resolve It.tap ( context ) ->
    { output } = context
    FS.writeFile ( await targetPath target, context ), output

copy = ( target ) ->
  It.resolve It.tap ( context ) ->
    FS.copyFile ( sourcePath context ),
      ( await targetPath target, context )

remove = rm = Fn.curry (target) ->
  ->
    try
      await FS.rm target, recursive: true
    catch error
      unless Text.startsWith "ENOENT", error.message
        throw error

watch = Fn.curry (path, handler) -> ->
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
  readText
  readBinary
  hash
  computeHash
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
