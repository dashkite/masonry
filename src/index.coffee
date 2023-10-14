import FS from "node:fs/promises"
import Path from "node:path"
import * as Fn from "@dashkite/joy/function"
import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import * as It from "@dashkite/joy/iterable"
import * as Val from "@dashkite/joy/value"
import * as Text from "@dashkite/joy/text"
import Glob from "fast-glob"

_glob = ( patterns, options ) ->
  Glob.glob patterns, options

parse = parse = (path) ->
  {dir, name, ext} = Path.parse path
  path: path
  directory: dir
  name: name
  extension: ext

assign = ( key, f ) -> 
  Fn.tee ( context ) -> context[ key ] = await f context

start = ([ glob, fx... ]) -> 
  Fn.flow [ 
    glob
    It.each Fn.flow fx 
  ]

glob = Fn.curry ( patterns ) -> ->
  for path in await _glob patterns, cwd: "."
    yield {
      root: "."
      source: parse path
    }

readText = read = assign "input",
  ({ root, build, source }) -> 
    FS.readFile ( Path.join ( root ? build.root ), 
      source.path ), "utf8"

readBytes = assign "input",
  ({ root, source }) -> FS.readFile Path.join root, source.path

transform = tr = generic name: "transform"

generic transform, Type.isArray, ( fx ) ->
  assign "output", ( context ) ->
    { input } = context
    ( input = await f { context..., input }) for f in fx
    input

generic transform, Type.isFunction, ( f ) ->
  assign "output", ( context ) -> f context

extension = ( extension ) ->
  assign "extension", Fn.wrap extension

sourcePath = ({ root, source }) ->
  Path.join root, source.path

targetPath = ( target, context ) ->
  do ({ source, extension } = context ) ->
    directory = Path.join target, source.directory
    await FS.mkdir directory, recursive: true
    name = source.name + ( extension ? source.extension )
    Path.join directory, name

write = ( target ) ->
  Fn.tee ( context ) ->
    FS.writeFile ( await targetPath target, context ), context.output

copy = ( target ) ->
  Fn.tee ( context ) ->
    FS.copyFile ( sourcePath context ),
      ( await targetPath target, context )

set = Fn.curry assign

export default {
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
  set  
}

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
  set
}
