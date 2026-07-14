import assert from "@dashkite/assert"
import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"

import FS from "fs/promises"
import Path from "path"

# module under test
import * as m from "@dashkite/masonry"

do ->

  await FS.mkdir "test/fixtures", recursive: true
  await FS.writeFile "test/fixtures/hello.txt", "hello world"

  print await test "Masonry", [

    test "import", ->
      assert typeof m.start == "function"
      assert typeof m.glob == "function"
      assert typeof m.read == "function"
      assert typeof m.write == "function"

    test "read pipeline", ->
      results = []
      run = m.start [
        m.glob [ "test/fixtures/**/*.txt" ]
        m.readText
        ({input}) -> results.push input
      ]
      await do run
      
      assert.equal results.length, 1
      assert.equal results[0], "hello world"
      
    test "write pipeline", ->
      run = m.start [
        m.glob [ "test/fixtures/**/*.txt" ]
        m.readText
        m.tr ({input}) -> input
        m.extension ".out"
        m.write "test/output"
      ]
      await do run
      
      content = await FS.readFile "test/output/test/fixtures/hello.out", "utf8"
      assert.equal content, "hello world"
      
      await FS.rm "test/output", recursive: true, force: true

  ]

  await FS.rm "test/fixtures", recursive: true, force: true

  process.exit if success then 0 else 1
