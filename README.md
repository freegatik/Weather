<p align="center">
  <img src="docs/readme-weather-icon.png" width="200" alt="Weather">
</p>

# Weather

![Static Badge](https://img.shields.io/badge/platform-iOS-white)
![Static Badge](https://img.shields.io/badge/latest_release-v1.0.0-green)
![Static Badge](https://img.shields.io/badge/swift-v5.0-orange)

[![CI](https://github.com/freegatik/Weather/actions/workflows/ci.yml/badge.svg)](https://github.com/freegatik/Weather/actions/workflows/ci.yml)

Native **UIKit** app (Swift **5**, iOS **18.2** in the Xcode project; **CocoaPods** pins the pod platform to **18.4**) for city weather search, recent-search history (**`UserDefaults`** via **`LastSearchCitiesProvider`**), and condition icons loaded with **[SDWebImage](https://github.com/SDWebImage/SDWebImage)**. Data comes from **[WeatherAPI](https://www.weatherapi.com/)** through **`WeatherService`**. The UI is **Storyboard**-driven with **`MainViewController`** and custom **`CityTableCell`** (XIB). **MVVM**-style separation for the cell; **`UITestingSupport`** helps UI and unit tests.

## CI

Workflow [`.github/workflows/ci.yml`](.github/workflows/ci.yml) on [GitHub Actions](https://github.com/freegatik/Weather/actions) for **`push`**, **`pull_request`**, and **`workflow_dispatch`**. **`concurrency`** with **`cancel-in-progress`** avoids stacked runs per ref.

| Job | What it runs |
|-----|----------------|
| **SwiftLint** | **`macos-latest`**, Homebrew **SwiftLint**, **`swiftlint lint --strict`** with GitHub Actions reporter ([`.swiftlint.yml`](.swiftlint.yml)) |
| **Xcode Analyze** | Restores **`Pods`** from cache → **`pod install`** → composite action **[`pick-ios-simulator`](.github/actions/pick-ios-simulator/action.yml)** (first available **iPhone 16 / 15 / 14**) → **`xcodebuild analyze`** on **`Weather.xcworkspace`** / **`Weather`** with **`platform=iOS Simulator,id=<UDID>`** |
| **Tests & Swift coverage** | Same Pods + simulator pick → **`xcodebuild test`** with **`-derivedDataPath`**, **`-enableCodeCoverage YES`**, **`-resultBundlePath TestResults.xcresult`** → merges **`.profraw`**, runs **`llvm-cov report`** over **`Weather.app`** + **`Objects-normal/*.o`**, ignores **`GeneratedAssetSymbols`**, **enforces minimum line coverage `MIN_APP_SWIFT_LINE_COVERAGE` (94.5%)** → uploads **`TestResults.xcresult`** on **`always()`** |

Simulator selection uses **UDID** (not `name=` + implicit **OS:latest**), matching the composite action output.

## Requirements

- **Xcode 15+** with a current iOS Simulator (CI uses **`macos-latest`** default Xcode)
- **CocoaPods** (`gem install cocoapods` or Homebrew)
- **iOS 18.2+** deployment (project); **Podfile** platform **18.4**

## Getting started

```bash
git clone https://github.com/freegatik/Weather.git
cd Weather
pod install
open Weather.xcworkspace
```

Use the **Weather** scheme: **⌘R** to run, **⌘U** for tests. Replace the WeatherAPI key in **`Weather/Services/WeatherService/WeatherService.swift`** for production (see comments in project).

## Project layout

| Area | Path / notes |
|------|----------------|
| Lifecycle | `Weather/AppDelegate/` |
| UI | `Weather/UI/` (`MainViewController`, `CityTableCell/`, `Base.lproj/Main.storyboard`) |
| Services | `Weather/Services/` (`WeatherService`, `LastSearchCitiesProvider`, `Model/`) |
| Test hooks | `Weather/App/UITestingSupport.swift` |
| Resources | `Weather/Resources/` (`Assets.xcassets`, plists, launch storyboard) |
| Unit & UI tests | `WeatherTests/`, `WeatherUITests/` |
| Dependencies | [`Podfile`](Podfile), [`Podfile.lock`](Podfile.lock) |

## Testing

CI runs the full **`Weather`** test action (unit + UI) with coverage gates. Locally:

```bash
pod install
xcodebuild test \
  -workspace Weather.xcworkspace \
  -scheme Weather \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Pick a simulator name that exists on your Mac (`xcrun simctl list devices available`).

Lint:

```bash
swiftlint lint --strict
```

## License

The project is distributed under the [MIT License](LICENSE). The canonical legal text is in the `LICENSE` file at the repository root.
