import _coffee from "coffeescript"

targets =

  node: ->
    ({source, input}) ->
      _coffee.compile input,
        bare: true
        inlineMap: true
        filename: source.path
        transpile:
          presets: [[
            "@babel/preset-env"
            targets: node: "current"
          ]]

  import: ({mode}) ->
    ({source, input}) ->
      _coffee.compile input,
        bare: true
        inlineMap: mode == "debug"
        filename: source.path
        transpile:
          presets: [[
            "@babel/preset-env"
            # i kid you not...
            targets: esmodules: true
            modules: false
          ]]

coffee = ({mode, target}) -> targets[target] {mode}

export {coffee}
