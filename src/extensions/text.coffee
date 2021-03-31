text = ({ input }) ->
  # based on webpack raw-loader
  # https://github.com/webpack-contrib/raw-loader/blob/master/src/index.js
  json = JSON.stringify input
          .replace /\u2028/g, '\\u2028'
          .replace /\u2029/g, '\\u2029'
  "export default #{json}"

export {text}
