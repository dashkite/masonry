import Pug from "pug"
import {coffee} from "./coffee"
import {stylus} from "./stylus"
import {markdown} from "./markdown"
import {yaml} from "./yaml"

adapter = (c, f) -> (input) -> f {c..., input}

pug =
  render: ({ root, source, input, data }) ->
    Pug.render input,
      filename: source?.path
      basedir: root
      # TODO make it possible to write to the data attribute
      data: data
      filters:
        coffee: adapter {root, source}, coffee.browser mode: "production"
        markdown: adapter {root, source}, markdown
        stylus: adapter {root, source}, stylus
        yaml: adapter {root, source}, yaml

  # default compile for browser
  # for backward compatibility
  compile: compile = ({ root, source, input }) ->
    f = Pug.compileClient input,
      filename: source?.path
      basedir: root
      filters:
        coffee: adapter {root, source}, coffee.browser mode: "production"
        markdown: adapter {root, source}, markdown
        stylus: adapter {root, source}, stylus
        yaml: adapter {root, source}, yaml
    "#{f}\nexport default template"

  browser: { compile }

  node:
    compile: ({ root, source, input }) ->
      f = Pug.compileClient input,
        filename: source?.path
        basedir: root
        filters:
          coffee: adapter {root, source}, coffee.browser mode: "production"
          markdown: adapter {root, source}, markdown
          stylus: adapter {root, source}, stylus
          yaml: adapter {root, source}, yaml
      "#{f}\nmodule.exports = template;"


export {pug}
