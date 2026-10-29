*&---------------------------------------------------------------------*
*& ZCL_ZCUST_DPC_EXT — Data Provider Extension сервиса ZCUST_SRV
*& Скелет-референс. Реальная логика — ABAP-командой после уточнения полей (OQ-3/OQ-5).
*&---------------------------------------------------------------------*
CLASS zcl_zcust_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zcust_dpc
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS /iwbep/if_mgw_appl_srv_runtime~create_deep_entity REDEFINITION.
  PROTECTED SECTION.
    METHODS customerset_create_entity REDEFINITION.
  PRIVATE SECTION.
    " Клиент с банковскими реквизитами (deep insert ToBankDetails, 4-17-30).
    TYPES: BEGIN OF ty_deep_customer.
             INCLUDE TYPE zcl_zcust_mpc=>ts_customer.
    TYPES:   tobankdetails TYPE STANDARD TABLE OF zcl_zcust_mpc=>ts_customerbank
                           WITH DEFAULT KEY,
           END OF ty_deep_customer.
    METHODS create_customer
      IMPORTING is_customer     TYPE zcl_zcust_mpc=>ts_customer
                it_banks        TYPE zcustomer_bank_t
      RETURNING VALUE(rv_kunnr) TYPE kunnr
      RAISING   /iwbep/cx_mgw_busi_exception.
ENDCLASS.

CLASS zcl_zcust_dpc_ext IMPLEMENTATION.

  METHOD customerset_create_entity.
    " Клиент без банковских реквизитов: плоская сущность из тела запроса.
    DATA ls_customer TYPE zcl_zcust_mpc=>ts_customer.
    io_data_provider->read_entry_data( IMPORTING es_data = ls_customer ).
    ls_customer-kunnr = create_customer( is_customer = ls_customer it_banks = VALUE #( ) ).
    copy_data_to_ref( EXPORTING is_data = ls_customer CHANGING cr_data = er_entity ).
  ENDMETHOD.

  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
    " Клиент + ToBankDetails одним запросом (коннектор: bank_accounts → ToBankDetails).
    DATA ls_deep TYPE ty_deep_customer.
    io_data_provider->read_entry_data( IMPORTING es_data = ls_deep ).
    DATA(lt_banks) = CORRESPONDING zcustomer_bank_t( ls_deep-tobankdetails ).
    ls_deep-kunnr = create_customer(
      is_customer = CORRESPONDING #( ls_deep )
      it_banks    = lt_banks ).
    LOOP AT ls_deep-tobankdetails ASSIGNING FIELD-SYMBOL(<ls_bank>).
      <ls_bank>-kunnr = ls_deep-kunnr.
    ENDLOOP.
    copy_data_to_ref( EXPORTING is_data = ls_deep CHANGING cr_data = er_deep_entity ).
  ENDMETHOD.

  METHOD create_customer.
    " Делегировать в Z-ФМ (вся глубина CMD_EI_API скрыта там).
    DATA lt_return TYPE bapiret2_t.
    CALL FUNCTION 'Z_CUSTOMER_CREATE_VIA_ODATA'
      EXPORTING
        is_customer = is_customer        " плоские поля Name/Stcd1/Stcd2/Bukrs/Vkorg/Ktokd/...
        it_banks    = it_banks           " Banks/Bankl/Bankn(20)/Korrs/Banka/Xmain
      IMPORTING
        ev_kunnr    = rv_kunnr
        et_return   = lt_return.

    " Ошибки → OData-исключение (бизнес-конверт {"error":{"code","message"}}).
    IF line_exists( lt_return[ type = 'E' ] ) OR line_exists( lt_return[ type = 'A' ] ).
      DATA(lo_messages) = me->mo_context->get_message_container( ).
      lo_messages->add_messages_from_bapi( it_bapi_messages = lt_return ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_messages.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
