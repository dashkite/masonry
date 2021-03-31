import assert from "assert"
import p from "path"
import {print, test} from "amen"
import * as q from "panda-quill"

# module under test
import * as m from "@dashkite/masonry"
import {coffee} from "@dashkite/masonry/coffee"
import {pug} from "@dashkite/masonry/pug"
import {markdown} from "@dashkite/masonry/markdown"
import {stylus} from "@dashkite/masonry/stylus"
import {yaml} from "@dashkite/masonry/yaml"
import {text} from "@dashkite/masonry/text"

source = p.resolve "test", "files", "input"
build = p.resolve "test", "build"

verify = (filename) ->
  expected = (await q.read p.join source, "..", "output", filename).trim()
  got = (await q.read p.join build, filename).trim()
  assert.equal expected, got

do ->

  print await test "Genie", [

    await test "simple build flow", ->

      await m.rm build

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
        w = m.watch source, -> resolve()
        setTimeout (-> m.exec "touch", [p.join source, "test.z"]), 100
        pr
        w.close()

    test
      description: "server"
      wait: 1000
      ->
        s = m.server build, {}
        assert.equal true, s.listening
        s.close()

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
          await do builder "*.coffee", ".js", coffee "node"
          verify "test.js"

        test "pug", ->
          await do builder "*.pug", ".html", pug
          verify "test.html"

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

      ]
  ]
