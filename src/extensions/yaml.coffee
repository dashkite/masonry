import YAML from "js-yaml"

Presets =
  
  json: ({ input }) -> JSON.stringify YAML.load input

  js: ({ build, input }) -> 
    json = JSON.stringify YAML.load input
    switch build.target
      when "browser" then "export default #{ json }"
      when "node" then "module.exports = #{ json }"

yaml = ( context ) ->
  if ( preset = Presets[ context.build.preset ])?
    preset context
  else
    throw new Error "masonry: unknown YAML preset #{ context.build.preset }"

export { yaml }
