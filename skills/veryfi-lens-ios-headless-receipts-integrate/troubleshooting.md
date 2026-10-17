# Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Wrong settings instance error | `VeryfiLensSettings`, the Demo receipts subclass, or credit-card settings | Pass `VeryfiLensReceiptSettings` |
| `veryfiLensClose` fires immediately | `upload(images:)` emits close at upload start | Wait for `veryfiLensSuccess` `status` `done` |
| Image path missing on success | `deleteLocalResources` is hardcoded true | Copy during `update` |
| Host expected `local_package_path` | This uploader is not decoupling | Cloud extract only. No public flag turns local retention on |
| `"No valid credentials"` | Called before configure, or validation failed | Wait for `completion(true)` |
| Photos prompt or copies | `backupImagesToGallery` true | Leave false and omit the add-usage string |
| Rectangles offset from the preview | Coordinates are buffer space until adjusted | Use `adjustedRectangles` for the preview layer |
| Full SPM package linked | `veryfi-lens-spm.git` | Use `veryfi-lens-spm-headless-receipts` |

## Conflicts

- Do not set an engine enum. There is nowhere to put `.none` or `.inApp` on this type.
- Do not import `VeryfiLensHeadlessReceipts_Private`.
- Do not use UI `uploadImages` or `headlessUpload` and expect this delegate.
- More than 4 images: extras are dropped. That is the cap, not a second package.
- Do not promise check TIFF, credit-card PAN reads, or Any-Documents templates.

App size: [SDK binary sizes](https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/). Measure the final app with the SDK linked and without it.
