#!/bin/sh

ROOT_PATH="./app"
CONTAINER_FOLDER="containers"
COMPONENTS_FOLDER="components"

# Prevent running script without args
if [ $# -eq 0 ]
then
  echo "Error: Missing arguments"
  exit 1
else
  if [[ $1 =~ [^a-zA-Z] ]]
  then
    echo "Error: \"$1\" not a valid component name."
    exit 1
  fi
fi

# Transform long options to short ones
for arg in "$@"
do
  shift
  case "$arg" in
    "--container")
      set -- "$@" "-c"
      ;;
    "--native")
      set -- "$@" "-n"
      ;;
    *)
      set -- "$@" "$arg"
      ;;
  esac
done

FILENAME=$1
NATIVE=false
CONTAINER=false

# loop through all flags in getopts starting at 2 position
OPTIND=2
while getopts "cn" opt
do
  case $opt in
    c)
      echo "Generating files as Container..."
      CONTAINER=true
      ;;
    n)
      echo "Generating react-native files..."
      NATIVE=true
      ;;
    \?)
      echo "Invalid option -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# render a template configuration file
# expand variables + preserve formatting
render_template() {
  eval "echo \"$(cat $1)\""
}


if $CONTAINER
then
  FULL_PATH="$ROOT_PATH/$CONTAINER_FOLDER/$1"
  mkdir -p $FULL_PATH
  render_template ./Container.js >> $FULL_PATH/$1Container.js
else
  FULL_PATH="$ROOT_PATH/$COMPONENTS_FOLDER/$1"
  mkdir -p $FULL_PATH
  render_template ./Container.js >> $FULL_PATH/$1.js
fi

render_template ./Stories.js >> $FULL_PATH/$1.stories.js
render_template ./Spec.js >> $FULL_PATH/$1.spec.js
touch $FULL_PATH/$1.styles.js
