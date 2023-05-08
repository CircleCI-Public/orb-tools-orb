#!/bin/bash
ORB_DIR=${ORB_VAL_ORB_DIR%/}
# In order to support the possibility of multiple orbs, but with the limitation of requiring a single path to persist to a workspace
# we will first tar the orb source to a single binary file, then untar it to the workspace.

tar_source() {
  TMP_SRC_DIR=$(mktemp -d)
  tar -czf "${TMP_SRC_DIR}/orb_source.tar.gz" -C "${ORB_DIR}" .
  rm -rf "${ORB_DIR}"
  mkdir -p "${ORB_DIR}"
  mv "${TMP_SRC_DIR}/orb_source.tar.gz" "${ORB_DIR}/orb_source.tar.gz"
  rm -rf "${TMP_SRC_DIR}"
}

untar_source() {
  TMP_SRC_DIR=$(mktemp -d)
  tar -xzf "${ORB_DIR}/orb_source.tar.gz" -C "${TMP_SRC_DIR}"
  rm -rf "${ORB_DIR}"
  mkdir -p "${ORB_DIR}"
  mv "${TMP_SRC_DIR}/"* "${ORB_DIR}/"
  rm -rf "${TMP_SRC_DIR}"
}

if [[ $ORB_VAL_TAR == '1' ]]; then
  printf "Creating tarball of orb source.\n"
  tar_source
  pwd
  ls -la "${ORB_DIR}"
fi
if [[ $ORB_VAL_UNTAR == '1' ]]; then
  printf "Extracting tarball of orb source.\n"
  untar_source
  pwd
  ls -la "${ORB_DIR}"
fi
