import assert from "assert"
import * as p from "path"
import {print, test} from "amen"
import {start, glob, read, tr, write} from "../src"
import * as q from "panda-quill"

source = p.resolve "test", "files"
build = p.resolve "test", "build"

do ->

  print await test "Genie", [

    test "simple build flow", ->

      await q.rmr build

      await do start [
        glob "*.txt", source
        read
        tr (path, content) -> content + "whose fleece was white as snow."
        write build
      ]

      assert.equal "Mary had a little lamb,\nwhose fleece was white as snow.",
        await q.read p.join build, "poem.txt"

  ]
