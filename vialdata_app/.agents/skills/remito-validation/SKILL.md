---
name: remito-data-validation
description: Failsafe skill to verify that a remito contains all mandatory operational fields, correct data formats, and basic logical consistency before it can be submitted to the database.
license: Internal use
---

This skill acts as a strict gatekeeper. It validates that every remito includes the minimum required operational data before submission, ensuring that no incomplete or invalid records enter the system.

The user or system provides a remito record in key-value format (JSON or plain text).

## Thinking Framework

Before approving a remito, analyze the following:
- Completeness: Are all universally required fields explicitly present?
- Data Integrity: Do the values match the expected type and format?
- Usability: Can administration, logistics, and billing use this record without guessing or needing to contact the operator?
- Traceability: Does the remito clearly identify the trip, the project, and the vehicle involved?

## Core Rules

- A remito MUST NOT be approved if any mandatory field is missing, empty, null, or invalid.
- Empty strings (""), "null", "undefined", "N/A", "---", "test", "x", or whitespace-only values count as missing data.
- Numeric zero ("0") must be treated as invalid only for fields that require a value strictly greater than zero, such as Cantidad.
- Do not make assumptions or infer missing information.
- Return raw JSON only. Do not wrap the response in markdown code fences (```) and do not include explanatory text outside the JSON object.

## Required Fields (Mandatory)

1. Fecha (Must be a valid system-accepted date or datetime format)
2. Número de Remito (If provided, must not be empty. If absent, assume the system generates it post-validation)
3. Número de Guía (Physical ticket number)
4. Obra
5. Destino
6. Procedencia
7. Tipo de Material
8. Cantidad (Must be a numeric value greater than 0)
9. Unidad de medida (e.g., m3, kg, un)
10. Patente Camión / Vehículo

## Validation Logic

- A field must be listed in `missing_fields` if it is absent, empty, null, whitespace-only, or contains a placeholder value.
- A field must be listed in `errors` if it is present but fails type, format, or logical validation.
- Additional non-required fields may be ignored unless they conflict with required field validation.

## Validation Output Format

Return ONLY a JSON object with the following structure.

If all fields are valid:
{
  "status": "VALID",
  "missing_fields": [],
  "errors": []
}

If any field is missing or invalid:
{
  "status": "INVALID",
  "missing_fields": ["<list field names exactly as required>"],
  "errors": [
    {
      "field": "<field_name>",
      "issue": "<short operational explanation>"
    }
  ]
}

## Avoid

- Approving incomplete remitos under any circumstance
- Treating placeholder text or whitespace as valid data
- Returning conversational filler
- Checking photographic evidence, which belongs to a separate skill