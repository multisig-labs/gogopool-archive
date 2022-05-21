#!/usr/bin/env bash

# This only works for all string params (no address support, etc)
# so not sure how useful it is. Leaving it here to document the technique.

set -Eeuo pipefail

trap 'rm -f -- "${TMPFILE}"' EXIT
TMPFILE=$(mktemp) || exit 1

cat << EOF > ${TMPFILE}
pragma solidity ^0.8.0;
contract Hasher {
	function run() external pure returns (bytes32) {
		return keccak256(abi.encodePacked("${1:-}","${2:-}","${3:-}","${4:-}","${5:-}","${6:-}"));
	}
}
EOF

re='bytes32 (0x[0-9a-f]+)'

[[ `forge run ${TMPFILE}` =~ ${re} ]]
hash=${BASH_REMATCH[1]}

echo ${hash}
