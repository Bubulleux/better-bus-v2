import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> with 
  SingleTickerProviderStateMixin {
  late DateTime start;
  DateTime get end => start.add(Duration(hours: 1));
  Offset? drag;
  double? imgScale;

  late AnimationController controlleur;

  @override
  void initState() {
    super.initState();
    start = DateTime.now().add(Duration(minutes: -5));
    controlleur = AnimationController(
    duration: Duration(seconds: 4),
    vsync: this)..repeat();
    controlleur.addListener(() => setState(() {}));
  }

  @override
    void dispose() {
      controlleur.dispose();
      super.dispose();
    }

  Widget buildTime(DateTime time) {
    final dateStr = DateFormat("dd/MM/yy").format(time);
    final timeStr = DateFormat.Hm().format(time);
    return Column(
      children: [
        Text(dateStr,
          style: TextStyle(
            fontSize: 33,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 5,),
        Text(timeStr,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget buildBalls() {
    final r = controlleur.value * 2 * pi;
    Widget ball(Color c) => Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(100)
      ),
    );

    return Transform.rotate(angle: r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ball(Color(0xffB27D60)),
          SizedBox(width: 150,),
          ball(Color(0xff69401A)),
        ],
      ),
    );
  }
  
  void dragUpdate(DragUpdateDetails detail) {
    setState(() {
      drag = detail.globalPosition;
    });
  }

  void stopDrag(DragEndDetails _) {
    setState(() {
      drag = null;
    });
  }


  @override
  Widget build(BuildContext context) {
    final img = AssetImage("assets/images/ticket.png");
    if (imgScale == null) {
      img.resolve(ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info, _) {
          final scale = info.image.width / info.image.height;
          
          print("Scale changed  $scale");
          setState(() => imgScale = scale);
      }));
    }

    // TODO: Sory fot that code...
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red,
                image: DecorationImage(
                  image: img,
                  fit: BoxFit.fitHeight,
                  repeat: ImageRepeat.repeat,
                ),
              ),
              child: AspectRatio(
                aspectRatio: imgScale ?? 1,
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: SizedBox(
                    height: 1000,
                    child: Column(
                      children: [
                        Flexible(
                          flex: 7,
                          child: Column(
                            children: [
                              SizedBox(height: 270,),
                              drag == null ? buildBalls() : Container(),
                            ],
                          ),
                    
                        ),
                        Flexible(
                          flex: 4,
                          child: 
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  buildTime(start),
                                  SizedBox(width: 50,),
                                  buildTime(end),
                                ],
                              ),
                              SizedBox(height: 70,),
                              buildTime(end)
                            ],
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              width: 80,
              height: 80,
              child: GestureDetector(onTap: Navigator.of(context).pop,),
            ),
            Positioned.fill(child: GestureDetector(onPanUpdate: dragUpdate,onPanEnd: stopDrag,)),
            drag != null ?
            Positioned(
              top: drag!.dy,
              left: drag!.dx - (250 / 2),
              child: buildBalls(),
            ) : Container(),
          ],
        ),
      ),
    );
  }
}
