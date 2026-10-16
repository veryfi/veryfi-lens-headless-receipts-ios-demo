# Clarifications

## Resolved enough to integrate

- Settings type is `VeryfiLensReceiptSettings`. Demo `VeryfiLensReceiptsSettings` is a different class.
- Uploader is cloud API, processes the document, and deletes local resources. Those switches are not public properties.
- `upload(images:)` close callback means upload start. `upload(url:)` does not emit that close.
- `pdfFormatIsOn` defaults true, is passed to the packager, and is omitted from `json`.
- Backups default false.

## Unconfirmed

- Other `documentType` values on this binary.
- Whether the location read prompts, and which iCloud entitlement `backupImagesToiCloud` requires.
- Whether `noCompress` is read even though it is omitted from `json`.
- Who should enable `boostModeIsOn` or change `isGPUOn`.
- XCFramework deployment target.
- Public mirror URL for `veryfi-lens-spm-headless-receipts`.
- Receipt API field names inside success `data`. Do not invent them.
