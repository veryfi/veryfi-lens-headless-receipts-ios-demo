---
name: veryfi-lens-ios-headless-receipts-integrate
description: >-
  Integrates the Veryfi Lens iOS Headless Receipts SDK. Covers pod
  VeryfiLensHeadless-Receipts, SPM repo veryfi-lens-spm-headless-receipts,
  VeryfiLensReceiptSettings, host-owned capture, upload(images:), and cloud
  Process a Document. Use when the app owns the camera or already has receipt
  images and calls VeryfiLensHeadless.
---

# Veryfi Lens iOS Headless Receipts

No Lens camera UI. The host owns capture, or it already has images, and calls `VeryfiLensHeadless`.

**Settings type:** `VeryfiLensReceiptSettings` (singular Receipt). It conforms to `VeryfiLensHeadlessSettings`. It is not `VeryfiLensSettings` and it is not the Demo UI class `VeryfiLensReceiptsSettings`.

**Credentials:** `VeryfiLensHeadlessCredentials`. **Entry:** `VeryfiLensHeadless.shared()`.

The uploader hardcodes `dataExtractionEngine: .cloudAPI`, `uploadWithoutProcessing: false`, `async: false`, and `deleteLocalResources: true`. There is no engine enum on this settings type. Cloud Process a Document is what a successful upload does. Local package retention cannot be turned off with a public flag.

## Quick flow

Assumptions: receipt images the host already has, or a host camera that will upload crops. Cloud extraction. Backups off.

1. Install [install.md](install.md). Import `VeryfiLensHeadlessReceipts`.
2. Apply [settings.md](settings.md). Leave `documentType` at `.receipt`.
3. `configure`, then `upload(images:)` (at most 4) or the live buffer path in [implementation.md](implementation.md).
4. Handle close, update, and success in [callbacks.md](callbacks.md). Copy files during `update`. Local deletion is hardcoded on.
5. Track [checklist.md](checklist.md).

## Guided flow

| Topic | Options |
|-------|---------|
| Input | `upload(images:)` up to 4, `upload(url:)` for one file, or live `processWithBlock` plus crop then upload |
| Backup | Photos or iCloud copies. Both default false. Turn on only if the host wants those copies |
| PDF | `returnStitchedPDF` default false |
| Blur in the response | `detectBlurResponseIsOn` default false. It does not block capture |

If the host wants the Lens camera screen, that is the receipts UI SDK (`VeryfiLens` and `VeryfiLensSettings`), a different binary. `VeryfiLens.shared().headlessUpload` is that UI SDK’s helper, not this module.

## Workflow

```
Headless receipts:
- [ ] Artifact
- [ ] VeryfiLensReceiptSettings
- [ ] configure
- [ ] upload or live detect
- [ ] Delegate
- [ ] Copy files during update
```

- [install.md](install.md)
- [implementation.md](implementation.md)
- [settings.md](settings.md)
- [callbacks.md](callbacks.md)
- [troubleshooting.md](troubleshooting.md)
- [clarifications.md](clarifications.md)
- [checklist.md](checklist.md)

## Warnings

- Credit card data is local only and is never sent to the backend. `.inApp` (`"mobile"`) is the on-device engine for `credit_card`, `code`, and `barcode` on the UI SDK. This receipts uploader is cloud extraction and is not a card path.
- Any-Documents is a broad solution: `any_document` plus `anyDocumentTemplate`. Nutrition facts, US passport, driver license, and prescription labels are shortcut flavors of Any-Documents, not separate products. Contact support for another template, including one that is not supported yet. Do not set `anyDocumentType`. This binary is not that solution.
- Local fraud detection and local field detection are paid features gated by the validated account and backend entitlement. They are not properties of this headless settings type. Do not invent `fraudDetectionIsOn` or `documentFieldsToDetect` here. Field detection also needs the Field Detection or Remote Models flavor on the UI SDK.
- Bank-check TIFF (`retrieveCheckTiffIsOn`) requires Remote Models. It is not part of this product and it is not in the Checks-specific UI flavor yet, because the TIFF model is large.
- When installed size matters, recommend Remote Models for flavors that embed heavy models, and measure the final app with this SDK linked and without it. Do not quote the XCFramework file size. [SDK binary sizes](https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/).
- `VeryfiLens.shared().uploadImages` and `VeryfiLens.shared().headlessUpload` are UI SDK helpers. They are not this Headless product.
- Leave `backupImagesToGallery` and `backupImagesToiCloud` false unless the host wants every scan copied into Photos or iCloud. Both default false on this type. The UI SDK’s `backupDocsToGallery` still defaults true, and that property is not this type.
- UI client code uses `VeryfiLensSettings()`. Demo subclasses are not a client contract. This product does not use them either.


## Suggestions

- Upload at most 4 images. Extras are dropped.
- Copy image paths inside `veryfiLensUpdate`. There is no public flag to keep local resources.
- Add bounding boxes, confidence, address parse, or blur response only when the host wants those fields in the cloud response.
- If size matters, Remote Models is the recommendation for embedded-model flavors. This pack does not claim a Remote Models build replaces this headless binary. Measure the app with and without the dependency you link. [SDK binary sizes](https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/).

## Do not

- Do not pass `VeryfiLensSettings` or `VeryfiLensReceiptsSettings` into `configure`.
- Do not set a `dataExtractionEngine`. The uploader is cloud API.
- Do not expect `local_package_path`.
- Do not use `VeryfiLens.shared().headlessUpload` or `uploadImages(paths:)`.
- Do not install the Full `veryfi-lens-spm` package.
- Do not import `VeryfiLensHeadlessReceipts_Private`.
- Do not turn gallery backup on unless the host wants Photos filled.

## Output

Host sample includes plist keys actually needed, `configure` with `VeryfiLensReceiptSettings`, one of upload or the live buffer path, and a delegate that treats `veryfiLensClose` on `upload(images:)` as upload start.
