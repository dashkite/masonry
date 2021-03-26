import assert from "assert"
import p from "path"
import fs from "fs/promises"
import {print, test} from "amen"
import {start, glob, read, tr, extension, write, copy, rm, watch, exec, server} from "../src"
import * as q from "panda-quill"

source = p.resolve "test", "files"
build = p.resolve "test", "build"

do ->

  print await test "Genie", [

    await test "simple build flow", ->

      await rm build

      await do start [
        glob "*.txt", source
        read
        tr ({path, input}) -> input + "whose fleece was white as snow."
        extension ".pm"
        write build
      ]

      assert.equal "Mary had a little lamb,\nwhose fleece was white as snow.",
        await q.read p.join build, "poem.pm"

    await test "copy", ->

      await do start [
        glob "*.z", source
        copy build
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
        w = watch source, -> resolve()
        setTimeout (-> exec "touch", [p.join source, "test.z"]), 100
        pr
        w.close()

    test
      description: "server"
      wait: 1000
      ->
        s = server build, {}
        assert.equal true, s.listening
        s.close()
  ]
