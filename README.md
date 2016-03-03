ABReleaseNotesViewController
====

`ABReleaseNotesViewController` is an easy-to-use, reasonably attractive way to display your application's release notes in-app. This project was inspired by [https://github.com/iGriever/TWSReleaseNotesView](TWSReleaseNotesView). I've used `TWSReleaseNotesView` in the past, and it was great, but it hasn't been updated in a few years.

![Animated GIF demonstrating the project](http://i.imgur.com/wgwhOY8.gif)

Quickstart
====

Create your release notes object in your init method, or in `-viewDidLoad`:

    - (void)viewDidLoad {
      [super viewDidLoad];
  
      self.releaseNotes = [ABReleaseNotesViewController releaseNotesControllerWithAppIdentifier:@"329380089" title:NSLocalizedString(@"Release Notes", @"")];
    }

After your view appears, begin checking for updates. If an update is available, you may present the view controller immediately, as depicted below:

    [self.releaseNotes checkForUpdates:^(BOOL updated) {
      if (updated) {
          [self presentViewController:self.releaseNotes animated:YES completion:nil];
      }
    }];

Additionally, you could present an alert or some sort of non-modal user interface to the user informing them that they can read release notes if desired.

System Requirements
====

iOS 9.0 and above. Should be compatible with tvOS, but I haven't tried it there, yet. Supporting iOS 8 should be relatively straightforward, if you're willing to deal with some Auto Layout annoyances that are rendered trivial by `UIStackView`.

Issues, Pull Requests, etc.
====

Issues, bug fixes, and new features are always welcome. Priority will be given to issues that are accompanied by patches, but I will do my best to stay on top of problems with the code.

Credits
====

* Created by [Aaron Brethorst](http://www.twitter.com/aaronbrethorst).
* Inspired by [TWSReleaseNotesView](https://github.com/iGriever/TWSReleaseNotesView), by [Matteo Lallone](https://twitter.com/iGriever) and [Gianluca Divisi](https://twitter.com/gianlucadivisi).

MIT License
====

    The MIT License (MIT)

    Copyright (c) 2016 Aaron Brethorst

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.