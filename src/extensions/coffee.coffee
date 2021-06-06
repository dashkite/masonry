import _coffee from "coffeescript"

coffee =

  node: ->
    ({source, input}) ->
      _coffee.compile input,
        bare: true
        inlineMap: true
        filename: source?.path
        transpile:
          filename: source?.path
          plugins: [
            [ require "babel-plugin-add-import-extension", {} ]
          ]
          presets: [
            [
              require "@babel/preset-env"
              targets: node: "current"
            ]
          ]

  browser: ({mode}) ->
    ({source, input}) ->
      _coffee.compile input,
        bare: true
        inlineMap: mode == "debug"
        filename: source?.path
        transpile:
          filename: source?.path
          plugins: [
            [require "babel-plugin-add-import-extension", {}]
          ]
          presets: [[
            require "@babel/preset-env"
            targets:
              "last 2 chrome versions,
                last 2 firefox versions,
                last 2 safari versions,
                last 2 ios_saf versions"
            modules: false
          ]]

export { coffee }
