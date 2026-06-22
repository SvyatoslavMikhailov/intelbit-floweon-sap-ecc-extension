*&---------------------------------------------------------------------*
*& ZCL_ZCUST_DPC_EXT — Data Provider Extension сервиса ZCUST_SRV
*& Скелет-референс. Реальная логика — ABAP-командой после уточнения полей (OQ-3/OQ-5).
*&---------------------------------------------------------------------*
CLASS zcl_zcust_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zcust_dpc
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS customerset_create_entity REDEFINITION.
ENDCLASS.

CLASS zcl_zcust_dpc_ext IMPLEMENTATION.

  METHOD customerset_create_entity.
    " 1. Считать плоскую сущность из тела запроса.
    DATA ls_customer TYPE zcl_zcust_mpc=>ts_customer.
    io_data_provider->read_entry_data( IMPORTING es_data = ls_customer ).

    " 2. Делегировать в Z-ФМ (вся глубина CMD_EI_API скрыта там).
    DATA lv_kunnr   TYPE kunnr.
    DATA lt_return  TYPE bapiret2_t.
    CALL FUNCTION 'Z_CUSTOMER_CREATE_VIA_ODATA'
      EXPORTING
        is_customer = ls_customer        " плоские поля Name/Stcd1/Stcd2/Bukrs/Vkorg/Ktokd/...
      IMPORTING
        ev_kunnr    = lv_kunnr
        et_return   = lt_return.

    " 3. Ошибки → OData-исключение (бизнес-конверт {"error":{"code","message"}}).
    LOOP AT lt_return TRANSPORTING NO FIELDS WHERE type CA 'EA'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = me->mo_context->get_message_container( ).
    ENDLOOP.

    " 4. Успех → вернуть Kunnr в созданной сущности.
    ls_customer-kunnr = lv_kunnr.
    copy_data_to_ref( EXPORTING is_data = ls_customer CHANGING cr_data = er_entity ).
  ENDMETHOD.

ENDCLASS.
