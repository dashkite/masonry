import FS from "node:fs/promises"
import Path from "node:path"
import * as Fn from "@dashkite/joy/function"
import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import * as It from "@dashkite/joy/iterable"
import * as Val from "@dashkite/joy/value"
import * as Text from "@dashkite/joy/text"
import chalk from "chalk"
import Glob from "fast-glob"

# we have to format the error because :/
format = ( error ) ->
  if error.stack?
    error
      .stack
      .split "\n"
      .map ( line ) -> line.trim()
      .slice 0, 1
      .join " "
  else
    error.message

# we have to do a transform-specific variation
# of attempt because of the idiosyncractic compositional
# semantics of transforms...
attempt = ( transform ) ->
  ( context ) ->
    try
      await transform context
    catch error
      console.warn chalk.red format error
      context.input

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
  f = Fn.flow fx
  -> await f value for await value from do glob

concurrently = ([ glob, fx... ]) ->
  f = Fn.flow fx
  -> Promise.all ( f value for await value from do glob )
        
glob = ( patterns, options = root: "." ) -> ->
  for path in await _glob patterns, cwd: options.root
    yield {
      root: options.root
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

targetDirectory = ({ source }, target ) ->
  Path.join target, source.directory

targetPath = ( context, target ) ->
  do ({ source, extension } = context ) ->
    directory = targetDirectory context, target
    name = source.name + ( extension ? source.extension )
    Path.join directory, name

write = ( target ) ->
  Fn.tee ( context ) ->
    await FS.mkdir ( targetDirectory context, target ), recursive: true
    FS.writeFile ( targetPath context, target ), context.output

copy = ( target ) ->
  Fn.tee ( context ) ->
    FS.copyFile ( sourcePath context ),
      ( await targetPath target, context )

mtime = ( path ) ->
  try
    stat = await FS.stat path
    stat.mtimeMs
  catch
    0

changed = ( target, fx ) ->
  f = Fn.flow fx
  Fn.tee ( context ) ->
    source = await mtime sourcePath context
    target = await mtime targetPath context, target
    await f context if mtime.source > target

clean = ( target ) ->
  Fn.tee ( context ) ->
    path = Path.join ".masonry", target
    # recursive also makes these idempotent
    await FS.mkdir ".masonry", recursive: true
    # ignore errors because they're probably 
    # just because the files aren't there
    # and if it's anything else it doesn't
    # matter anyway
    try await FS.rm path, recursive: true
    try await FS.rename target, path

export default {
  start
  concurrently
  glob
  read
  readText
  readBytes
  tr
  transform
  attempt
  extension
  write
  copy
  changed
  clean
}

export {
  start
  concurrently
  glob
  read
  readText
  readBytes
  tr
  transform
  attempt
  extension
  write
  changed
  copy
}
