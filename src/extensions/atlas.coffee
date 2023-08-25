import Path from "path"
import * as Atlas from "@dashkite/atlas"
# import { getDomain } from "@dashkite/drn"
import * as cheerio from "cheerio"

atlas = ( entries, map ) ->

  ({input}) ->
    
    console.log "masonry: atlas: generating import map"

    $ = cheerio.load input
    map = $ "<script type = 'importmap'>"
      .text JSON.stringify ( await Atlas.generate entries, map ), null, 2

    console.log "masonry: atlas: injecting import map into HTML"

    if (target = $ "script[type='importmap']").length > 0
      target.replaceWith map
    else
      $ "head"
        .prepend map

    console.log "masonry: atlas: rendering modified HTML"
    result = $.html()
    console.log "masonry: atlas: completed"
    result


export { atlas }
