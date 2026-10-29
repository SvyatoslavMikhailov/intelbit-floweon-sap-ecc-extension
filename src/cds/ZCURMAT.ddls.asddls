/*
  CDS-вью «текущий материал» → OData EntitySet CurrentMaterialSet сервиса ZMAT_SRV
  (контракт Фловеон, 4-17-30). Правило выбора — ZFLW_CURMAT_D / ZFLW_CURMAT_M; здесь
  только наименование (MAKT, язык сессии; нет текста — пустое, строка не теряется).
  Одна строка на REF. Фильтр OData: Bismt eq '<REF>' (импорт REF по запросу).
*/
@AbapCatalog.sqlViewName: 'ZFLWCMATV'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Фловеон: текущий материал REF'
define view ZCURMAT
  as select from ZFLW_CURMAT_M as cur
    left outer join makt on  makt.matnr = cur.Matnr
                         and makt.spras = $session.system_language
{
  key cur.Bismt  as Bismt,
      cur.Matnr  as Matnr,
      cur.Ersda  as Ersda,
      makt.maktx as Maktx
}
