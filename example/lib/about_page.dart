import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dynamic_theme/theme_switcher_widgets.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          ListTile(
            title: Text("Change brightness"),
            onTap: () {
              showDialog(context: context, builder: (_) => BrightnessSwitcherDialog(
                onSelectedTheme: (it) {
                  DynamicTheme.of(context).setBrightness(it);
                },
              ));
            },
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset("assets/neo_logo_light.png"),
                  ),
                  Divider(),
                  Text("Neo: AI-Assistant for Enterprise", style: Theme.of(context).textTheme.title,),
                  SizedBox(height: 8,),
                  Text('''
Neohelden is a startup from Germany developing a digital assistant for enterprise use-cases.

Users can interact with Neo using voice and text and request information from third-party systems or trigger actions – essentially, they're having a conversation with B2B software systems.
Our Conversational Platform allows for easy configuration and extension of Neo's functionalities and integrations, which enables customization of Neo to individual needs and requirements.

Neo has been using Adaptive Cards for a while now, and we're excited to bring them to Flutter!
                  
                  ''', style: Theme.of(context).textTheme.body1,),
                  SizedBox(height: 8,),
                  Align(
                    alignment: Alignment.center,
                    child: OutlineButton(
                      onPressed: () {
                        launch("https://neohelden.com/?utm_source=flutter&utm_medium=aboutButton&utm_campaign=flutterDemoApp");
                      },
                      child: Text("Check out the website"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Image.asset("assets/norbert.jpg", width: 100,),
                      SizedBox(width: 16,),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Text("Norbert Kozsir - Flutter Developer @Neohelden", style: Theme.of(context).textTheme.title,),
                            SizedBox(height: 8,),
                            Text("Norbert is the lead developer of the Flutter division at Neohelden and "
                                "responsible for this library,"
                                " he is building the Neo App using Flutter for the upcoming release.",
                              style: Theme.of(context).textTheme.body1,),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      OutlineButton(
                        child: Text("Twitter"),
                        onPressed: () {
                          launch("https://twitter.com/norbertkozsir");
                        },
                      ),
                      OutlineButton(
                        child: Text("Medium"),
                        onPressed: () {
                          launch("https://medium.com/@norbertkozsir");
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
