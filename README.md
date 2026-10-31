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
| Game version | **cdda-experimental-2026-10-30-2308** (upstream tag [`cdda-experimental-2026-10-30-2308`](https://github.com/CleverRaven/Cataclysm-DDA/tree/cdda-experimental-2026-10-30-2308)) |
| Devices | iPhone and iPad, arm64, iOS/iPadOS 15 or later, landscape |
| Graphics | Tilesets and ASCII, all upstream tilesets included |
| Sound | Supported (SDL3_mixer); add soundpacks yourself, see below |
| Languages | All upstream translations |

## Installing

There is no App Store release. Install the app with your own Apple ID:

1. Download the unsigned IPA from the [Releases](../../releases) page. Open the release titled
   **“⬇ TẢI IPA — Cataclysm DDA iOS”**, then download the asset ending in
   `-unsigned.ipa`. The technical tag is named `ios-build-<run-number>`; the release title and
   asset filename identify the downloadable IPA. The iOS workflow keeps Simulator smoke-test
   logs and screenshots as Actions artifacts.
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
**Settings → Interface → Language** and choose **tiếng Việt**.

### Tilesets

The app bundles the official graphical tilesets from the matching upstream release. To switch
from ASCII graphics, open **Settings → Graphics** and choose a tileset such as **MShockXotto+**.

**Tiếng Việt:** Vào **Settings → Interface → Language** và chọn **tiếng Việt**. Để dùng hình
ảnh thay vì ký tự ASCII, vào **Settings → Graphics** rồi chọn tileset **MShockXotto+**.

## Files, saves and mods

Everything the game writes lives in the app's Documents folder, which shows up in the Files app
under *On My iPhone/iPad → Cataclysm* and in Finder when the device is connected to a Mac.

| Folder | Contents |
|---|---|
| `save/` | Worlds and characters |
| `config/` | Options, keybindings, `debug.log` and crash logs |
| `mods/` | Your own mods, one folder per mod |
| `gfx/` | Extra tilesets |
| `sound/` | Soundpacks, e.g. [CDDA-Soundpack](https://github.com/Fris0uman/CDDA-Soundpack) |
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
scripts/build-deps.sh iphoneos
scripts/compile-translations.sh
scripts/build-app.sh iphoneos Release
scripts/package-ipa.sh
```

The unsigned IPA is written to
`dist/Cataclysm-cdda-experimental-2026-10-30-2308-unsigned.ipa`. Sideload it with AltStore,
Sideloadly, or another signing tool. An unsigned IPA cannot be installed directly on an iPhone.
The first dependency build takes a while; it creates the SDL3 libraries in `deps/`, which can
then be reused for later game versions.

To build in GitHub Actions instead, commit and push your changes to the configured port branch.
The [iOS workflow](https://github.com/tranducvuong03/Cataclysm-ios/actions/workflows/ios.yml)
builds the device IPA and also builds and smoke-tests the Simulator version. When the device IPA
packaging succeeds, the workflow creates a regular GitHub Release (not a prerelease) for that run
and uploads the IPA with a clear **“⬇ TẢI IPA — Cataclysm DDA iOS (build #...)”** title. Each run
gets a unique internal tag (`ios-build-<run-number>`) and a clearly named
`Cataclysm-iOS-...-unsigned.ipa` asset, so previous releases are retained. GitHub requires a tag
behind every Release; users can identify the download by its title and IPA filename. Check the
same workflow run for its Simulator smoke-test result before installing.

### Change the upstream version and build a new IPA

The upstream tag, exact source commit, displayed game version, translation checksum, and graphics
archive checksum are pinned together in `cdda.env`. Change all of these values for a new upstream
release:

```sh
CDDA_REF=cdda-experimental-YYYY-MM-DD-HHMM
CDDA_COMMIT=<full-40-character-commit-sha-for-that-tag>
CDDA_VERSION_STRING=cdda-experimental-YYYY-MM-DD-HHMM
CDDA_TRANSLATIONS_SHA256=<sha256-of-that-release-translation-archive>
CDDA_GRAPHICS_SHA256=<sha256-of-that-release-graphics-archive>
```

Keep `CDDA_REPO` pointing at `https://github.com/CleverRaven/Cataclysm-DDA.git`. Do not put
the upstream commit SHA in `CDDA_TRANSLATIONS_SHA256`: it is the SHA-256 checksum of the separate
translations `.tar.gz` asset, not a Git commit ID.

Find the exact commit and translations checksum from the upstream GitHub release for the tag.
The release asset is normally named
`cdda-translations-YYYY-MM-DD-HHMM.tar.gz` (without the `cdda-experimental-` prefix).
GitHub's release API reports the asset's `digest` as `sha256:...`; copy the hex digest into
`CDDA_TRANSLATIONS_SHA256`. If the digest is not shown, download that exact asset and calculate
it with `shasum -a 256 <downloaded-archive>`. The build script verifies the checksum before
extracting any catalogs.
If that release has no translation archive, confirm the source checkout contains usable
`lang/po/*.po` files before building; do not copy translations from a different game version.
The source repository does not include all binary graphics assets (including the full tilesets,
fonts, and compiled Metal shaders). Get
`CDDA_GRAPHICS_SHA256` from the release asset
`cdda-windows-with-graphics-x64-YYYY-MM-DD-HHMM.zip` (again, the asset name omits
`cdda-experimental-`). The script downloads the archive, verifies its checksum, and installs the
`gfx/`, `data/font/`, and `data/shaders/` resources used by iOS. It fails if the expected
MShockXotto+ tileset, Terminus font, or required Metal shader is absent.
It also adds a blank `unknown` fallback to the portrait add-on, which the upstream tileset loader
requires even though that add-on only defines portraits.

Next, rebuild the patched upstream checkout from scratch. **Back up any local work in `cdda/`
first**: `--force` removes that generated checkout and recreates it from the pinned upstream and
the patch series.

```sh
scripts/fetch-cdda.sh --force
```

This applies every file in `patches/` to the new upstream revision. If a patch fails to apply,
stop and port that change to the new source before continuing; do not build against a partially
patched checkout. The iOS patches are maintained in this repository. If you port a patch by
editing `cdda/`, commit the change on its `ios` branch, then run `scripts/export-patches.sh` to
regenerate `patches/`. Review the generated diff and run `scripts/prepare-cdda.sh` to verify that
the checkout and patch files match.

Once all patches apply, verify and build:

```sh
scripts/prepare-cdda.sh
bash scripts/fetch-graphics.sh
scripts/build-deps.sh iphoneos       # only needed if the SDL dependencies are not already built
scripts/compile-translations.sh
scripts/build-app.sh iphoneos Release
scripts/package-ipa.sh
```

The IPA name uses `CDDA_VERSION_STRING`. To choose another output path:

```sh
scripts/package-ipa.sh \
  build/iphoneos/Release-iphoneos/Cataclysm.app \
  dist/Cataclysm-my-version-unsigned.ipa
```

Before sharing the IPA, push the `cdda.env` and any patch changes to GitHub and wait for the
device build and Simulator smoke tests to pass. Updating upstream can change save compatibility;
back up worlds before testing a different game version.

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

### Hướng dẫn tiếng Việt: đổi phiên bản upstream và tạo IPA

Muốn build tại máy cần **Mac có Xcode 15 trở lên**, CMake 3.24 trở lên, GNU gettext và Bash.
Các lệnh build iOS không chạy trực tiếp trong Windows PowerShell. Nếu bạn dùng Windows, hãy
sửa mã rồi push lên GitHub; GitHub Actions sẽ build IPA trên máy Mac của GitHub.

#### Build IPA của phiên bản hiện tại

Mở Terminal tại thư mục repo trên Mac và chạy:

```sh
scripts/fetch-cdda.sh
bash scripts/fetch-graphics.sh
scripts/build-deps.sh iphoneos
scripts/compile-translations.sh
scripts/build-app.sh iphoneos Release
scripts/package-ipa.sh
```

IPA chưa ký sẽ nằm trong `dist/` với tên phiên bản hiện tại. Cần ký/cài bằng AltStore, Sideloadly
hoặc công cụ sideload tương tự; IPA unsigned không cài trực tiếp được. `build-deps.sh` chỉ cần
chạy lại khi thư viện SDL chưa được build hoặc cần cập nhật.

Nếu dùng Windows hoặc muốn CI build hộ: commit rồi push thay đổi lên branch port. Mở
[iOS workflow](https://github.com/tranducvuong03/Cataclysm-ios/actions/workflows/ios.yml), chờ
build thiết bị đóng gói IPA thành công; workflow sẽ tạo GitHub Release chính thức (không phải
pre-release) có tiêu đề dễ nhận biết
**“⬇ TẢI IPA — Cataclysm DDA iOS (build #...)”** và đính kèm file
`Cataclysm-iOS-...-unsigned.ipa`. GitHub vẫn cần tag kỹ thuật phía sau mỗi Release
(`ios-build-<số-run>`), nhưng trang tải sẽ hiện tiêu đề và tên file rõ ràng. Mỗi run dùng tag
riêng nên không ghi đè release cũ. Workflow vẫn giữ log và ảnh smoke test của Simulator trong
Actions artifacts; hãy kiểm tra kết quả smoke test trước khi cài IPA.

#### Đổi sang tag upstream mới

Mở `cdda.env` và cập nhật đồng bộ năm giá trị sau theo release upstream mới:

```sh
CDDA_REF=cdda-experimental-YYYY-MM-DD-HHMM
CDDA_COMMIT=<SHA-40-ky-tu-cua-tag>
CDDA_VERSION_STRING=cdda-experimental-YYYY-MM-DD-HHMM
CDDA_TRANSLATIONS_SHA256=<SHA-256-cua-goi-dich-tar.gz>
CDDA_GRAPHICS_SHA256=<SHA-256-cua-goi-tileset-zip>
```

- `CDDA_REF`: tên tag upstream.
- `CDDA_COMMIT`: commit SHA đầy đủ mà tag trỏ tới, không phải SHA rút gọn.
- `CDDA_VERSION_STRING`: chuỗi phiên bản hiển thị và dùng đặt tên IPA.
- `CDDA_TRANSLATIONS_SHA256`: SHA-256 của gói dịch riêng; **không phải** commit SHA.
- `CDDA_GRAPHICS_SHA256`: SHA-256 của gói tileset đồ họa riêng; **không phải** commit SHA.

Giữ `CDDA_REPO` là repo upstream `CleverRaven/Cataclysm-DDA`. Trong trang GitHub Release của
đúng tag, tìm asset `cdda-translations-YYYY-MM-DD-HHMM.tar.gz`. Tên asset bỏ phần
`cdda-experimental-`. Lấy trường `digest` dạng `sha256:...` của asset, rồi điền phần mã hex vào
`CDDA_TRANSLATIONS_SHA256`. Script sẽ kiểm tra checksum trước khi giải nén và biên dịch `.po`
thành `.mo`. Không dùng gói dịch của phiên bản khác. Nếu release không có gói dịch, hãy kiểm tra
source có `lang/po/*.po` hợp lệ trước khi tiếp tục.

Sau khi cập nhật `cdda.env`, tạo lại checkout upstream đã áp dụng các patch:

```sh
scripts/fetch-cdda.sh --force
```

**Lưu lại mọi công việc cần giữ trong `cdda/` trước khi chạy lệnh này**: `--force` xóa checkout
được tạo trước đó rồi tải đúng tag mới. Script sẽ áp dụng toàn bộ `patches/*.patch`. Nếu có patch
báo lỗi, dừng lại và port patch đó sang upstream mới; đừng build từ checkout chỉ được áp dụng một
phần. Nếu phải sửa code trong `cdda/`, hãy commit thay đổi trên branch `ios`, chạy
`scripts/export-patches.sh` để cập nhật `patches/`, xem lại diff rồi chạy
`scripts/prepare-cdda.sh` để kiểm tra patch series đã đồng bộ.

Bản source upstream không có đầy đủ tài nguyên đồ họa dạng binary (gồm tileset, font và Metal
shader đã biên dịch). Lấy SHA-256 của asset
`cdda-windows-with-graphics-x64-YYYY-MM-DD-HHMM.zip` trong release cùng tag, điền vào
`CDDA_GRAPHICS_SHA256` trong `cdda.env`. Lấy digest `sha256:...` của asset và chỉ chép phần hex.
`scripts/fetch-graphics.sh` tải gói, kiểm tra SHA-256 rồi chép `gfx/`, `data/font/` và
`data/shaders/` vào checkout. Script báo lỗi nếu thiếu tileset MShockXotto+, font Terminus hoặc
Metal shader cần thiết. Script cũng bổ sung tile `unknown` trống vào tileset portrait phụ vì
loader upstream yêu cầu tile dự phòng này dù tileset đó chỉ khai báo ảnh chân dung.

Build và đóng gói IPA:

```sh
scripts/prepare-cdda.sh
bash scripts/fetch-graphics.sh
scripts/build-deps.sh iphoneos       # bỏ qua nếu SDL đã có sẵn trong deps/install/iphoneos
scripts/compile-translations.sh
scripts/build-app.sh iphoneos Release
scripts/package-ipa.sh
```

Muốn tự đặt tên file IPA:

```sh
scripts/package-ipa.sh \
  build/iphoneos/Release-iphoneos/Cataclysm.app \
  dist/Cataclysm-phien-ban-moi-unsigned.ipa
```

Nếu build trên Windows, sau khi cập nhật `cdda.env` và patch, commit rồi push lên GitHub Actions.
Chỉ cài/chia sẻ IPA sau khi CI build thành công và smoke test trên Simulator qua. Phiên bản game
mới có thể không tương thích save cũ; hãy sao lưu thư mục `save/` trước khi thử.

### Repository layout

| Path | |
|---|---|
| `cdda.env` | Upstream repository, tag and commit the port is built from |
| `patches/` | Changes to upstream sources, applied as commits on branch `ios` of `./cdda` |
| `scripts/fetch-graphics.sh` | Downloads and verifies the matching upstream graphics archive |
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
on-screen keyboard, quicksaves, checks that the save was written and uploads screenshots and
logs as the **smoke-test** artifact.
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
