/*
  CDS-вью номенклатуры → OData EntitySet MaterialSet (контракт Река).
  Источник: MARA + MAKT. SAP ECC 6.0 EHP8 (ABAP CDS, 7.40+).
  Скелет-референс: активируется и регистрируется германской SAP-командой / Интелбит.
*/
@AbapCatalog.sqlViewName: 'ZRIVERMATV'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Номенклатура для Интелбит:Река'
define view ZMAT
  as select from mara
    inner join makt on  makt.matnr = mara.matnr
                    and makt.spras = $session.system_language
{
  key mara.matnr as Matnr,
      makt.maktx as Maktx,
      mara.meins as Meins,
      mara.mtart as Mtart,
      mara.matkl as Matkl
}
