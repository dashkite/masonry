import _stylus from "stylus"

stylus = ({root, source, input}) ->
  _stylus input
  .include source.directory
  .include root
  .render()

export {stylus}
