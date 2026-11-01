# Cataclysm: Dark Days Ahead for iOS

An iPhone and iPad port of [Cataclysm: Dark Days Ahead](https://cataclysmdda.org/), the open-source
post-apocalyptic survival roguelike. It builds the game's own SDL tiles front end for iOS, with
the touch controls of the official Android port, a layout that respects the notch and home
indicator, and saves you can reach from the Files app.

This is an unofficial port and is not affiliated with the Cataclysm: DDA team. The game itself
comes unmodified from [CleverRaven/Cataclysm-DDA](https://github.com/CleverRaven/Cataclysm-DDA);
this repository holds only the iOS build system, a small patch series and the iOS platform layer.

| | |
|---|---|
| Game version | Latest upstream `cdda-experimental-*` release with a successful iOS build ([upstream releases](https://github.com/CleverRaven/Cataclysm-DDA/releases)) |
| Devices | iPhone and iPad, arm64, iOS/iPadOS 15 or later, landscape |
| Graphics | Tilesets and ASCII, all upstream tilesets included |
| Sound | CC-Sounds effects and music bundled (SDL3_mixer) |
| Languages | All upstream translations |

## Installing

There is no App Store release. Install the app with your own Apple ID:

1. Download the latest unsigned IPA from the [Releases](../../releases). Choose the asset whose
   name ends in `-unsigned.ipa`. GitHub may also show automatically generated source archives for
   the release tag; those are not needed to install the game. The workflow uploads the IPA only.
2. Sign and install it with a sideloading tool such as [AltStore](https://altstore.io/) or
   [Sideloadly](https://sideloadly.io/). With a free Apple ID the signature lasts 7 days,
   after which the tool has to refresh it; your saves are kept.

Or build it yourself and run it from Xcode, see [Building](#building).

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
| ⌨ button | Tap to show or hide the keyboard, touch and hold to show or hide the shortcut bar |

The shortcut bar learns: keys you type on the keyboard and actions picked from the action menu
are added to it. Everything above can be changed under **Settings → Touch**.

The ⌨ button sits in the empty margin beside the screen on iPhones with a notch or Dynamic
Island, and in the top right corner otherwise. It hides itself while a hardware keyboard is
connected.

### Keyboard, mouse and controllers

Hardware keyboards (Magic Keyboard, Bluetooth) work like on desktop. On iPad a trackpad or mouse
can click in menus and on the map. Game controllers supported by iOS can be enabled under
**Settings → Interface**.

### Text size

The terminal always fills the screen; its size follows from the font. A fresh install picks a
font cell height that gives about 28 rows. To fit more or less on screen, change
**Settings → Graphics → Font width / Font height / Font size** (and the map and overmap
variants) and restart the app.

### Language

The app bundles the upstream translation catalogs. To use Vietnamese, open
**Settings → Interface → Language** and choose **Vietnamese**. Installed catalogs remain
selectable even when the upstream release does not include generated translation statistics.

### Tilesets

The app bundles the official graphical tilesets from the matching upstream release. To switch
from ASCII graphics, open **Settings → Graphics** and choose a tileset such as **MShockXotto+**.

### Sound

The IPA includes the **CC-Sounds** soundpack, with sound effects and music. Sound is enabled by
default. If needed, open **Options → General → Soundpack options**, choose **CC-Sounds**, and
restart the game.

The pack is downloaded from
[Fris0uman/CDDA-Soundpacks](https://github.com/Fris0uman/CDDA-Soundpacks) at the pinned
2025-11-15 release. CC-Sounds is licensed under
[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Per-file sound-effect credits,
the pack license, and the authorization for CO.AG music are included in the app bundle under
`data/sound/CC-Sounds/`.

## Files, saves and mods

Everything the game writes lives in the app's Documents folder, which shows up in the Files app
under *On My iPhone/iPad → Cataclysm* and in Finder when the device is connected to a Mac.

| Folder | Contents |
|---|---|
| `save/` | Worlds and characters |
| `config/` | Options, keybindings, `debug.log` and crash logs |
| `mods/` | Your own mods, one folder per mod |
| `gfx/` | Extra tilesets |
| `sound/` | Additional soundpacks; CC-Sounds is bundled with the app |
| `memorial/`, `achievements/` | Graveyard and achievements |

To move a game between devices or to and from desktop Cataclysm built from the same upstream
revision, copy the world folder in `save/`.

iOS can stop an app in the background at any time, so save before switching away. Settings →
Touch → *Quicksave on app lose focus* saves automatically when the app goes to the background;
upstream marks this experimental.

## Building

Local iOS builds require a Mac with Xcode 15 or later, CMake 3.24 or later, and GNU gettext
(`brew install cmake gettext`) for translations. The scripts below use Bash and Apple's Xcode
tools; they do not run natively in Windows PowerShell. If you are on Windows, use the GitHub
Actions workflow described below.

### Build an IPA for the currently pinned version

From the repository root on a Mac:

```sh
scripts/fetch-cdda.sh
bash scripts/fetch-graphics.sh
bash scripts/fetch-soundpack.sh
scripts/build-deps.sh iphoneos
scripts/compile-translations.sh
scripts/build-app.sh iphoneos Release
scripts/package-ipa.sh
```

The unsigned IPA is written to
`dist/Cataclysm-cdda-experimental-2026-10-30-2308-unsigned.ipa`. Sideload it with AltStore,
Sideloadly, or another signing tool. An unsigned IPA cannot be installed directly on an iPhone.
The first dependency build takes a while; it creates the SDL3 libraries in `deps/`, which can
then be reused for later game versions. Bundling CC-Sounds adds about 138 MB to the app.

To build in GitHub Actions instead, commit and push your changes to the configured port branch.
The [iOS workflow](https://github.com/tranducvuong03/Cataclysm-IOS-Experimental/actions/workflows/ios.yml)
builds the device IPA and runs iPhone and iPad Simulator smoke tests. After the device IPA is
packaged, the workflow creates a GitHub prerelease and uploads the IPA as its only asset.
Each build gets a unique internal tag (`ios-build-<run-number>`) and a clearly named
`Cataclysm-iOS-...-unsigned.ipa` file; previous releases are kept. GitHub automatically provides
source archives for release tags, but they are not uploaded by this workflow and are not needed
to install the IPA. Check the workflow's Simulator test results before installing.

The workflow also checks the upstream releases twice an hour (at minute 17 and 47 UTC) for a new
`cdda-experimental-YYYY-MM-DD-HHMM` release. Once its graphics asset and SHA-256 digest are
available, it builds that exact version using the pinned
`cdda-translations-2026-10-30-2308.tar.gz` archive, runs the same smoke tests, and publishes a
prerelease titled with the upstream version. The uploaded IPA filename ends in
`-unsigned.ipa`. After a successful build and release, it also updates `cdda.env` on `main` with
the upstream tag, commit, and asset checksums. Existing upstream versions are not built again.
If an upstream change is incompatible with the iOS patches or fails a build or smoke test, no
IPA release is published and `cdda.env` is left unchanged.
GitHub may delay or drop scheduled runs during periods of high load, so these checks are not
guaranteed to start at their exact scheduled times. Every run that GitHub starts is visible in the
Actions tab.
Simulator checks verify that CC-Sounds is bundled, enabled, and selected; they do not test audio
playback because the iOS Simulator may not expose an audio output device.

### Change the upstream version and build a new IPA

The upstream tag, exact source commit, displayed game version, and graphics archive checksum are
pinned in `cdda.env`. Translation builds always use
`cdda-translations-2026-10-30-2308.tar.gz` with SHA-256
`92abf0aaf85936fb1fa238e7368b96003c701293018640f99c6f78bfcfe66e4e`; keep
`CDDA_TRANSLATIONS_REF` and `CDDA_TRANSLATIONS_SHA256` unchanged when updating the game. Follow
these steps to build a newer upstream release.

1. Find the new upstream release on
   [CleverRaven/Cataclysm-DDA](https://github.com/CleverRaven/Cataclysm-DDA/releases). Record its
   tag and full 40-character commit SHA, plus the SHA-256 digest for that release's graphics
   archive.
2. Update these four values in `cdda.env`:

```sh
CDDA_REF=cdda-experimental-YYYY-MM-DD-HHMM
CDDA_COMMIT=<full-40-character-commit-sha-for-that-tag>
CDDA_VERSION_STRING=cdda-experimental-YYYY-MM-DD-HHMM
CDDA_GRAPHICS_SHA256=<sha256-of-that-release-graphics-archive>
```

   Keep `CDDA_REPO`, `CDDA_TRANSLATIONS_REF`, and `CDDA_TRANSLATIONS_SHA256` unchanged. The
   graphics archive is normally named
   `cdda-windows-with-graphics-x64-YYYY-MM-DD-HHMM.zip`. This asset name omits the
   `cdda-experimental-` prefix. Copy the graphics asset's `sha256:` digest from GitHub without the
   prefix. The commit SHA is not a checksum.
3. Recreate the upstream checkout so the new version is used. **Back up any local work in `cdda/`
   first**: `--force` deletes that generated checkout.

```sh
scripts/fetch-cdda.sh --force
```

   This applies every iOS patch. If a patch fails, stop and update it for the new upstream source;
   do not build a partially patched checkout. After porting patches, run
   `scripts/export-patches.sh`, review the changes, and verify them with `scripts/prepare-cdda.sh`.
4. Fetch the graphics, soundpack, and translation assets, build the app, and package the IPA:

```sh
scripts/prepare-cdda.sh
bash scripts/fetch-graphics.sh
bash scripts/fetch-soundpack.sh
scripts/build-deps.sh iphoneos       # only if SDL dependencies are missing or need rebuilding
scripts/compile-translations.sh
scripts/build-app.sh iphoneos Release
scripts/package-ipa.sh
```

The scripts verify the translation, graphics, and soundpack checksums. The graphics download
supplies the tilesets, Terminus font, and Metal shaders required by iOS. The independently pinned
soundpack version and checksums are in `soundpack.env`; this audio release does not have to change
when the game source version changes. To choose a custom IPA path:

```sh
scripts/package-ipa.sh \
  build/iphoneos/Release-iphoneos/Cataclysm.app \
  dist/Cataclysm-my-version-unsigned.ipa
```

5. On Windows, commit and push `cdda.env` and patch changes to the configured port branch instead
   of building locally. GitHub Actions builds the IPA and runs both Simulator smoke tests. Download
   the IPA from the new release only after the device build succeeds; back up worlds because a
   newer game version may not be compatible with existing saves.

`build-app.sh` generates an Xcode project in `build/<platform>/CataclysmDDA.xcodeproj`. To sign
the app with your own Apple Developer team, set your team and a bundle identifier you own:

```sh
APP_DEVELOPMENT_TEAM=ABCDE12345 APP_BUNDLE_ID=com.example.cataclysm scripts/build-app.sh iphoneos
```

Alternatively, open the generated project in Xcode, select the *Cataclysm* scheme, choose your
team under *Signing & Capabilities*, and press Run.

Cataclysm keeps the whole game database in memory. If your App ID has the
[Increased Memory Limit](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.kernel.increased-memory-limit)
capability enabled, request it with `EXTRA_CMAKE_ARGS=-DAPP_INCREASED_MEMORY_LIMIT=ON`; this helps
on devices with less RAM. A full build takes a while: Cataclysm has around 450 large source
files.

### Repository layout

| Path | |
|---|---|
| `cdda.env` | Upstream repository, tag and commit the port is built from |
| `soundpack.env` | Pinned CC-Sounds release, source commit, and checksums |
| `patches/` | Changes to upstream sources, applied as commits on branch `ios` of `./cdda` |
| `scripts/fetch-graphics.sh` | Downloads and verifies the matching upstream graphics archive |
| `scripts/fetch-soundpack.sh` | Downloads and verifies the pinned CC-Sounds release |
| `ios/CMakeLists.txt` | Xcode project: game sources, SDL3 libraries, app bundle, game data |
| `ios/src/ios_platform.mm` | iOS platform layer: paths, safe area, keyboard, haptics, keyboard button |
| `ios/src/ios_autoplay.cpp` | Scripted input for automated tests |
| `ios/scripts/copy-game-data.sh` | Build phase that copies `data/`, `gfx/` and translations into the app |
| `ios/resources/` | `Info.plist`, privacy manifest, app icon |
| `scripts/` | Fetch, build, package, release and test scripts |
| `tools/linux-harness/` | Desktop build of the iOS code paths for development without a Mac |
| `.github/workflows/ios.yml` | CI: device build and IPA, simulator build and smoke test |

### How the port works

Upstream already runs on Android through SDL3, and most of what a phone needs lives behind
`#if defined(__ANDROID__)`. The patch adds a `CATA_IOS` build flag and turns on the same touch
interface for it, replacing the few Android Java calls with the iOS platform layer. On top of
that it:

- enters through `SDL_main`, reads data from the app bundle and writes to Documents/;
- renders at full Retina resolution and sizes the terminal to the safe area, so text is drawn
  1:1 and nothing hides behind the notch, shrinking it above the on-screen keyboard;
- maps iOS touches (which SDL identifies by `UITouch` address) to the finger indices the
  Android gesture code expects;
- maps trackpad and mouse positions from points to terminal pixels;
- finishes a background quicksave inside an iOS background task.

### Changing the patches

`scripts/fetch-cdda.sh` applies `patches/` as commits on a branch called `ios` in `./cdda`.
Commit your changes there, then run `scripts/export-patches.sh` to regenerate `patches/`.
To move to a newer upstream release, update `cdda.env`, run `scripts/fetch-cdda.sh --force`
and rebase the patches.

### Publishing a release

`scripts/release.sh` publishes an unsigned IPA as a GitHub Release from your Mac, without
GitHub Actions. It builds the device app (or takes an IPA you pass it), then creates the release
and tag on the current commit with the GitHub CLI:

```sh
gh auth login                                  # once
scripts/release.sh cdda-experimental-2026-10-30-2308-ios.1             # build and publish
scripts/release.sh cdda-experimental-2026-10-30-2308-ios.1 path/to.ipa # publish an IPA you already have
RELEASE_DRAFT=1 scripts/release.sh cdda-experimental-2026-10-30-2308-ios.1
```

The commit must be clean and pushed, and `./cdda` must match `patches/`.

### TestFlight

`scripts/testflight.sh` archives the app, signs it for your Apple developer team and uploads it
to App Store Connect for TestFlight, from your Mac. It needs Xcode 26 or later, which
[App Store Connect requires for uploads](https://developer.apple.com/news/upcoming-requirements/). One-time setup:

1. Register the bundle ID (`io.github.h4zm47.cataclysmdda`, or your own passed as
   `APP_BUNDLE_ID`) under *Certificates, Identifiers & Profiles → Identifiers*, then create the
   app in App Store Connect (*Apps → + → New App*) with that bundle ID.
2. Either sign in to Xcode with an Apple ID on the team (*Xcode → Settings → Accounts*), or
   create an App Store Connect API key (*Users and Access → Integrations*) and pass it as
   `ASC_KEY_PATH`, `ASC_KEY_ID` and `ASC_ISSUER_ID`.

Then, with your team ID from *Membership details*:

```sh
APP_DEVELOPMENT_TEAM=ABCDE12345 scripts/testflight.sh
```

Each build gets the UTC date and time as its build number (`YYYYMMDD.HHMM`), so every upload
is higher than the last; set `BUILD_NUMBER` to override it. `TESTFLIGHT_INTERNAL_ONLY=1` limits
the build to internal testers, and `TESTFLIGHT_EXPORT_ONLY=1` writes a signed IPA to `dist/`
for Transporter instead of uploading. Once App Store Connect has processed the build, add
testers under *TestFlight*; external testers need Beta App Review first.

The app carries a privacy manifest, `ios/resources/PrivacyInfo.xcprivacy`, which App Store
Connect requires. It declares the file-timestamp and system-boot-time APIs that the game and
SDL use; update it if new code uses other
[required reason APIs](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api).

### Testing

CI builds both the device and the simulator app. The simulator job installs the app in an
iPhone and an iPad Simulator and drives it with `CATA_AUTOPLAY` (see
`ios/src/ios_autoplay.cpp`): it starts a *Play Now!* game, exercises the touch controls and the
on-screen keyboard, saves and quits, checks that the character save was written and uploads
screenshots and logs as the **smoke-test** artifact.
The Simulator can report the Mac's keyboard as a hardware keyboard, which hides the quick
shortcuts, so the test sets `CATA_IOS_HARDWARE_KEYBOARD=0` to get the phone behaviour.
`scripts/simulator-smoke-test.sh` runs the same test locally (`SMOKE_DEVICE_KIND=ipad` for an
iPad).

`tools/linux-harness` builds the game for Linux with the iOS code paths enabled and a stand-in
platform layer (simulated notch, keyboard and screen scale). It runs the same layout, touch
controls and autoplay hook as the app, which is handy for working on them without a Mac:

```sh
cmake -S tools/linux-harness -B build/harness -G Ninja && cmake --build build/harness
tools/linux-harness/run.sh                       # in a window on the current display
CATA_AUTOPLAY="idle=8;shot=menu" tools/linux-harness/run.sh --headless   # under Xvfb
```

## License

Cataclysm: Dark Days Ahead is licensed under
[CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/) with some third-party parts under
their own licenses; see upstream's
[LICENSE.txt](https://github.com/CleverRaven/Cataclysm-DDA/blob/cdda-experimental-2026-10-30-2308/LICENSE.txt). The
patches and the rest of this repository are released under the same CC BY-SA 3.0 license.
SDL3 and its satellite libraries are under the [zlib license](https://www.libsdl.org/license.php).
