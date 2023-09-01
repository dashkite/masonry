import Pug from "pug"

import { coffee } from "./coffee"
import { stylus } from "./stylus"
import { markdown } from "./markdown"
import { yaml } from "./yaml"

embed = ( target, code ) ->
  switch target
    when "browser"
      "#{code}\nexport default template"
    when "node"
      "#{code}\nmodule.exports = template;"

js = ({ root, source, input, build }) ->
  embed build.target, Pug.compileClient input,
    filename: source?.path
    basedir: root
    filters:
      coffee: ( input ) -> coffee { root, source }
      markdown: ( input ) -> markdown { root, source }
      stylus: ( input ) -> stylus { root, source }
      yaml: ( input ) -> yaml { root, source }

html = ({ root, source, input, data }) ->
  Pug.render input,
    filename: source?.path
    basedir: root
    # TODO make it possible to write to the data attribute
    data: data
    filters:
      coffee: ( input ) -> coffee { root, source }
      markdown: ( input ) -> markdown { root, source }
      stylus: ( input ) -> stylus { root, source }
      yaml: ( input ) -> yaml { root, source }

Presets = { html, js }

pug = ( context ) ->
  if ( preset = Presets[ context.build.preset ])?
    await preset context
  else
    throw new Error "masonry: unknown Pug preset #{ context.build.preset }"

export { pug }
