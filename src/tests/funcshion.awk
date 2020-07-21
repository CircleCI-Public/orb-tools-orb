## A utility written by @ryanwohara
## Utility will parse a given shell script, create a directory based on its name,
## and write a file for each function within that shell script.
## https://github.com/ryanwohara/funcshion

BEGIN {
  split(ARGV[ARGC-1], directoryNameSplit, "/")
  split(directoryNameSplit[length(directoryNameSplit)], fileNameSplit, ".")
  dirPath = length(path) ? path : ENVIRON["PWD"]
  dirName = length(subdir) ? subdir : fileNameSplit[1]
  outputDirectory = dirPath "/" dirName
  system("mkdir -p " outputDirectory)
}

match($0, /^((func(tion)?)?\s*?\w+)\s*?(\(.*?\))?\s*?{/, matched) {
  if ( sub(/func(tion)? /, "", matched[1]) ) {
    functionName = $2
  }
  else {
    functionName = $1
  }
  sanitizedName = tolower(/\S\(\)/ ? substr(functionName, 1, length(functionName)-2) : functionName)
  inFunction = 1
}

inFunction {
  concat = functionBody ~ /^$/ ? "" : functionBody "\n"
  functionBody = concat $0
}

/^}$/ {
  inFunction = 0
  print functionBody > outputDirectory "/" sanitizedName
  functionBody = ""
}