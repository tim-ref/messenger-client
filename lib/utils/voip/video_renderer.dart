/*
 * Modified by akquinet GmbH on 21.11.2024
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 *   Famedly
 *   Copyright (C) 2019, 2020, 2021 Famedly GmbH
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU Affero General Public License as
 *   published by the Free Software Foundation, either version 3 of the
 *   License, or (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *   GNU Affero General Public License for more details.
 *
 *   You should have received a copy of the GNU Affero General Public License
 *   along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:matrix/matrix.dart';

class VideoRenderer extends StatefulWidget {
  final WrappedMediaStream? stream;
  final bool mirror;
  final RTCVideoViewObjectFit fit;

  const VideoRenderer(
    this.stream, {
    this.mirror = false,
    this.fit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _VideoRendererState();
}

class _VideoRendererState extends State<VideoRenderer> {
  RTCVideoRenderer? _renderer;
  bool _rendererReady = false;
  MediaStream? get mediaStream => widget.stream?.stream;
  StreamSubscription? _streamChangeSubscription;

  Future<RTCVideoRenderer> _initializeRenderer() async {
    _renderer ??= RTCVideoRenderer();
    await _renderer!.initialize();
    _renderer!.srcObject = mediaStream;
    return _renderer!;
  }

  void disposeRenderer() {
    try {
      _renderer?.srcObject = null;
      _renderer?.dispose();
      _renderer = null;
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  void initState() {
    _streamChangeSubscription = widget.stream?.onStreamChanged.stream.listen((stream) {
      setState(() {
        _renderer?.srcObject = stream;
      });
    });
    setupRenderer();
    super.initState();
  }

  Future<void> setupRenderer() async {
    await _initializeRenderer();
    setState(() => _rendererReady = true);
  }

  @override
  void dispose() {
    _streamChangeSubscription?.cancel();
    disposeRenderer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => !_rendererReady
      ? Container()
      : Builder(
          key: widget.key,
          builder: (ctx) {
            return RTCVideoView(
              _renderer!,
              mirror: widget.mirror,
              filterQuality: FilterQuality.medium,
              objectFit: widget.fit,
              placeholderBuilder: (_) => Container(color: Colors.white.withOpacity(0.18)),
            );
          },
        );
}
