import FS from "fs/promises"
import Path from "path"
import YAML from "js-yaml"
import * as Atlas from "@dashkite/atlas"
import * as cheerio from "cheerio"

atlas = (path, map = {}) ->

  ({input}) ->

    # TODO possibly support this interface in Atlas directly?
    pkg = YAML.load await FS.readFile Path.resolve path, "package.json"

    generator = await Atlas.Reference.create pkg.name, "file:#{path}"
    for _name, description of map
      generator.dependencies.add await do ->
        Atlas.Reference.create _name, description

    $ = cheerio.load input
    $ "<script type = 'importmap'>"
      .prependTo "head"
      .text generator.map.toJSON Atlas.jsdelivr

    $.html()

export { atlas }
