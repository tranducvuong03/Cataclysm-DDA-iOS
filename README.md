# Cataclysm: Dark Days Ahead for iOS

An unofficial iPhone and iPad port. Install the latest IPA from
[Releases](../../releases) using [AltStore](https://altstore.io/) or [Sideloadly](https://sideloadly.io/).

## Installing

There is no App Store release. Install the app with your own Apple ID:

1. Download the unsigned IPA from the [Releases](../../releases) page, or the
   **Cataclysm-unsigned-ipa** artifact from a successful run of the
   [iOS workflow](../../actions/workflows/ios.yml) (unzip it to get
   `Cataclysm-0.I-1-unsigned.ipa`).
2. Sign and install it with a sideloading tool such as [AltStore](https://altstore.io/) or
   [Sideloadly](https://sideloadly.io/). With a free Apple ID the signature lasts 7 days,
   after which the tool has to refresh it; your saves are kept.

## Playing on a touch screen

The touch controls are the ones from upstream's Android port:

| Gesture | Effect |
|---|---|
| Tap | Wait a turn (`.`) in game, confirm in menus |
| Double tap | Escape / back |
| Swipe, or touch and hold then slide | Move or scroll in that direction; holding repeats, like a virtual joystick |
| Two-finger tap | Inventory (`i`) |
| Two-finger swipe | Wide-move keys (`H` `J` `K` `L`), e.g. to pan the view while looking around |
| Pinch | Zoom in and out |
| Three-finger tap | Show or hide the shortcut bar |
| Three-finger swipe | Tab, back-tab, page up and page down |
| Shortcut bar | Context-sensitive keys along the bottom edge; flick one upward to remove it |
| Vehicle controls | On-screen 8-direction D-pad while driving |
| ⌨ button | Tap to show or hide the keyboard, touch and hold to show or hide the shortcut bar |

The shortcut bar learns: keys you type on the keyboard and actions picked from the action menu
are added to it. Everything above can be changed under **Settings → Touch**.

The ⌨ button sits in the empty margin beside the screen on iPhones with a notch or Dynamic
Island, and in the top right corner otherwise. It hides itself while a hardware keyboard is
connected.

Build on macOS with Xcode, or use the
[GitHub Actions workflow](https://github.com/tranducvuong03/Cataclysm-IOS-Experimental/actions/workflows/ios.yml).
To rebuild the latest pinned version, run the workflow manually and enable **Rebuild latest upstream version**.

To build Android for the latest upstream version, run the
[Android workflow](https://github.com/tranducvuong03/Cataclysm-DDA-iOS/actions/workflows/android.yml).
