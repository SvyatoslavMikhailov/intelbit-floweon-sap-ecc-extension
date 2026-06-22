/*
  CDS-вью складских остатков → OData EntitySet StockSet (контракт Река).
  Источник: MARD (остатки по складам) + MARC (данные завода — при необходимости).
  Поле Labst — свободный остаток (MARD-LABST).
  Скелет-референс.
*/
@AbapCatalog.sqlViewName: 'ZRIVERSTKV'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Остатки для Интелбит:Река'
define view ZSTOCK
  as select from mard
{
  key mard.matnr as Matnr,
  key mard.werks as Werks,
  key mard.lgort as Lgort,
      mard.labst as Labst
}
