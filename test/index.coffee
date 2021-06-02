import assert from "assert"
import FS from "fs/promises"
import Path from "path"
import {print, test} from "amen"
import * as _ from "@dashkite/joy"

# module under test
import * as m from "@dashkite/masonry"
import {coffee} from "@dashkite/masonry/coffee"
import {pug} from "@dashkite/masonry/pug"
import {markdown} from "@dashkite/masonry/markdown"
import {stylus} from "@dashkite/masonry/stylus"
import {yaml} from "@dashkite/masonry/yaml"
import {text} from "@dashkite/masonry/text"
import {atlas} from "@dashkite/masonry/atlas"

source = Path.resolve "test", "files", "input"
build = Path.resolve "test", "build"

verify = (filename) ->
  paths =
    source: Path.join source, "..", "output", filename
    build: Path.join build, filename
  expected = _.trim await FS.readFile paths.source, "utf8"
  got = _.trim await FS.readFile paths.build, "utf8"
  assert.equal expected, got

do ->

  print await test "Genie", [

    await test "simple build flow", ->

      await do m.rm build

      await do m.start [
        m.glob "*.txt", source
        m.read
        m.tr ({path, input}) -> input + "whose fleece was white as snow."
        m.extension ".pm"
        m.write build
      ]

      verify "poem.pm"

    await test "copy", ->

      await do m.start [
        m.glob "*.z", source
        m.copy build
      ]

      # give it a minute
      setTimeout (-> verify "test.z"), 100

    test
      description: "watch, exec"
      wait: 1000
      ->
        resolve = undefined
        pr = new Promise (_resolve) -> resolve = _resolve
        w = do m.watch source, -> resolve()
        setTimeout (m.exec "touch", [Path.join source, "test.z"]), 100
        pr
        w.close()

    test "Extensions", do ->

      builder = (pattern, extension, transform) ->
        m.start [
          m.glob pattern, source
          m.read
          m.tr transform
          m.extension extension
          m.write build
        ]

      [

        test "coffee", ->
          await do builder "*.coffee", ".js", do coffee.node
          verify "test.js"

        test "pug", [

          test "render", ->
            await do builder "*.pug", ".html", pug.render
            verify "test.html"

          test "compile", ->
            await do builder "*.pug", ".pug.js", pug.compile
            verify "test.pug.js"

        ]

        test "stylus", ->
          await do builder "*.styl", ".css", stylus
          verify "test.css"

        test "yaml", ->
          await do builder "*.yaml", ".json", yaml
          verify "test.json"

        test "markdown", ->
          await do builder "*.md", ".md.html", markdown
          verify "test.md.html"

        test "text", ->
          await do builder "*.txt", ".txt.js", text
          verify "test.txt.js"

        test "composition", ->
          await do builder "*.styl", ".css.js", [ stylus, text ]
          verify "test.css.js"

        # we test against another project (../navigate)
        # because masonry has a ton of dependencies
        # and breaks atlas
        test description: "atlas", wait: false, ->
          await do builder "*.pug", ".html",
            [ pug.render, atlas "../navigate" ]
          verify "test-with-import-map.html"


      ]
  ]
