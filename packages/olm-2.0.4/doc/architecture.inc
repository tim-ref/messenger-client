<!-- Copyright (c) 2020 Famedly GmbH -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->
<style>
.olm ul { list-style: none; margin: 0; padding: 0; }
.olm li { position: relative; margin: 0; padding: 0; }
.olm ul.v { display: flex; flex-direction: row; }
.olm ul.h { display: flex; flex-direction: column; }
.olm ul.v > li:not([data-repo=platform]) { flex: 1; }
.olm ul.h > li:not([data-repo=platform]) { flex: 1; }
.olm ul.v > li > ul { height: 100%; }
.olm :not(span).box { display: flex; flex-direction: column; justify-content: center; text-align: center; }
.olm .box { border: 1px solid black; margin: .5em; padding: .8em; }
.olm li::before { content: ""; width: 1px; height: 1.1em; background-color: #000; position: absolute; left: 0; right: 0; bottom: 100%; margin: auto; z-index: -1; }
.olm ul.h > li:not(:last-child) > ul.v > li::before { top: 0; bottom: 0; height: auto; margin: -1.1em auto; }
.olm ul.h > li:first-child::before, .olm ul.h > li:not(.box)::before, .olm ul.h > li:not(.box) + li::before { display: none; }
.olm ul.v > li:not(.box)::before { margin-bottom: -.5em; }
.olm li.box::after { opacity: .6; font-size: .8em; content: attr(data-repo); text-align: right; line-height: 1em; position: absolute; bottom: 0; left: 0; right: 0; }
.olm [data-repo=platform] { background-color: #ddd; }
.olm [data-repo=olm] { background-color: #ffd; }
.olm [data-repo=dart-olm] { background-color: #ddf; }
</style>
<div class="olm">
<ul class="h">
	<li class="box" data-repo="dart-olm">
		Dart Bindings, like JS Bindings (olm.dart)
	<li>
		<ul class="v">
			<li>
				<ul class="h">
					<li class="box" data-repo="dart-olm">
						Dart Bindings Code (native.dart)
					<li class="box" data-repo="dart-olm">
						Dart FFI (ffi.dart)
					<li class="box" data-repo="olm">
						libolm
					<li class="box" data-repo="platform">
						Native
				</ul>
			<li>
				<ul class="h">
					<li class="box" data-repo="dart-olm">
						Dart JS-interop (js.dart)
					<li class="box" data-repo="olm">
						JS Bindings Code
					<li>
						<ul class="v">
							<li class="box" data-repo="olm">
								asm.js<div class="box">libolm</div>
							<li class="box" data-repo="olm">
								WASM<div class="box">libolm</div>
						</ul>
					<li class="box" data-repo="platform">
						JS
				</ul>
		</ul>
</ul>
</div>
