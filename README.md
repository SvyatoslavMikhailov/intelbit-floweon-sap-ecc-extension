# intelbit-floweon-sap-ecc-extension

**ABAP-сторона** интеграции SAP ECC 6.0 EHP8 ↔ **Интелбит.Фловеон**: CDS-вью чтения + SEGW
OData-сервисы + Z-функция записи контрагента через `CMD_EI_API`. Apache 2.0.

Companion к Python-коннектору
[`intelbit-floweon-connector-sap`](https://github.com/SvyatoslavMikhailov/intelbit-floweon-connector-sap):
коннектор говорит по OData с сервисами, которые определяет это расширение.

**Исторические имена объектов.** SQL-имена CDS-вью `ZRIVERMATV` / `ZRIVERPRCV` / `ZRIVERSTKV`
(`@AbapCatalog.sqlViewName`) — исторические (прежнее имя продукта — Интелбит:Река). ABAP-объекты
не переименовываются до импорта в систему SAP; в документации они указаны как есть.

> **Статус: скелеты v0.1.0.** Референс-объекты с сигнатурами и комментариями ключевых шагов.
> Реальная бизнес-логика ABAP (особенно маппинг `CMD_EI_API`) дописывается **после уточнения
> полей у БОВА** (OQ-3/OQ-5 ADR-001). В CI **не компилируется** (ABAP не собрать в GH-раннере).

## Что внутри

```
src/
├── cds/        ZMAT / ZPRICE / ZSTOCK — CDS DDL (чтение: MARA+MAKT, KONP+A, MARD)
├── segw/       ZCUST_SRV.md (модель CustomerSet) + DPC_EXT.abap (create_entity → Z-ФМ)
├── fm/         Z_CUSTOMER_CREATE_VIA_ODATA.abap (плоские поля → CVI_EI_EXTERN → CMD_EI_API)
└── docs-contract/ODATA_CONTRACT.md   — канонический OData-контракт (синхронен с коннектором)
docs/  INSTALL.md (импорт в SAP, активация, транспорты, права) · SECURITY.md
```

## Деплой

Деплоится транспортами в SAP ООО «БОВА Евразия» — германской SAP-командой или Интелбит
(опция по смете). Порядок — `docs/INSTALL.md`.

## Почему «ecc» в имени

Содержимое ECC-специфично (`CMD_EI_API`, таблицы KNA1/MARA/KONP/MARD). Коннектор остаётся
generic (`intelbit-floweon-connector-sap`) и переиспользуем; версионная специфика SAP
инкапсулирована здесь. Для S/4HANA — отдельный extension-репозиторий со своим контрактом.
