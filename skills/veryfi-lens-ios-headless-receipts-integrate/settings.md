# Settings

Public type: `VeryfiLensReceiptSettings`. `documentType` is a `DocumentType`, default `.receipt` (`"receipt"`). This is not `documentTypes: [String]`.

Leave `documentType` at `.receipt` on this binary. Other `DocumentType` values are **Unconfirmed** here. The product name and uploader are receipts.

## Recipe

Flags the uploader reads, with backups off:

```swift
let settings = VeryfiLensReceiptSettings()
settings.documentType = .receipt
settings.autoCaptureIsOn = true
settings.isAutoRotationEnabled = true
settings.isSkewCorrectionOn = true
settings.isDewarpingOn = true
settings.cleanBorderIsOn = false
settings.returnStitchedPDF = false
settings.backupImagesToGallery = false       // default; leave false unless Photos copies are wanted
settings.backupImagesToiCloud = false        // default
settings.autoDeleteAfterProcessing = false   // server-side delete, not local file retention
settings.boostModeIsOn = false
settings.computeIsOn = false
settings.boundingBoxesIsOn = false
settings.confidenceDetailsIsOn = false
settings.parseAddressIsOn = false
settings.detectBlurResponseIsOn = false
settings.barcodeExtractionIsOn = false
```

`autoDeleteAfterProcessing` is the server-side delete flag. Local deletion is hardcoded `deleteLocalResources: true`.

## Complete public settings

| Property | Default | Explanation |
|----------|---------|-------------|
| `documentType` | `.receipt` | Leave `.receipt`. Other values are **Unconfirmed** on this binary. |
| `autoCaptureIsOn` | `true` | Live auto-capture. |
| `autoCaptureFrameConfidence` | `10` | Frames required for auto-capture. |
| `autoCaptureMarginRatio` | `0` | Edge margin for auto-capture. |
| `isGPUOn` | `true` | On-device GPU. Included in `json`. Who should change it is **Unconfirmed**. Leave the default. |
| `isDewarpingOn` | `true` | Dewarp before upload. |
| `isSoftBinarizationOn` | `false` | Public flag included in `json`. Leave false unless the host asks. |
| `isSkewCorrectionOn` | `true` | Skew correction. |
| `isAutoRotationEnabled` | `true` | Auto rotation. |
| `returnStitchedPDF` | `false` | Stitched PDF in the package. |
| `stitchedPDFPixelDensityMultiplier` | `2.0` | PDF density. Included in `json`. |
| `barcodeExtractionIsOn` | `false` | Extra barcode extract on the receipt upload. |
| `backupImagesToGallery` | `false` | Copies into Photos. Needs the add-usage string. Leave false unless wanted. |
| `backupImagesToiCloud` | `false` | Copies into iCloud. Leave false unless wanted. |
| `autoDeleteAfterProcessing` | `false` | Server-side delete after process. |
| `boostModeIsOn` | `false` | API boost. **Unconfirmed** who should enable it. |
| `computeIsOn` | `false` | API compute flag on this type. Default false here. |
| `parseAddressIsOn` | `false` | Address parse in the API response. |
| `detectBlurResponseIsOn` | `false` | Blur information in the cloud response. Does not block capture. |
| `confidenceDetailsIsOn` | `false` | Confidence breakdown. |
| `boundingBoxesIsOn` | `false` | Boxes in the API response. |
| `cleanBorderIsOn` | `false` | Border cleanup. |
| `noCompressOnWifi` | `false` | Skip compression on Wi-Fi. Included in `json`. |
| `noCompress` | `false` | Public property. Omitted from `json`. Whether the uploader reads it outside `json` is **Unconfirmed**. |
| `highQualityThumbnail` | `false` | Higher quality thumbnail. Included in `json`. |
| `pdfFormatIsOn` | `true` | Passed to the packager even though it is omitted from `json`. |

There is no `dataExtractionEngine`, `ignoreRemoteSettings`, `documentTypes`, `dictateIsOn`, or `autoDeleteLocalResourcesAfterProcessing` on this type.

`VeryfiLensSettings` backups (`backupDocsToGallery` default true) are a different type. This recipe’s backup flags already default false. Leave them false.

Any-Documents templates are not this receipt uploader. Credit-card settings are the other headless binary. Check TIFF is Remote Models, not this product.
