#! /usr/bin/env bash

set -eu

for filename in $(find src -type f); do
    echo $filename
done
