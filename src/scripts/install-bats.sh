if ! which git > /dev/null; then
    echo "git is required to install BATS"
    exit 1
fi

cd /tmp || echo "Unable to open /tmp" && exit 1
git clone https://github.com/bats-core/bats-core.git
cd bats-core ||  echo "Failed to open cloned directory" && exit 1
./install.sh /usr/local
if ! which bats > /dev/null; then
    echo "BATS has failed to install."
    exit 1
fi
echo
echo "BATS installed"
echo
