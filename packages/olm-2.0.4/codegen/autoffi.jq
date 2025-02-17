#!/usr/bin/env -S jq -nrRf
# Copyright (c) 2020 Famedly GmbH
# SPDX-License-Identifier: AGPL-3.0-or-later

def clean: gsub("/\\*.*\\*/"; "") | sub("/\\*.*$"; "/*");
def count(pat): [scan(pat)] | length;
def balanced: clean | until(count("\\(") == count("\\)") and count("/\\*") == count("\\*/"); . + " " + input | clean);

def translate_native:
   ltrimstr("const ")
 | rtrimstr(" const")
 | (capture("(?<x>.*[^ ]) *\\*$") | "Pointer<\(.x | translate_native | sub("^Void$"; "Uint8"))>")
// (capture("^void$") | "Void")
// (capture("^char$") | "Utf8")
// (capture("^int$") | "Int32")
// (capture("^size_t$") | "IntPtr")
// (capture("^uint(?<w>[0-9]+)_t$") | "Uint" + .w)
// (capture("^int(?<w>[0-9]+)_t$") | "Int" + .w)
// "NativeType";

def translate:
  .type = (.type | sub("^ +"; "") | sub(" +$"; ""))
| .ntype = (.type | translate_native)
| .dtype = (.ntype | sub("^((Uint|Int)([0-9]+|Ptr))$"; "int") | sub("^Void$"; "void"));

def error_func:
  if type == "string" then
    capture("(const )?(?<type>.*[^ ]) *\\*$")
  | .type
  | rtrimstr(" const")
  | gsub("(?<ch>[A-Z]+)"; "_\(.ch | ascii_downcase)")
  | ltrimstr("_")
  | "\(.)_last_error"
  else
    null
  end;

def printfun: "
final \(.internalname) = libolm.lookupFunction<
  \(.ntype) Function(\(.args | map("\(.ntype) \(.name)") | join(", "))),
  \(.dtype) Function(\(.args | map("\(.dtype) \(.name)") | join(", ")))
>('\(.name)');";

def wrapperfun: "
\(.dtype) \(.name)(\(.args | map("\(.dtype) \(.name)") | join(", "))) {
  int result = \(.internalname)(\(.args | map(.name) | join(", ")));
  if (result == olm_error()) throw_olm(\(.error_func)(\(.args[0].name)));
  return result;
}";

"// Auto-generated file.

import 'ffi_base.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';",

( inputs
| balanced
| capture("(?<type>[^(]*[ *])(?<name>[^ (*]*) *\\((?<args>|[^(].*[^)])\\);")
| .args |= (sub("^ *void *$"; "") | split(",") | map(capture("(?<type>.*[ *])(?<name>[^ *]+)") | translate))
| translate
| .error_func = (if .type == "size_t" then .args[0].type | error_func else null end)
| if .error_func then
    .internalname = "_\(.name)_unchecked" | wrapperfun, printfun
  else
    .internalname = .name | printfun
  end
)
