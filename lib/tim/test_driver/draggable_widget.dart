/*
 * TIM-Referenzumgebung
 * Copyright (C) 2024 - akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';

class DraggableWidget extends StatefulWidget {
  final Widget child;

  const DraggableWidget({required this.child, Key? key}) : super(key: key);

  @override
  State<DraggableWidget> createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget> {
  double width = 100.0, height = 100.0;
  Offset position = const Offset(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    position = const Offset(0.0, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Draggable(
            feedback: Align(
              alignment: Alignment.center,
              child: Container(
                color: Colors.black12,
                child: Center(
                  child: Text(
                    "drop me",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
            ),
            onDraggableCanceled: (Velocity velocity, Offset offset) {
              setState(() => position = offset);
            },
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
