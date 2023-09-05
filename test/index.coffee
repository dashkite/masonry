import assert from "@dashkite/assert"
import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"

import FS from "fs/promises"
import Path from "path"

# module under test
import * as m from "@dashkite/masonry"

do ->

  print await test "Genie Coffee", [

    test "import"

  ]

  process.exit if success then 0 else 1
