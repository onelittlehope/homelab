#!/usr/bin/env bash

set -o errexit          # -e: Exit on error. Append "|| true" if you expect an error.
set -o errtrace         # -E: Exit on error inside any functions or sub shells.
set -o nounset          # -u: Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR.
set -o pipefail         # Use last non-zero exit code in a pipeline.

if [ "$EUID" -ne 0 ]; then
  log_error "Please run this script as 'root'"
  exit 1
fi

echo "Refreshing apt repository list"

DEBIAN_FRONTEND=noninteractive apt-get --quiet --assume-yes clean
DEBIAN_FRONTEND=noninteractive apt-get --quiet --assume-yes update

echo "Installing Ansible + dependencies"

DEBIAN_FRONTEND=noninteractive apt-get --quiet --assume-yes install \
  acl \
  ansible \
  apt-transport-https \
  aptitude \
  git \
  python3-apt \
  python3-github \
  python3-gitlab \
  sudo

echo "Setting up ansible-pull"

mkdir -p "/var/log/ansible"

ANSIBLE_HOST_PATTERN_MISMATCH="ignore"
export ANSIBLE_HOST_PATTERN_MISMATCH

ANSIBLE_LOG_PATH="/var/log/ansible/ansible.log"
export ANSIBLE_LOG_PATH

ANSIBLE_PYTHON_INTERPRETER="/usr/bin/python3"
export ANSIBLE_PYTHON_INTERPRETER

echo "Calling ansible-pull"

ansible-pull --url "https://github.com/onelittlehope/homelab.git"
