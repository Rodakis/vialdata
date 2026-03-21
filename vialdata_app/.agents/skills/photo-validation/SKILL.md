---
name: remito-photo-evidence-check
description: Failsafe skill to verify that a remito includes the minimum required photographic evidence, correct file types, and valid linkage to the corresponding remito number.
license: Internal use
---

This skill acts as a photographic evidence gatekeeper. It validates that every remito includes the required photo evidence, explicitly associates images with the correct remito number, and detects operational conflicts.

## Expected Input Context

You will receive data containing:
1. `current_remito_number`: The reference number being validated.
2. `attachments`: A list of attached files (including metadata such as filename, MIME type, or assigned labels).
3. `active_policy` (Optional): Specific rules regarding minimum image count or required categories (e.g., "Carga", "Descarga"). 

If no policy is provided, apply the default:
- At least 1 valid image linked to the current remito.

## Validation Rules

Evaluate the input against the following strict criteria:

### 1. Evidence Presence & Type
- A remito MUST include at least the minimum required number of valid image files.
- Valid images are identified by:
  - MIME types: `image/jpeg`, `image/png`, `image/heic`, `image/webp`, OR
  - File extensions: `.jpg`, `.jpeg`, `.png`, `.heic`, `.webp`
- If MIME type is missing, fallback to file extension.
- Non-image files (e.g., `.pdf`, `.docx`) MUST NOT count as photographic evidence.
- Missing, null, or empty attachment arrays count as zero evidence.

### 2. Remito Association
- At least one valid image MUST be explicitly linked to the `current_remito_number`.
- A valid linkage is established if the `current_remito_number` is present in:
  - The filename (e.g., `remito_12345_carga.jpg`)
  - Structured metadata fields or system labels.
- Images lacking any clear link must be logged as unlinked.

### 3. Conflict Detection
- If an image filename or metadata explicitly references a different remito number, it MUST be flagged as conflicting evidence.

### 4. Category Coverage
- If `active_policy` defines required photo categories (e.g., "Carga", "Descarga"), all required categories MUST be present across the valid, linked images.

### 5. Validation Behavior (Pass/Fail Logic)
A remito is strictly **INVALID** if ANY of the following conditions are met:
1. The number of valid image files is below the policy minimum (or 0).
2. No valid image is explicitly linked to the `current_remito_number`.
3. Required categories from `active_policy` are missing.
4. **Any conflicting remito references are detected** (cross-contamination of trip evidence).

*Note: Additional unlinked images that do not explicitly conflict with the current remito do NOT invalidate the submission, but must be reported in `unlinked_photos`.*

## Output Constraints

- Return RAW JSON ONLY.
- Do NOT wrap the response in markdown code fences (```json ... ```).
- Do NOT include any text, conversational filler, or explanations outside the JSON object.
- Do NOT assume visual correctness; rely strictly on metadata and structure.
- All JSON output fields MUST be present exactly as defined, even if arrays are empty.

## Output Format

Return ONLY a JSON object matching this exact structure:

If the remito is **VALID**:
{
  "status": "VALID",
  "missing_photo_types": [],
  "unlinked_photos": [],
  "conflicting_remito_references": [],
  "errors": []
}

If the remito is **INVALID** (due to missing data, lack of linkage, or conflicts):
{
  "status": "INVALID",
  "missing_photo_types": ["<list missing categories required by policy>"],
  "unlinked_photos": ["<list of filenames or IDs without valid remito linkage>"],
  "conflicting_remito_references": [
    {
      "photo": "<filename_or_id>",
      "expected_remito_number": "<current_remito_number>",
      "detected_remito_number": "<other_remito_number>"
    }
  ],
  "errors": [
    {
      "field": "photo_evidence",
      "issue": "<concise operational explanation of why it failed>"
    }
  ]
}