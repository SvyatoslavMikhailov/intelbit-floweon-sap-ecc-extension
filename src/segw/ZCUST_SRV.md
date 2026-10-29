# SEGW OData-проект `ZCUST_SRV`

OData V2 сервис записи контрагента (контракт Фловеон). Регистрируется и активируется в SAP
Gateway (`/IWFND/MAINT_SERVICE`). Скелет-референс модели — реализуется ABAP-командой.

## EntityType `Customer`

Плоская сущность (минимальный core). Глубина CMD_EI_API спрятана в Z-ФМ.

| Property | EDM type | Key | SAP | Назначение |
|----------|----------|:---:|-----|------------|
| `Kunnr` | Edm.String(10) | ✔ (после create) | KNA1-KUNNR | номер контрагента (возврат) |
| `Name` | Edm.String(35) | | KNA1-NAME1 | наименование (обяз.) |
| `Land1` | Edm.String(3) | | KNA1-LAND1 | страна |
| `Ort01` | Edm.String(35) | | KNA1-ORT01 | город |
| `Pstlz` | Edm.String(10) | | KNA1-PSTLZ | индекс |
| `Stras` | Edm.String(35) | | KNA1-STRAS | улица |
| `Stcd1` | Edm.String(16) | | KNA1-STCD1 | ИНН |
| `Stcd2` | Edm.String(11) | | KNA1-STCD2 | КПП |
| `Bukrs` | Edm.String(4) | | — | балансовая единица |
| `Vkorg` | Edm.String(4) | | — | сбытовая организация (8100) |
| `Ktokd` | Edm.String(4) | | — | группа счёта |

## EntityType `CustomerBank` (4-17-30)

Банковские реквизиты клиента (KNBK). Приходят только вложенными в создание клиента
(deep insert через навигацию `ToBankDetails`); отдельного POST нет.

| Property | EDM type | Key | SAP | Назначение |
|----------|----------|:---:|-----|------------|
| `Kunnr` | Edm.String(10) | ✔ | KNBK-KUNNR | клиент (заполняется после create) |
| `Banks` | Edm.String(3) | ✔ | KNBK-BANKS | страна банка (`RU`) |
| `Bankl` | Edm.String(15) | ✔ | KNBK-BANKL | ключ банка = БИК (9 цифр) |
| `Bankn` | Edm.String(20) | ✔ | см. TODO | расчётный счёт — **20 цифр** как в Bitrix24 |
| `Korrs` | Edm.String(20) | | BNKA (см. TODO) | корр. счёт банка |
| `Banka` | Edm.String(60) | | BNKA-BANKA | наименование банка (справочно) |
| `Xmain` | Edm.String(1) | | — | `X` — основной счёт (первый) |

Ассоциация `Customer` 1 → N `CustomerBank`, навигация `ToBankDetails`.

==TODO (решение БОВА/SAP-команды, не додумывать):== KNBK-BANKN — 18 символов, а
российский счёт — 20 цифр. Варианты: (а) BANKN = первые 18, BKONT = последние 2
(локализация RU); (б) BANKN = первые 18, полный счёт в KNBK-BKREF; (в) иной принятый в
БОВА способ. Коннектор передаёт 20 цифр в `Bankn` — разбиение делает Z-ФМ.
Нет записи BNKA для (Banks, Bankl): варианты — (а) отказ `BANK_NOT_FOUND` (задача логисту);
(б) создать BNKA (`BAPI_BANK_CREATE`, наименование/корр. счёт из запроса); (в) завести
вручную SAP-командой.

## EntitySet `CustomerSet`

- **createEntity** (POST, без навигации) → `Z_CUSTOMER_CREATE_VIA_ODATA`, вернуть `Kunnr`.
- **createDeepEntity** (POST с `ToBankDetails`) → то же с таблицей банковских реквизитов.
- **getEntitySet** (GET) с `$filter` по `Stcd1` (+`Stcd2`) — дедуп на стороне пресета.
- Только создание (D17): клиент с тем же `Stcd1`/`Stcd2` → ошибка `CUSTOMER_DUPLICATE`
  (пресет b24-sap ищет клиента до записи и в этом случае только связывает).

## Реализация

Redefine методы в классе `ZCL_ZCUST_DPC_EXT` (наследник `*_DPC`):
- `CUSTOMERSET_CREATE_ENTITY` — см. `DPC_EXT.abap`.
- `/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY` — клиент + `ToBankDetails`.
- `CUSTOMERSET_GET_ENTITYSET` — SELECT из KNA1 по `STCD1`/`STCD2`, маппинг в плоский `Customer`.

CSRF включён по умолчанию (POST требует `X-CSRF-Token`).
