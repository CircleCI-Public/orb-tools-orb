#! /bin/bash
# Reduce nested commands and jobs to files under src/commands or src/jobs so they can be packed by 'circleci orb pack src/'.
# Allows you to group collections of commands under directories.

# Directory under which prepack directories reside.
SRC="${1:-src}"

# The subdirectory to prepack.
TYP="${2:-commands}"

pre-pack()
{
    local current_directory="$1"
    local d

    cd "$current_directory" || exit 1
    pwd

    find . -maxdepth 1 -mindepth 1 -type d -print0 | xargs --null -I % basename % | while read -r d; do
        if [ -n "$(ls "${d}")" ]; then
            # Drop one level below before processing all of the files and pack those sub-subdirectories into the current subdirectory.
            pre-pack "$d"
            find "$d" -maxdepth 1 -mindepth 1 -type f -print0 | xargs --null -I % basename % | while read -r f; do
                fname="$(basename "$f")"
                if [ ! -f "${d}-${fname}" ]; then
                    cp "${d}/${f}" "${d}-${fname}"
                fi
            done
        else
            printf "INFO: Ignoring '%s', module is empty.\\n" "${SRC}/${TYP}/${d}"
        fi
    done

    cd ..

    return 0
}

pre-pack "$SRC/$TYP/"
