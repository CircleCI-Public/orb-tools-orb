if [[ $EUID == 0 ]]; then export SUDO=""; else export SUDO="sudo"; fi
wget https://github.com/mikefarah/yq/releases/download/3.2.1/yq_linux_386
$SUDO mv yq_linux_386 /usr/local/bin/yq
$SUDO chmod +x /usr/local/bin/yq