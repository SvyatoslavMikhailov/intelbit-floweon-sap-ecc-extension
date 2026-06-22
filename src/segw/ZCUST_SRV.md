# SEGW OData-проект `ZCUST_SRV`

OData V2 сервис записи контрагента (контракт Река). Регистрируется и активируется в SAP
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

## EntitySet `CustomerSet`

- **createEntity** (POST) → вызвать `Z_CUSTOMER_CREATE_VIA_ODATA`, вернуть `Kunnr` либо OData-ошибку.
- **getEntitySet** (GET) с `$filter` по `Stcd1` (+`Stcd2`) — дедуп на стороне пресета.

## Реализация

Redefine методы в классе `ZCL_ZCUST_DPC_EXT` (наследник `*_DPC`):
- `CUSTOMERSET_CREATE_ENTITY` — см. `DPC_EXT.abap`.
- `CUSTOMERSET_GET_ENTITYSET` — SELECT из KNA1 по `STCD1`/`STCD2`, маппинг в плоский `Customer`.

CSRF включён по умолчанию (POST требует `X-CSRF-Token`).
