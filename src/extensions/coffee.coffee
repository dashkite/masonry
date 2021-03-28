import _coffee from "coffeescript"

# TODO we could infer the build targets from package.json
coffee = (target) ->
  targets = switch target
    when "node" then node: "current"
    when "browser" then esmodules: true
    else throw new Error "masonry-coffee: unsupported target `#{target}`.
        Supported targets: node, browser."

  ({source, input}) ->
    _coffee.compile input,
      bare: true
      inlineMap: true
      filename: source.path
      transpile:
        presets: [[
          "@babel/preset-env"
          {bugfixes: true, targets}
        ]]

export {coffee}
