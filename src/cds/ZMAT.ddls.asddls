/*
  CDS-вью номенклатуры → OData EntitySet MaterialSet (контракт Река).
  Источник: MARA + MAKT (+ MVKE 8100/10 — признак Sales8100). SAP ECC 6.0 EHP8 (ABAP 7.50).
  4-17-30: Bismt (REF), Ersda, Spart, Sales8100 — для сверки с «текущим материалом».
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
    left outer join ZFLW_MVKE8100 as sales on sales.matnr = mara.matnr
{
  key mara.matnr as Matnr,
      makt.maktx as Maktx,
      mara.meins as Meins,
      mara.mtart as Mtart,
      mara.matkl as Matkl,
      mara.bismt as Bismt,
      mara.ersda as Ersda,
      mara.spart as Spart,
      // Нет строки MVKE 8100/10 → NULL → сравнение ложно → ''.
      case when sales.matnr > '' then 'X' else '' end as Sales8100
}
