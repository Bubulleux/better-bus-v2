import 'package:better_bus_v2/data_provider/local_data_handler.dart';
import 'package:flutter/material.dart';

class PreferencesView extends StatelessWidget {
  const PreferencesView({Key? key}) : super(key: key);

  Future<List<Widget>> getPreferences() async {
    Map<String, String> preferences =  await LocalDataHandler.getAllPref();
    List<Widget> result = [];
    preferences.forEach((key, value) {result.add(Text("$key:\n $value"));});
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: getPreferences(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Widget> data = snapshot.data as List<Widget>;
              return ListView.separated(
                itemBuilder: (context, index) {
                  return data[index];
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
    );
  }
}
