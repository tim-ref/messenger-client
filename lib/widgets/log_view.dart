/*
 * Modified by akquinet GmbH on 16.10.2023
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

class LogViewer extends StatefulWidget {
  const LogViewer({Key? key}) : super(key: key);

  @override
  LogViewerState createState() => LogViewerState();
}

class LogViewerState extends State<LogViewer> {
  Level logLevel = Level.debug;
  double fontSize = 14;
  @override
  Widget build(BuildContext context) {
    final outputEvents = Logs()
        .outputEvents
        .where((e) => e.level.index <= logLevel.index)
        .toList();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(logLevel.toString()),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in_outlined),
            onPressed: () => setState(() => fontSize++),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out_outlined),
            onPressed: () => setState(() => fontSize--),
          ),
          PopupMenuButton<Level>(
            itemBuilder: (context) => Level.values
                .map(
                  (level) => PopupMenuItem(
                    value: level,
                    child: Text(level.toString()),
                  ),
                )
                .toList(),
            onSelected: (Level level) => setState(() => logLevel = level),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: outputEvents.length,
        itemBuilder: (context, i) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SelectableText(
            outputEvents[i].toDisplayString(),
            style: TextStyle(
              color: outputEvents[i].color,
            ),
          ),
        ),
      ),
    );
  }
}

extension on LogEvent {
  Color get color {
    switch (level) {
      case Level.wtf:
        return Colors.purple;
      case Level.error:
        return Colors.red;
      case Level.warning:
        return Colors.orange;
      case Level.info:
        return Colors.green;
      case Level.debug:
        return Colors.white;
      case Level.verbose:
      default:
        return Colors.grey;
    }
  }

  String toDisplayString() {
    var str = '# [${level.toString().split('.').last.toUpperCase()}] $title';
    if (exception != null) {
      str += ' - ${exception.toString()}';
    }
    if (stackTrace != null) {
      str += '\n${stackTrace.toString()}';
    }
    return str;
  }
}
