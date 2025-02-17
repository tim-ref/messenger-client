#!/usr/bin/env -S jq -nrRf
# Copyright (c) 2020 Famedly GmbH
# SPDX-License-Identifier: AGPL-3.0-or-later

"// Auto-generated file.

@JS('Olm')
library js;

import 'package:js/js.dart';
import 'dart:async';
import 'dart:js_util';
import 'dart:typed_data';

@JS(\"init\")
external dynamic _init();

Future<void> init() {
  return promiseToFuture(_init());
}",

def count(pat): [scan(pat)] | length;

foreach( foreach(
    {s: inputs}
  | until(.s | test("^\\s*///[^\n]*$") | not; .pre += .s + "\n" | .s = input)
  | select(.s | test("^\\s*//") | not)
  | .s |= sub("\\s*//.*$"; "")
) as $l ({c: 0};
    if .p then del(.p, .s) else . end | if .co then . else
        if .s then .s += "\n" + $l.s else $l + {c} end
      | if .s | count("\\(") == count("\\)") and (test("\\)\\s*(async)?\\s*$") | not) then
            .s |= sub("\\s*extends +[^ ]*"; "")
          | .s |= sub("\\s*: +[^{;]*"; "")
          | if .s | (test("\\)\\s*(async)?\\s*[{;]") or test("[ .]_")) then
                .s |= (sub("\\s*{.*$"; ";") | sub("^(?<sp>\\s*)"; .sp + "external "))
              | .co = .c
              | (.m1, .m2) = if .pre then 1 else 2 end
            else . end
          | if .s | test("{$") then .m2 = 4 else . end
          | if .s | test("}$") then .m1 = 4 else . end
          | if .c == 0 and .m2 then
              .pre += (.s | capture("^(?<sp>\\s*)") | .sp + "@JS()\n")
            else . end
          | .p = true
        else . end
    end
  | .c += ($l.s | count("{") - count("}"))
  | if .c == .co then del(.co) else . end
; if .p then
    if .s | test("^import|[ .]_|Future<|Pointer<") then {} else . end
  else empty end)
) as $x ({};
  if $x.s then
    if $x.s != "" then
      {p: (if $x.m1 + .nlm > 3 then null else .nl end + $x.pre + $x.s)}
    else
      {nl: "\n", nlm: .m2, m2r: .m2}
    end | .m2 = $x.m2
  else
    del(.p) | .m2 = ([.m2, .m2r] | max)
  end
; .p // empty)
