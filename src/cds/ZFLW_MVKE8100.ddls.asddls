/*
  Материалы с данными сбыта 8100/10 (MVKE) — вспомогательное вью для ZMAT и правила
  «текущий материал» (D18, 4-17-30). Литералы — в WHERE отдельного вью, а не в ON-условии
  join: так вью активируется на ABAP 7.50 без оговорок.
  LVORM (пометка на удаление) намеренно не учитывается — решение D18.
*/
@AbapCatalog.sqlViewName: 'ZFLWMVKE81V'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Фловеон: материалы сбыта 8100/10'
define view ZFLW_MVKE8100
  as select from mvke
{
  key mvke.matnr as matnr
}
where mvke.vkorg = '8100'
  and mvke.vtweg = '10'
