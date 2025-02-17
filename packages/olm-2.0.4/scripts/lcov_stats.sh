#!/bin/sh -e
awk -F: '$1=="LF" {lf+=$2} $1=="LH" {lh+=$2} END {printf("lines: %.1f%% (%d of %d lines)\n", lh/lf*100, lh, lf)}' "$@"
