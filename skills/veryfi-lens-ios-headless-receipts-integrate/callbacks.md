# Callbacks

`VeryfiLensHeadlessDelegate`: close, error, success, update. No help callback.

`upload(images:)` calls the upload-start helper with a close response before the network upload. That invokes `veryfiLensClose` at **upload start**, with queue count and scan count. It does not mean the user dismissed a camera. `upload(url:)` does not call that start/close helper.

Progress and the cloud result then arrive on `veryfiLensUpdate` and `veryfiLensSuccess`. Success `status` is `"done"` for the hardcoded cloud API engine. `document_type` is the settings `documentType` raw string (`receipt` by default).

Package success can include the usual cloud `data` payload. This pack does not list receipt API field names. Do not invent them.

Because local resources are deleted, image paths in `update` can disappear when processing finishes. Copy during `update`.

`veryfiLensError` includes `invalid_credentials` and `"No valid credentials"` when configure did not succeed.

`backupImagesToGallery` true copies into Photos and needs the add-usage string.

Fraud and field-detection keys are not unlocked by this settings type. Those features are paid and backend-gated on the account, and field detection needs its UI flavor.
