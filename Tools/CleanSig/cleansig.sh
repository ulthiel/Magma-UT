#!/usr/bin/env bash
# This script removes all the sig files (generated automatically by Magma)
# from the Packages directory.

find ../../Packages/ -type f -name '*.sig' -delete
