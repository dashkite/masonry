import FS from "fs/promises"
import Path from "path"
import YAML from "js-yaml"
import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import * as Text from "@dashkite/joy/text"
import * as Atlas from "@dashkite/atlas"
import * as cheerio from "cheerio"

deliver = generic
  name: "deliver"
  description: "Generate Import Map URLs"
  default: ({ name, version }) ->
    "https://cdn.jsdelivr.net/npm/#{name}@#{version}/"

generic deliver, Type.isString, ( name ) ->
  "https://cdn.jsdelivr.net/npm/#{name}/"


generic deliver, ( Type.isKind Atlas.FileReference ), ( reference ) ->
  { name } = reference
  if Text.startsWith "@", name
    name = name[1..]
  "https://modules.dashkite.com/#{name}/"

generic deliver, ( Type.isKind Atlas.Scope ), ({ reference }) -> deliver reference

generic deliver, ( Type.isKind Atlas.ParentScope ), ({ reference }) ->
  # hacky AF but just need to get this working
  # amounts to a no-op for file references
  ( deliver reference ).replace "@#{ reference.version }", ""

atlas = (path, root = ".", map = {}) ->

  ({input}) ->

    # TODO possibly support this interface in Atlas directly?
    pkg = YAML.load await FS.readFile Path.resolve path, "package.json"

    generator = await Atlas.Reference.create pkg.name, "file:#{path}"
    generator.root = root
    for _name, description of map
      generator.dependencies.add await do ->
        Atlas.Reference.create _name, description

    $ = cheerio.load input

    map = $ "<script type = 'importmap'>"
      .text generator.map.toJSON deliver

    if (target = $ "script[type='importmap']").length > 0
      target.replaceWith map
    else
      $ "head"
        .prepend map

    $.html()

export { atlas }
