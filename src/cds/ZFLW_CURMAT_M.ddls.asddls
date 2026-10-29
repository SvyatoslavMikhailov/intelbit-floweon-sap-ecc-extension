/*
  «Текущий материал» REF (D18), шаг 2 из 2: среди кандидатов с последней датой создания
  (ZFLW_CURMAT_D) — наибольший MATNR. Те же фильтры кандидатов, что в шаге 1, — иначе
  дата могла бы прийти от материала, не прошедшего фильтр.
*/
@AbapCatalog.sqlViewName: 'ZFLWCMATMV'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Фловеон: текущий материал — max MATNR'
define view ZFLW_CURMAT_M
  as select from mara
    inner join ZFLW_MVKE8100 as sales  on  sales.matnr = mara.matnr
    inner join ZFLW_CURMAT_D as latest on  latest.Bismt    = mara.bismt
                                       and latest.MaxErsda = mara.ersda
{
  key mara.bismt      as Bismt,
      mara.ersda      as Ersda,
      max(mara.matnr) as Matnr
}
where mara.spart = '01'
group by
  mara.bismt,
  mara.ersda
