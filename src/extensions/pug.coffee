import Pug from "pug"
import {coffee} from "./coffee"
import {stylus} from "./stylus"
import {markdown} from "./markdown"
import {yaml} from "./yaml"

adapter = (c, f) -> (input) -> f {c..., input}

pug = ({ root, source, input }) ->
  Pug.render input,
    filename: source.path
    basedir: root
    filters:
      coffescript: adapter {root, source}, coffee
      markdown: adapter {root, source}, markdown
      stylus: adapter {root, source}, stylus
      yaml: adapter {root, source}, yaml

export {pug}
