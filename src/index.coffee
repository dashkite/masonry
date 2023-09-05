import FS from "node:fs/promises"
import Path from "node:path"
import * as Fn from "@dashkite/joy/function"
import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import * as It from "@dashkite/joy/iterable"
import * as Val from "@dashkite/joy/value"
import * as Text from "@dashkite/joy/text"
import Glob from "fast-glob"
import Ch from "chokidar"

_glob = ( patterns, options ) ->
  Glob.glob patterns, options

parse = parse = (path) ->
  {dir, name, ext} = Path.parse path
  path: path
  directory: dir
  name: name
  extension: ext

assign = ( key, f ) -> 
  ( context ) -> context[ key ] = await f context

start = (fx) -> Fn.flow [ fx..., It.start ]

glob = Fn.curry ( patterns ) -> ->
  for path in await _glob patterns, cwd: "."
    yield {
      root: "."
      source: parse path
    }

readText = read = It.resolve It.tap assign "input",
  ({ root, source }) -> FS.readFile (Path.join root, source.path), "utf8"

readBytes = It.resolve It.tap assign "input",
  ({ root, source }) -> FS.readFile Path.join root, source.path

transform = tr = generic name: "transform"

generic transform, Type.isArray, ( fx ) ->
  It.resolve It.tap assign "output", ( context ) ->
    { input } = context
    ( input = await f { context..., input }) for f in fx
    input

generic transform, Type.isFunction, ( f ) ->
  It.resolve It.tap assign "output", ( context ) -> f context

extension = ( extension ) ->
  It.tap assign "extension", Fn.wrap extension

sourcePath = ({ root, source }) ->
  Path.join root, source.path

targetPath = ( target, context ) ->
  do ({ source, extension } = context ) ->
    directory = Path.join target, source.directory
    await FS.mkdir directory, recursive: true
    name = source.name + ( extension ? source.extension )
    Path.join directory, name

write = ( target ) ->
  It.resolve It.tap ( context ) ->
    FS.writeFile ( await targetPath target, context ), context.output

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
  Ch.watch path, ignoreInitial: true
    .on "all", handler

set = Fn.curry ( name, f ) -> It.resolve It.tap assign name, f

export {
  start
  glob
  read
  readText
  readBytes
  tr
  transform
  extension
  write
  copy
  rm
  remove
  watch
  set
}
