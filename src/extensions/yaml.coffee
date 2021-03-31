import YAML from "js-yaml"

yaml = ({input}) -> JSON.stringify YAML.load input

export {yaml}
