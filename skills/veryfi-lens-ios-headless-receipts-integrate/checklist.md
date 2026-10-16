# Checklist

```
Headless receipts:
- [ ] Pod VeryfiLensHeadless-Receipts or SPM veryfi-lens-spm-headless-receipts
- [ ] import VeryfiLensHeadlessReceipts
- [ ] VeryfiLensReceiptSettings, documentType .receipt
- [ ] Backups left false unless the host asked
- [ ] Delegate on VeryfiLensHeadless.shared()
- [ ] Upload or live path only after configure succeeds
- [ ] At most 4 images
- [ ] veryfiLensClose on upload(images:) treated as start
- [ ] Files copied during update
- [ ] Private module not imported
- [ ] Unconfirmed items not promised
```

Do not add the Full package `veryfi-lens-spm`.

Size questions use a with-and-without app measurement. [SDK binary sizes](https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/).

[clarifications.md](clarifications.md) stays the list of open items.
