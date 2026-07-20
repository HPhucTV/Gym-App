# Task 3 Report: Secure Photo-Analysis HTTP API

## Outcome

Implemented the three photo-analysis routes on the existing Express server:

- `POST /api/food-analyses` with one `primaryImage`
- `POST /api/food-analyses/:analysisId/images` with one `secondaryImage`
- `POST /api/food-analyses/:analysisId/confirmations` with bounded JSON

The upload boundary uses Multer memory storage, a 5 MB limit, a one-file/zero-text-field contract, and JPEG/PNG/WebP magic-byte detection. Uploaded buffers are overwritten and released after service completion. The existing 15-minute structured session store remains the only workflow persistence.

Errors now use one non-leaky JSON envelope. The new workflow has a dedicated per-IP rate limit and privacy-safe, allowlisted telemetry. Importing `server.js` no longer starts a listener, and all legacy endpoints remain mounted.

## Red-Green Evidence

Initial focused red:

```text
node --test test/food_analysis_routes_test.js
FAIL: Cannot find module '../src/food-analysis/router'
```

Additional focused reds:

```text
node --test test/analysis_logger_test.js
FAIL: Cannot find module '../src/http/analysis_logger'

node --test --test-name-pattern="fails closed without a Gemini key" test/gemini_food_observer_test.js
FAIL: fetch was called

node --test --test-name-pattern="emits bounded workflow telemetry" test/food_analysis_service_test.js
FAIL: expected workflow events, received none
```

Focused green:

```text
node --test test/food_analysis_routes_test.js test/analysis_logger_test.js
PASS: 12 tests
```

## Verification

```text
npm test
PASS: 55 tests, 0 failures

node -e "const { app } = require('./server'); if (!app) process.exit(1)"
PASS: process exited without opening a port

npm audit --omit=dev
PASS: found 0 vulnerabilities
```

Direct smoke checks:

```text
legacy POST /api/analyze-food without a file -> 400
legacy GET /api/scan-barcode without a barcode -> 400
new photo route without GEMINI_API_KEY -> 503 ANALYSIS_UNAVAILABLE
malformed confirmation JSON -> 400 INVALID_CONFIRMATION
```

## Security Review

Brief STRIDE abuse-case pass:

- **Spoofing:** There are no user accounts in product scope. Analysis IDs are random UUIDs and invalid/unknown IDs receive stable generic errors.
- **Tampering:** Client MIME headers and filenames are ignored for trust decisions; magic bytes select the canonical provider MIME type. Confirmation input is validated by the existing strict service schemas.
- **Repudiation:** Every new request receives a correlation UUID. Only bounded event/status/error buckets are logged.
- **Information disclosure:** Error responses exclude filenames, headers, request values, stacks, and provider responses. Telemetry discards images, labels, prompts, history, and arbitrary fields.
- **Denial of service:** Uploads are memory-only, limited to one 5 MB file, JSON is limited to 32 KB, per-IP rate limiting is active, provider calls retain their timeout, and structured sessions expire after 15 minutes with a bounded capacity.
- **Elevation of privilege:** The workflow performs no privileged action and has no account/role surface. It exposes only create/add/confirm operations over opaque analysis IDs.

Additional checks:

- No new photo-analysis module imports `fs` or writes uploads to disk.
- Missing Gemini configuration fails closed before `fetch` and does not log whether a key exists.
- The default logger emits only allowlisted fields and bounded enums.
- Production dependency audit has no findings to triage.

## Self-Review and Concerns

- Preserved `/api/analyze-food`, `/api/scan-barcode`, `/api/register-barcode`, and the remaining legacy routes.
- Kept the work inside the Node server; no Flutter files were changed.
- The new endpoint intentionally has no account authentication because accounts are excluded from the product scope. Internet deployment must still terminate HTTPS and apply network/platform protections outside this process.
- Magic-byte validation establishes the allowed container signature, not full image integrity; malformed allowed-format data is rejected by the downstream observer as `ANALYSIS_UNAVAILABLE` or `INVALID_PROVIDER_RESPONSE`.
