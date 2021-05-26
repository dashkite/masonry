import * as Atlas from "@dashkite/atlas"
import * as cheerio from "cheerio"

atlas = (name, map) ->

  ({input}) ->

    generator = await Atlas.Reference.create name, "file:."
    for _name, description of map
      generator.dependencies.add await do ->
        Atlas.Reference.create _name, description

    $ = cheerio.load input
    $ "<script type = 'importmap'>"
      .prependTo "head"
      .text generator.map.toJSON Atlas.jsdelivr

    $.html()

export { atlas }
