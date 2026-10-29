# Changelog

## [Unreleased]

### Добавлено (4-17-30, решения БОВА)

- «Текущий материал» REF (D18): CDS `ZFLW_MVKE8100`, `ZFLW_CURMAT_D` (max ERSDA),
  `ZFLW_CURMAT_M` (max MATNR), `ZCURMAT` → `ZMAT_SRV/CurrentMaterialSet`; ABAP 7.50 без
  оконных функций, фильтр кандидатов до агрегации. Исключения REF — в пресете, не в SAP.
- `ZMAT`: поля `Bismt`, `Ersda`, `Spart`, `Sales8100`.
- `ZCUST_SRV`: сущность `CustomerBank`, навигация `ToBankDetails`, `CREATE_DEEP_ENTITY`;
  ФМ — параметр `IT_BANKS`, проверка БИК (9) и счёта (20). TODO с вариантами: 20-значный
  счёт в KNBK (BANKN/BKONT/BKREF) и отсутствующий BNKA.

### Изменено (4-17-30)

- ФМ `Z_CUSTOMER_CREATE_VIA_ODATA` — только создание (D17): дубль по ИНН/КПП →
  `CUSTOMER_DUPLICATE`, ветки изменения нет.
- `ODATA_CONTRACT.md` синхронизирован с коннектором `intelbit-floweon-connector-sap` 0.3.0.

### Изменено

- Переименование river → floweon (имя продукта Интелбит.Фловеон, D-1 от 21.07.2026):
  репозиторий `intelbit-river-sap-ecc-extension` → `intelbit-floweon-sap-ecc-extension`, документация, README,
  CLAUDE.md — «Интелбит.Фловеон». Прежнее имя продукта — Интелбит:Река.
- ABAP-объекты (в т.ч. sqlViewName `ZRIVER*`) не менялись — см. примечание в README.
