// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:shared/shared.dart';

class FullScreenZoomableMediaViewer extends StatelessWidget {
  const FullScreenZoomableMediaViewer({
    super.key,
    required this.media,
    this.initialIndex = 0,
  });

  final List<Media> media;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(initialPage: initialIndex);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PageView.builder(
        controller: pageController,
        itemCount: media.length,
        itemBuilder: (context, index) {
          final currentMedia = media[index];

          if (currentMedia.isVideo) {
            // Do not wrap in InteractiveViewer, just play video
            return Center(
              child: InlineVideo(
                videoSettings: VideoSettings.build(
                  videoUrl: currentMedia.url,
                  shouldPlay: true,
                  blurHash: currentMedia.blurHash,
                  aspectRatio: 9 / 16,
                  withSound: true,
                ),
              ),
            );
          } else {
            // Allow zoom and pan for images only
            return InteractiveViewer(
              maxScale: 4,
              minScale: 1,
              panEnabled: true,
              child: Center(
                child: Image.network(
                  currentMedia.url,
                  fit: BoxFit.contain,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
