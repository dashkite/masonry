json = ({ input }) ->
  # based on webpack raw-loader
  # https://github.com/webpack-contrib/raw-loader/blob/master/src/index.js
  "export default #{input}"

export { json }
