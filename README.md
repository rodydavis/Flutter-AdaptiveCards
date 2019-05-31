![AdaptiveCards for Flutter](docs/adaptivecards_for_flutter.png?raw=true "AdaptiveCards for Flutter")

# AdaptiveCards for Flutter

A Flutter implementation of Adaptive Cards.


### Installing

Put this into your pubspec.yaml
```
dependencies:
  flutter_adaptive_cards:
    git:
      url: https://github.com/Norbert515/flutter_adaptive_cards.git
```

## Using

Using adaptive cards coudn't be simpler. All you need is the `AdaptiveCard` widget.

There are several constructors which handle data loading from different sources.

`AdaptiveCard.network` takes a url to download the payload and display it.
`AdaptiveCard.asset` takes an asset path to load the payload from the local data.
`AdaptiveCard.memory` takes a map (which can be obtained but decoding a string using the json class) and displays it.

An example:

```
AdaptivCard.network(
  placeholder: Text("Loading, please wait"),
  url: "www.someUrlThatPointsToAJson",
  hostConfigPath: "assets/host_config.json",
  onSubmit: (map) {
    // Send to server or handle locally
  },
  onOpenUrl: (url) {
    // Open url using the browser or handle differently
  },
  // If this is set, a button will appear next to each adaptive card which when clicked shows the payload.
  // NOTE: this will only be shown in debug mode, this attribute does change nothing for realease builds.
  // This is very useful for debugging purposes
  showDebugJson: true,
  // If you have not implemented explicit dark theme, adaptive cards will try to approximate its colors to match the dark theme
  // so the contrast and color meaning stays the same.
  // Turn this off, if you want to have full control over the colors when using the dark theme.
  // NOTE: This is currently still under development
  approximateDarkThemeColors: true,
);
```


## Running the tests

Simply type 
```
flutter test
```

and to update the golden files run 

```
flutter test --update-goldens test/sample_golden_test.dart
```
This updates the golden files for the sample cards.

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Authors

* **Norbert Kozsir** (@Norbert515) – *Initial work*, Head of Flutter development @Neohelden

See also the list of [contributors](https://github.com/Norbert515/flutter_adaptive_cards/contributors) who participated in this project.


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

