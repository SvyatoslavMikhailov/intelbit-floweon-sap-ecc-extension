# Установка в SAP ECC 6.0 EHP8

Деплоится транспортами в SAP ООО «БОВА Евразия» (германской SAP-командой или Интелбит —
опция по смете). Репозиторий — **референс-скелеты**; объекты создаются/активируются в SAP.

## 1. CDS-вью (чтение)

Создать DDL-источники из `src/cds/` (SE80 / Eclipse ADT) и активировать:

- `ZFLW_MVKE8100` → `ZFLWMVKE81V` (MVKE 8100/10) — **первым**: на него ссылаются ZMAT и
  правило «текущий материал»
- `ZMAT` → SQL-вью `ZRIVERMATV` (MARA+MAKT+MVKE: `Bismt`, `Ersda`, `Spart`, `Sales8100`)
- «Текущий материал» REF (D18), строго по порядку: `ZFLW_CURMAT_D` → `ZFLWCMATDV`,
  `ZFLW_CURMAT_M` → `ZFLWCMATMV`, `ZCURMAT` → `ZFLWCMATV`
- `ZPRICE` → `ZRIVERPRCV` (KONP + A-таблица условия; уточнить таблицу доступа под схему БОВА)
- `ZSTOCK` → `ZRIVERSTKV` (MARD)

## 2. OData-сервисы (SEGW)

Для каждого read-вью завести OData-проект в SEGW (или CDS-exposure через `@OData.publish`),
сгенерировать MPC/DPC, зарегистрировать и активировать в `/IWFND/MAINT_SERVICE`:

- `ZMAT_SRV` / `MaterialSet` и `CurrentMaterialSet` (вью `ZCURMAT`, ключ `Bismt`)
- `ZPRICE_SRV` / `PriceSet`
- `ZSTOCK_SRV` / `StockSet`

Для записи контрагента — проект `ZCUST_SRV` (см. `src/segw/ZCUST_SRV.md`):
- модель `Customer` (плоские поля),
- redefine `CUSTOMERSET_CREATE_ENTITY` (см. `src/segw/DPC_EXT.abap`) → вызов Z-ФМ,
- `CUSTOMERSET_GET_ENTITYSET` с `$filter` по `Stcd1`;
- сущность `CustomerBank` + ассоциация/навигация `ToBankDetails`, redefine
  `CREATE_DEEP_ENTITY` (банковские реквизиты при создании клиента, 4-17-30).
  ==До ввода в эксплуатацию== БОВА/SAP-команда выбирает способ хранения 20-значного счёта
  (BANKN/BKONT/BKREF) и поведение при отсутствии банка в BNKA — варианты в `ZCUST_SRV.md`.

## 3. Z-функция

Создать ФМ `Z_CUSTOMER_CREATE_VIA_ODATA` (см. `src/fm/`) в Z-группе функций (параметр
`IT_BANKS` — табличный тип `ZCUSTOMER_BANK_T` по структуре `CustomerBank`; только
создание — дубль по ИНН/КПП возвращает `CUSTOMER_DUPLICATE`). Дописать
реальную логику CMD_EI_API **после уточнения полей у БОВА** (OQ-3/OQ-5).

## 4. Технический пользователь и права

- Сервисный (тех.) пользователь типа SYSTEM/COMMUNICATION для Basic-аутентификации Фловеона.
- Права `S_SERVICE` на 4 сервиса; `S_RFC` на нужные группы ФМ; объектные полномочия на
  ведение делового партнёра/контрагента (CMD_EI_API).
- CSRF включён (POST требует `X-CSRF-Token: Fetch` → токен).

## 5. Транспорты

Объекты разложить по транспортным запросам (CDS, SEGW-проекты, классы DPC/MPC, ФМ) и
провезти по ландшафту DEV→QAS→PRD.

## Проверка контракта

OData-ответы должны соответствовать `src/docs-contract/ODATA_CONTRACT.md` (синхронен с
коннектором `intelbit-floweon-connector-sap`).
