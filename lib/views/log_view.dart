import 'package:better_bus_v2/data_provider/local_data_handler.dart';
import 'package:flutter/material.dart';

class LogView extends StatelessWidget {
  const LogView({Key? key}) : super(key: key);

  Future<List<String>> getLog() async {
    List<String> log = await LocalDataHandler.loadLog();
    return log;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                LocalDataHandler.clearLog();
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: FutureBuilder(
                future: getLog(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<String> data = snapshot.data as List<String>;
                    return ListView.separated(
                      itemBuilder: (context, index) {
                        return Text(data[index]);
                      },
                      itemCount: data.length,
                      separatorBuilder: (context, index) => const Divider(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error!.toString()),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
