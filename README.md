# bookmark_blade

A Flutter Project for combining a group of links into a single link.

To run this you'll need to also have a local server for the [bookmark api](github.com/VHCBlade/bookmark_api). You'll need to install [Dart Frog](https://dartfrog.vgv.dev/) and run 
```
dart_frog dev
```

You'll also need to add a lib/local.dart file with the following content:
```
const site = "http://<server>:8080/";
```

Make sure to replace `<server>` with your ip/localhost.

This uses [bookmark_models](github.com/VHCBlade/bookmark_models) to share the models with the api.
