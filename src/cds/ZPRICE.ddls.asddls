/*
  CDS-вью цен → OData EntitySet PriceSet (контракт Река).
  Источник: KONP + A-таблица условия (для PR00 сбыт. орг. — обычно A304/A305;
  конкретная таблица доступа зависит от схемы калькуляции БОВА — уточнить OQ).
  Фильтр сбытовой организации Vkorg = '8100' (БОВА).
  Скелет-референс.
*/
@AbapCatalog.sqlViewName: 'ZRIVERPRCV'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Цены для Интелбит:Река'
define view ZPRICE
  as select from konp
    -- TODO(OQ): join на A-таблицу доступа (A304/A305/…) под схему БОВА для Vkorg/Matnr/DatabFrom.
{
  key konp.knumh                  as Knumh,
      cast( '' as vkorg )         as Vkorg,      // из A-таблицы (сбыт. орг. 8100)
      cast( '' as matnr )         as Matnr,      // из A-таблицы
      konp.kschl                  as Kschl,
      konp.kbetr                  as Kbetr,
      konp.konwa                  as Konwa,
      konp.kpein                  as Kpein,
      cast( '' as datab )         as DatabFrom   // дата начала действия (A-таблица KONH-DATAB)
}
