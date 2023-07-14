#!/bin/bash
#
# This script should be run on the hypervisor to set up storage pool for VMs.

set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPTDIR}/common.sh"

usage() {
    cat - <<EOF
${BASH_SOURCE[0]} (create|cleanup)

  -h           Show this help.

create: Set up a storage pool with the given name and dir. Uses
        variables VM_STORAGE_POOL and VM_DISK_DIR.

cleanup: Remove storage pool rules created by 'create' command.

EOF
}

action_create() {
    sudo sh -c '
virsh pool-define-as '"${VM_STORAGE_POOL}"' dir --target '"${VM_DISK_DIR}"'
virsh pool-build '"${VM_STORAGE_POOL}"'
virsh pool-start '"${VM_STORAGE_POOL}"'
'
}

action_cleanup() {
    sudo sh -c '
virsh pool-destroy '"${VM_STORAGE_POOL}"'
virsh pool-undefine '"${VM_STORAGE_POOL}"'
'
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi
action="${1}"
shift

case "${action}" in
    create|cleanup)
        "action_${action}" "$@"
        ;;
    -h)
        usage
        exit 0
        ;;
    *)
        usage
        exit 1
        ;;
esac
