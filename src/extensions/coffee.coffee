import _coffee from "coffeescript"

coffee = (target) ->
  targets = switch target
    when "node" then node: "current"
    when "web" then esmodules: true
    else throw new Error "masonry-coffee: unsupported target `#{target}`.
        Supported targets: node, web."

  ({path, input}) ->
    _coffee.compile input,
      bare: true
      inlineMap: true
      filename: path
      transpile:
        presets: [[
          "@babel/preset-env"
          {bugfixes: true, targets}
        ]]

export {coffee}
