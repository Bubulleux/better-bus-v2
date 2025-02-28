import 'package:better_bus_core/core.dart';
import 'package:flutter/material.dart';

class GtfsDownloadIndicator extends StatefulWidget {
  const GtfsDownloadIndicator({
    required this.downloader,
    this.width = 100,
    this.height = 20,
    this.onDone,
    super.key,
  });

  final double width;
  final double height;
  final GTFSDataDownloader downloader;
  final void Function()? onDone;

  @override
  State<GtfsDownloadIndicator> createState() => _GtfsDownloadIndicatorState();
}

class _GtfsDownloadIndicatorState extends State<GtfsDownloadIndicator> {
  double progress = 0;

  @override
  void initState() {
    super.initState();
    download();
  }

  Future<void> download() async {
    if (progress != 0) return;
    await widget.downloader.forceDownload(
      onProgress: (value) => setState(() {
        progress = value;
      })
    );
    widget.onDone?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.black12, 
        borderRadius: BorderRadius.circular(5)
      ),
      width: widget.width,
      height: widget.height,
      child: Transform.scale(
        alignment: Alignment.centerLeft,
        scaleX: progress,
        child:
          Container(
            color: Theme.of(context).colorScheme.primary,
          ),

      ),
    );
  }
}
