#!/bin/sh -e
# Copyright (c) 2020 Famedly GmbH
# SPDX-License-Identifier: AGPL-3.0-or-later

cd "$(dirname "$0")"/..
codegen/autojs.jq < lib/src/native.dart > lib/src/js.dart
printf '#include "%s"\n' olm/{olm,sas,pk}.h | gcc -I native/olm/include -E - | awk '/^#/{f=/\Wolm\//;next};f' | codegen/autoffi.jq > lib/src/ffi.dart
