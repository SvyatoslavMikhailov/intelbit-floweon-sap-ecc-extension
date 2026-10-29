*&---------------------------------------------------------------------*
*& Z_CUSTOMER_CREATE_VIA_ODATA
*& Создание клиента из плоских OData-полей через CMD_EI_API (только создание — D17,
*& 4-17-30: изменение клиента из Bitrix24 не выполняется).
*&
*& Скелет-референс (SAP ECC 6.0 EHP8). ==Реальную бизнес-логику не дописывать до
*& уточнения полей у БОВА (OQ-3/OQ-5 ADR-001).== Ниже — сигнатура и ключевые шаги.
*&---------------------------------------------------------------------*
FUNCTION z_customer_create_via_odata.
*"----------------------------------------------------------------------
*"  IMPORTING
*"     VALUE(IS_CUSTOMER) TYPE  ZCUSTOMER_FLAT  " Name/Land1/Ort01/Pstlz/Stras/
*"                                               " Stcd1(ИНН)/Stcd2(КПП)/Bukrs/Vkorg/Ktokd
*"     VALUE(IT_BANKS)    TYPE  ZCUSTOMER_BANK_T OPTIONAL
*"                                               " Banks/Bankl(БИК)/Bankn(20 цифр)/Korrs/
*"                                               " Banka/Xmain
*"  EXPORTING
*"     VALUE(EV_KUNNR)    TYPE  KUNNR
*"     VALUE(ET_RETURN)   TYPE  BAPIRET2_T
*"----------------------------------------------------------------------

  " --- Шаг 0. Дубль по ИНН/КПП → ошибка (только создание, D17). ------------------
  " Пресет ищет клиента по ИНН+КПП до записи и при находке только связывает; сюда
  " дубль попадает лишь в гонке — отказ безопасен (повтор найдёт и свяжет).
  DATA lv_kunnr TYPE kunnr.
  SELECT SINGLE kunnr INTO lv_kunnr
    FROM kna1
    WHERE stcd1 = is_customer-stcd1
      AND stcd2 = is_customer-stcd2.
  IF lv_kunnr IS NOT INITIAL.
    APPEND VALUE #( type = 'E' id = 'ZFLW' number = '001' message_v1 = lv_kunnr
                    message = |CUSTOMER_DUPLICATE: { lv_kunnr }| ) TO et_return.
    RETURN.
  ENDIF.

  " --- Шаг 0а. Банковские реквизиты: формат (дублирует проверку коннектора). --------
  LOOP AT it_banks INTO DATA(ls_bank).
    " Длина — strlen (без хвостовых пробелов CHAR), цифры — по ровно этой длине.
    IF strlen( ls_bank-bankl ) <> 9 OR ls_bank-bankl(9) CN '0123456789'
       OR strlen( ls_bank-bankn ) <> 20 OR ls_bank-bankn(20) CN '0123456789'.
      APPEND VALUE #( type = 'E' id = 'ZFLW' number = '002' message_v1 = ls_bank-bankl
                      message = |BANK_DETAILS_INVALID: { ls_bank-bankl }| ) TO et_return.
      RETURN.
    ENDIF.
  ENDLOOP.

  " --- Шаг 1. Заполнить структуру CVI_EI_EXTERN (ракурсы за один вызов). ----------
  DATA ls_main TYPE cvis_ei_extern.
  " ls_main-partner-header-object_task = 'I'.                       " только создание
  " ls_main-partner-central_data-common-data-bp_control-... = ...   " общие данные (имя/адрес)
  " ls_main-partner-central_data-taxnumber-...               = ...   " ИНН/КПП (STCD1/STCD2)
  " ls_main-customer-company_data-company[]                  = ...   " балансовая ед. (Bukrs)
  " ls_main-customer-sales_data-sales[]                      = ...   " сбыт. орг. (Vkorg)
  " Группа счёта Ktokd → ls_main-customer-header-object_instance / account_group.
  " TODO(OQ-3/OQ-5): точный маппинг полей и ракурсов уточнить у БОВА.
  "
  " Банковские реквизиты → ls_main-customer-central_data-bankdetail-bankdetails[] (KNBK):
  "   banks = 'RU', bank_key (BANKL) = БИК.
  " TODO(БОВА/SAP-команда, решение не принято): счёт 20 цифр, KNBK-BANKN — 18 символов.
  "   (а) BANKN = bankn(18), BKONT = bankn+18(2)  — локализация RU;
  "   (б) BANKN = bankn(18), BKREF = bankn         — полный счёт в ссылке;
  "   (в) иной принятый в БОВА способ.
  " TODO(БОВА/SAP-команда): нет BNKA для (RU, БИК):
  "   (а) отказ BANK_NOT_FOUND → задача логисту в Bitrix24;
  "   (б) BAPI_BANK_CREATE (Banka, Korrs из запроса) перед CMD_EI_API;
  "   (в) банк заводит SAP-команда вручную.
  " Xmain = 'X' — основной счёт (первый в запросе).

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
