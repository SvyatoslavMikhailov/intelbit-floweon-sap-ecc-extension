*&---------------------------------------------------------------------*
*& Z_CUSTOMER_CREATE_VIA_ODATA
*& Создание/обновление контрагента из плоских OData-полей через CMD_EI_API.
*&
*& Скелет-референс (SAP ECC 6.0 EHP8). ==Реальную бизнес-логику не дописывать до
*& уточнения полей у БОВА (OQ-3/OQ-5 ADR-001).== Ниже — сигнатура и ключевые шаги.
*&---------------------------------------------------------------------*
FUNCTION z_customer_create_via_odata.
*"----------------------------------------------------------------------
*"  IMPORTING
*"     VALUE(IS_CUSTOMER) TYPE  ZCUSTOMER_FLAT  " Name/Land1/Ort01/Pstlz/Stras/
*"                                               " Stcd1(ИНН)/Stcd2(КПП)/Bukrs/Vkorg/Ktokd
*"  EXPORTING
*"     VALUE(EV_KUNNR)    TYPE  KUNNR
*"     VALUE(ET_RETURN)   TYPE  BAPIRET2_T
*"----------------------------------------------------------------------

  " --- Шаг 0. Дедуп по ИНН/КПП: если контрагент есть — режим изменения. ----------
  DATA lv_kunnr TYPE kunnr.
  SELECT SINGLE kunnr INTO lv_kunnr
    FROM kna1
    WHERE stcd1 = is_customer-stcd1
      AND stcd2 = is_customer-stcd2.
  " lv_kunnr пуст → создание; заполнен → обновление существующего.

  " --- Шаг 1. Заполнить структуру CVI_EI_EXTERN (ракурсы за один вызов). ----------
  DATA ls_main TYPE cvis_ei_extern.
  " ls_main-partner-header-object_task = COND #( WHEN lv_kunnr IS INITIAL THEN 'I' ELSE 'U' ).
  " ls_main-partner-central_data-common-data-bp_control-... = ...   " общие данные (имя/адрес)
  " ls_main-partner-central_data-taxnumber-...               = ...   " ИНН/КПП (STCD1/STCD2)
  " ls_main-customer-company_data-company[]                  = ...   " балансовая ед. (Bukrs)
  " ls_main-customer-sales_data-sales[]                      = ...   " сбыт. орг. (Vkorg)
  " Группа счёта Ktokd → ls_main-customer-header-object_instance / account_group.
  " TODO(OQ-3/OQ-5): точный маппинг полей и ракурсов уточнить у БОВА.

  " --- Шаг 2. Валидация + сохранение через CMD_EI_API. ---------------------------
  DATA lt_message TYPE cvis_message.
  DATA lt_extern  TYPE cmds_ei_extern_t.
  " APPEND ls_main TO lt_extern.
  " CALL METHOD cmd_ei_api=>maintain
  "   EXPORTING  it_customers = lt_extern
  "   IMPORTING  et_return    = lt_message-messages.
  " cmd_ei_api=>maintain валидирует и пишет во все ракурсы за один вызов.

  " --- Шаг 3. Коммит при отсутствии ошибок. --------------------------------------
  " IF NOT line_exists( lt_message-messages[ type = 'E' ] ).
  "   CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
  "   ev_kunnr = <созданный/изменённый KUNNR>.
  " ELSE.
  "   CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  " ENDIF.
  " et_return = смаппить lt_message-messages → BAPIRET2_T (для возврата в OData).

ENDFUNCTION.
