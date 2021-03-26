import assert from "assert"
import p from "path"
import fs from "fs/promises"
import {print, test} from "amen"
import * as q from "panda-quill"

# module under test
import * as m from "@dashkite/masonry"

source = p.resolve "test", "files"
build = p.resolve "test", "build"

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

      assert.equal "Mary had a little lamb,\nwhose fleece was white as snow.",
        await q.read p.join build, "poem.pm"

    await test "copy", ->

      await do m.start [
        m.glob "*.z", source
        m.copy build
      ]

      # give it a minute
      setTimeout (-> assert.equal true, await q.isFile p.join build, "test.z"),
        100

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
  ]
