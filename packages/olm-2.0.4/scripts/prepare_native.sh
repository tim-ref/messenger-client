#!/bin/sh -e
# Copyright (c) 2020 Famedly GmbH
# SPDX-License-Identifier: AGPL-3.0-or-later

cd "$(dirname "$0")"/..
ldconfig -p | grep -wF libolm.so.3 && exit
mkdir native
cd native
git clone --depth 1 https://gitlab.matrix.org/matrix-org/olm.git
cd olm
cmake -DCMAKE_BUILD_TYPE=Release .
cmake --build .
