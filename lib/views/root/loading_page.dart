import 'package:flutter/material.dart';

import '../../model/loading_step.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage(this.steps, {super.key});

  final List<LoadingStep> steps;

  @override
  State<LoadingPage> createState() => LoadingPageState();
}

class LoadingPageState extends State<LoadingPage> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.steps.forEach((e) => e.then = update);
  }

  void update() {
    if (!mounted) return;
    setState(() {

    });
  }

  List<Widget> buildSteps() {
    return widget.steps.map((e) => e.build(context)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).primaryColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(2, 2)
                    )
                  ]
                ),
                child: const Image(
                  width: 200, image: AssetImage("assets/images/icon.jpg")),
              ),
              const CircularProgressIndicator(color: Colors.white24),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: buildSteps(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
