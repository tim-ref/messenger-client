/*
 * Modified by akquinet GmbH on 10.04.2024
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/widgets/mxc_image.dart';
import 'image_viewer.dart';

class ImageViewerView extends StatelessWidget {
  final ImageViewerController controller;

  const ImageViewerView(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          key: const ValueKey("closeImageViewerButton"),
          icon: const Icon(Icons.close),
          onPressed: Navigator.of(context).pop,
          color: Colors.white,
          tooltip: L10n.of(context)!.close,
        ),
        backgroundColor: const Color(0x44000000),
        actions: [
          IconButton(
            icon: const Icon(Icons.reply_outlined),
            onPressed: controller.forwardAction,
            color: Colors.white,
            tooltip: L10n.of(context)!.share,
          ),
          if (!PlatformInfos.isIOS)
            IconButton(
              key: const ValueKey("imageDownloadButton"),
              icon: const Icon(Icons.download_outlined),
              onPressed: () => controller.saveFileAction(context),
              color: Colors.white,
              tooltip: L10n.of(context)!.downloadFile,
            ),
          if (PlatformInfos.isMobile)
            // Use builder context to correctly position the share dialog on iPad
            Builder(
              builder: (context) => IconButton(
                onPressed: () => controller.shareFileAction(context),
                tooltip: L10n.of(context)!.share,
                color: Colors.white,
                icon: Icon(Icons.adaptive.share_outlined),
              ),
            ),
        ],
      ),
      body: InteractiveViewer(
        minScale: 1.0,
        maxScale: 10.0,
        onInteractionEnd: controller.onInteractionEnds,
        child: Center(
          child: Hero(
            tag: controller.widget.event.eventId,
            child: MxcImage(
              event: controller.widget.event,
              fit: BoxFit.contain,
              isThumbnail: false,
              animated: true,
            ),
          ),
        ),
      ),
    );
  }
}
