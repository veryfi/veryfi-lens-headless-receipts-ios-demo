# Install

Pod `VeryfiLensHeadless-Receipts`. Dedicated SPM repo `veryfi-lens-spm-headless-receipts`.

## Artifact and import

| | |
|--|--|
| Pod | `VeryfiLensHeadless-Receipts` |
| CocoaPods repo | `veryfi-lens-headless-cocoapods-receipts` |
| Dedicated SPM | Yes. Repo `veryfi-lens-spm-headless-receipts`. Public host URL **Unconfirmed** |
| XCFramework | `VeryfiLensHeadlessReceipts.xcframework` |
| Swift import | `VeryfiLensHeadlessReceipts` |

```swift
import VeryfiLensHeadlessReceipts
import AVFoundation
```

## Swift Package Manager

Xcode → File → Add Package Dependencies. The package credential is the Lens CocoaPods/SPM key from the Veryfi hub.

Dedicated repo name: `veryfi-lens-spm-headless-receipts`.

The release pipeline publishes that repo under `shared/lens/veryfi-lens-spm-headless-receipts.git` (GitLab remote `git@gitlab.services.veryfi.com:shared/lens/veryfi-lens-spm-headless-receipts.git`). The customer host `https://repo.veryfi.com/shared/lens/veryfi-lens-spm-headless-receipts.git` is **Unconfirmed**, because public installation pages still show `https://repo.veryfi.com/shared/lens/veryfi-lens-spm.git`.

That Full URL is the Full UI binary. Do not install this flavor from it. If Xcode cannot resolve the dedicated host, ask Veryfi for the package URL rather than substituting the Full package.


## CocoaPods

Public docs call CocoaPods deprecated and prefer SPM. CocoaPods remains a pipeline path.

```ruby
source 'https://repo.veryfi.com/shared/lens/veryfi-lens-podspec.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'YourApp' do
  use_frameworks!
  pod 'VeryfiLensHeadless-Receipts'
end
```

Public pages pin a version with `pod 'VeryfiLensHeadless-Receipts', 'x.x.x.x', :linkage => :dynamic`. The current version number is **Unconfirmed** here. Use the version Veryfi gave the customer.


## Manual XCFramework

Embed `VeryfiLensHeadlessReceipts.xcframework`. The Full UI `VeryfiLens.xcframework` is a different product.

## Permissions

| Key | When |
|-----|------|
| `NSCameraUsageDescription` | Host camera that feeds `process(buffer:)` or `processWithBlock` |
| `NSPhotoLibraryAddUsageDescription` | `backupImagesToGallery = true` (default false) |
| `NSPhotoLibraryUsageDescription` | Not required for `upload(images:)` of images the host already decoded |
| `NSLocationWhenInUseUsageDescription` | **Unconfirmed**. The uploader reads a location helper for each scan. This settings type has no `locationServicesIsOn`. Do not add a location string unless a build shows a prompt |

iCloud backup (`backupImagesToiCloud`, default false) uses the host’s iCloud entitlement, not a usage-description key. **Unconfirmed** which entitlement string the uploader requires beyond the flag.

Contacts and Calendar strings are not part of this recipe. The legacy UI README list is **Unconfirmed**.

Deployment target for this XCFramework is **Unconfirmed** in this pack.

## App size

When installed size matters, recommend the **Remote Models** flavor. A specific flavor embeds its models in the binary. Remote Models keeps that binary smaller and downloads most of the heavy model resources after install, only for the features the host turned on.

Bank-check TIFF follows that split. `retrieveCheckTiffIsOn` is not supported on the Checks-specific flavor yet, because the TIFF model is large. Remote Models downloads it after install.

Measure the final build product, once with this Veryfi Lens SDK linked and once without it. The distributed XCFramework is a fat artifact that includes every architecture and platform slice. That file size is not the size added to the installed app. Store delivery can shrink the download further.

Flavor tables and the artifact-versus-app explanation: [SDK binary sizes](https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/).


## Public installation page

The public [headless receipts installation](https://docs.veryfi.com/lens/mobile/headless/receipts/installation/) page shows the matching pod and the Full SPM URL `veryfi-lens-spm.git`. Use `veryfi-lens-spm-headless-receipts`, not the Full package.

## Optional local evidence

These paths are evidence from the Veryfi Lens iOS source tree. They are not part of this skill pack. Ignore them when this folder is the only checkout. Nothing in the integration depends on opening them.

- `VeryfiLensHeadless/Public/VeryfiLensHeadless.swift`
- `VeryfiLensHeadless/Headless Receipts/VeryfiLensReceiptSettings.swift`
- `VeryfiLensHeadless/Headless Receipts/ReceiptsUploader.swift`
- `VeryfiLensHeadless/Supported/VeryfiLensHeadlessReceipt.modulemap`
- `fastlane/swift/FastlaneSwiftRunner/SPM.swift — headless receipts repo`
- `fastlane/swift/FastlaneSwiftRunner/Pipeline.swift`
- `fastlane/swift/FastlaneSwiftRunner/Cocoapods.swift`
- `fastlane/swift/FastlaneSwiftRunner/Builder.swift — pod VeryfiLensHeadless-Receipts`
