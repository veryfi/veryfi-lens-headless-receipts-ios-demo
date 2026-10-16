# Implementation

## Credentials

```swift
let credentials = VeryfiLensHeadlessCredentials(
    clientId: "<clientId>",
    username: "<username>",
    apiKey: "<apiKey>",
    url: "https://api.veryfi.com"
)
```

Empty fields: `completion(false)` and `veryfiLensError` message `invalid_credentials`, `data.empty_fields`, once the delegate is set.

Calls made before configure, or after credentials fail validation, report `veryfiLensError` with `"No valid credentials"`.

## Configure and upload

```swift
VeryfiLensHeadless.shared().delegate = self
VeryfiLensHeadless.shared().configure(with: credentials, settings: settings) { success in
    guard success else { return }
    VeryfiLensHeadless.shared().upload(images: images) // at most 4; extras are dropped
}
```

`upload(url:)` sends one file URL. `upload(images:)` caps at 4 (`prefix` when `count > 4`).

Live preview, after configure:

```swift
VeryfiLensHeadless.shared().setCameraSessionQueue(sessionQueue)
VeryfiLensHeadless.shared().startProcessingBuffer()
VeryfiLensHeadless.shared().processWithBlock(buffer: sampleBuffer) { rectangles, buffer in
    let converted = VeryfiLensHeadless.shared().adjustedRectangles(
        rectangles,
        for: buffer,
        videoPreviewLayer: previewLayer
    )
    // Host draws converted. RectangleFeature is part of this public method signature.
}
```

Still image:

```swift
let rotated = VeryfiLensHeadless.shared().rotate(image: image)
VeryfiLensHeadless.shared().crop(image: rotated) { cropped in
    VeryfiLensHeadless.shared().upload(images: cropped)
}
```

`crop(image:for:completion:)` uses host-supplied rectangles. `detectedDocuments(for:videoPreviewLayer:)` is the other rectangle read.

When the screen goes away:

```swift
VeryfiLensHeadless.shared().stopProcessingBuffer()
VeryfiLensHeadless.shared().close()
```

`RectangleFeature` is listed in the explicit private module `VeryfiLensHeadlessReceipts_Private`. The in-repo demo calls these methods with `import VeryfiLensHeadlessReceipts` only. Do not import the private module in client code.

A `VeryfiLensCreditCardsSettings` instance on this binary fails the cast. Error string: `Wrong VeryfiLensHeadlessSettings instance is used. Make sure VeryfiLensHeadlessSettings instance is used`.

## Not the UI SDK

`VeryfiLens.shared().headlessUpload` and `uploadImages(paths:)` are UI SDK helpers. Do not use them with this module. They are not this Headless lifecycle.

There is no Lens gallery or Files browser in this product. The host supplies images or frames.

## Local files

`deleteLocalResources` is hardcoded true in the receipts uploader. Image paths in `update` can disappear when processing finishes. Copy during `update`. There is no `autoDeleteLocalResourcesAfterProcessing` on `VeryfiLensReceiptSettings`. Do not expect `local_package_path`. `uploadWithoutProcessing` is hardcoded false, so this is not the UI SDK decoupling handoff.
