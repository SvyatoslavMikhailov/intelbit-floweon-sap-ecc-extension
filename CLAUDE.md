# CLAUDE.md — intelbit-river-sap-ecc-extension

Гайд для Claude Code по этому репозиторию.

## Что это

ABAP-сторона интеграции SAP ECC 6.0 EHP8 ↔ Интелбит:Река (Apache 2.0). Companion к
Python-коннектору `intelbit-river-connector-sap`. Содержит **референс-скелеты**:
CDS-вью чтения, SEGW OData-модель, Z-ФМ записи контрагента через CMD_EI_API.

## Важно

- ==Реальную бизнес-логику ABAP не дописывать до уточнения полей у БОВА (OQ-3/OQ-5 ADR-001).==
  Это скелеты с сигнатурами и комментариями ключевых шагов.
- ABAP в CI **не компилируется** (GH-раннер не собирает ABAP). CI — только markdown-lint.
- Канонический OData-контракт — `src/docs-contract/ODATA_CONTRACT.md`. Он **должен быть
  синхронен** с `docs/ODATA_CONTRACT.md` коннектора `intelbit-river-connector-sap`.
- Имена полей/таблиц ECC-специфичны (KNA1/MARA/KONP/MARD, CMD_EI_API) — это намеренно,
  версионная специфика инкапсулирована здесь.

## Структура

- `src/cds/*.asddls` — CDS DDL чтения (ZMAT/ZPRICE/ZSTOCK).
- `src/segw/` — модель ZCUST_SRV + DPC_EXT (create_entity → Z-ФМ).
- `src/fm/` — Z_CUSTOMER_CREATE_VIA_ODATA (скелет CMD_EI_API + дедуп по ИНН/КПП).
- `docs/` — INSTALL (импорт в SAP), SECURITY.

---

## LLM Coding Guidelines (Karpathy)

Behavioral guidelines to reduce common LLM coding mistakes.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

*Source: https://github.com/forrestchang/andrej-karpathy-skills/blob/main/CLAUDE.md*
