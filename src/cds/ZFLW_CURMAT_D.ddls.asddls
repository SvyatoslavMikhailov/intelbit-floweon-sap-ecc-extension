/*
  «Текущий материал» REF (D18), шаг 1 из 2: последняя дата создания по каждому REF.
  REF = MARA-BISMT. Кандидаты фильтруются ДО агрегации: сбыт 8100/10 (ZFLW_MVKE8100),
  сектор MARA-SPART = '01', непустой BISMT. Исключения REF (XXX, БП-…) здесь не
  применяются — это настройка клиента в пресете b24-sap (правило filter-ref-exclusions).
  ABAP 7.50: оконных функций нет → два вью с GROUP BY вместо ROW_NUMBER().
*/
@AbapCatalog.sqlViewName: 'ZFLWCMATDV'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Фловеон: текущий материал — max ERSDA'
define view ZFLW_CURMAT_D
  as select from mara
    inner join ZFLW_MVKE8100 as sales on sales.matnr = mara.matnr
{
  key mara.bismt     as Bismt,
      max(mara.ersda) as MaxErsda
}
where mara.bismt <> ''
  and mara.spart = '01'
group by
  mara.bismt
