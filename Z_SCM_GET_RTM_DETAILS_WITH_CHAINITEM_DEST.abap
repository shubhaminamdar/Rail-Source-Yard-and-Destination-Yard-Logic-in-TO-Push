FUNCTION Z_SCM_GET_RTM_DETAILS
  IMPORTING
    VALUE(IT_SHIPMENT) TYPE ZSCM_TKNUM_T
  EXPORTING
    VALUE(ET_RTM_DETAILS) TYPE ZSCM_RTM_DETAILS_T
    VALUE(ET_RETURN) TYPE BAPIRET2_T.



*&---------------------------------------------------------------------*
* FM                  : Z_SCM_GET_RTM_DETAILS
* Create Date         : 04/12/2025
* Technical Author    : Omkar More
* Functional Author   : Shubham Inamdar
* CD / TR             : 8086354 / RD2K9A5EQE
* Description         : FM to get rate to market data for shipment
*&---------------------------------------------------------------------*
  TYPES : BEGIN OF lty_vttk,
           tknum  TYPE  tknum,
           shtyp  TYPE  shtyp,
           tplst  TYPE  tplst,
           route  TYPE  routr,
           signi  TYPE  signi,
           tdlnr  TYPE  tdlnr,
          END OF lty_vttk,

          BEGIN OF lty_tvrab,
            route TYPE route,
            abnum TYPE rabnum,
            knanf TYPE knota,
            knend TYPE knotz,
          END OF lty_tvrab,

          BEGIN OF lty_yttstm0001,
            truck_no       TYPE ytruck_no,
            qwik_vehi_type TYPE zvehtype,
          END OF lty_yttstm0001,

          BEGIN OF lty_ttds,
            tplst  TYPE tplst,
            bukrs  TYPE bukrs,
          END OF lty_ttds,

       BEGIN OF lty_vttp,
       tknum   TYPE tknum,
       tpnum   TYPE tpnum,
       vbeln   TYPE vbeln_vl,
       END OF lty_vttp,

      BEGIN OF lty_lips,
        vbeln TYPE vbeln_vl,
        posnr TYPE posnr,
        spart TYPE spart,
     END OF lty_lips,

         BEGIN OF lty_zlog_exec_var,
         name        TYPE rvari_vnam,
         numb	       TYPE tvarv_numb,
         shtyp       TYPE shtyp,
         remarks     TYPE textr,
         transplpt   TYPE tplst,
         spart       TYPE spart,
         rfcdest     TYPE rfcdest,
         ewb_uom_d   TYPE txt30,
         errormsg    TYPE natxt,
         bukrs       TYPE bukrs,
         vsart       TYPE vsart,
       END OF lty_zlog_exec_var,

       BEGIN OF lty_zscm_chainship,
         shnumber TYPE tknum,
         chainid  TYPE char40,
         odpairid TYPE char40,
         trmode   TYPE vsart,
       END OF lty_zscm_chainship,

* BEGIN: Cursor Generated Code - Added type for ZSCM_CHAINITEM
       BEGIN OF lty_zscm_chainitem,
         chainid    TYPE char40,
         odpairid   TYPE char40,
         legid      TYPE char40,
         destination TYPE char40,
       END OF lty_zscm_chainitem,
* END: Cursor Generated Code

       BEGIN OF lty_rail_location_config,
         bukrs TYPE bukrs,
         vsart TYPE vsart,
       END OF lty_rail_location_config,

       BEGIN OF lty_vttk_rail,
         tknum TYPE tknum,
         route TYPE routr,
       END OF lty_vttk_rail,

       BEGIN OF lty_rail_location_map,
         tknum      TYPE tknum,
         bukrs      TYPE bukrs,
         shtyp      TYPE shtyp,
         chainid    TYPE char40,
         odpairid   TYPE char40,
         trmode     TYPE vsart,
         rail_route TYPE routr,
         rail_source TYPE knota,
         rail_dest  TYPE knotz,
       END OF lty_rail_location_map.

* BEGIN: Cursor Generated Code - Added type for chainitem destination mapping
       BEGIN OF lty_chainitem_dest_map,
         chainid    TYPE char40,
         odpairid   TYPE char40,
         destination TYPE char40,
       END OF lty_chainitem_dest_map.
* END: Cursor Generated Code

  DATA: lt_shipment              TYPE zscm_tknum_t,
        lt_vttk                   TYPE TABLE OF lty_vttk,
        lw_vttk                   TYPE lty_vttk,
        lt_vttk_temp              TYPE TABLE OF lty_vttk,
        lw_vttk_temp              TYPE lty_vttk,
        ltr_truck_no              TYPE RANGE OF ytruck_no,
        lwr_truck_no              LIKE LINE OF ltr_truck_no,
        lt_tvrab                  TYPE TABLE OF lty_tvrab,
        lw_tvrab                  TYPE lty_tvrab,
        lt_ttds                   TYPE TABLE OF lty_ttds,
        lw_ttds                   TYPE lty_ttds,
        lt_lips                   TYPE TABLE OF lty_lips,
        lw_lips                   TYPE lty_lips,
        lt_vttp                   TYPE TABLE OF lty_vttp,
        lt_vttp_temp              TYPE TABLE OF lty_vttp,
        lw_vttp                   TYPE lty_vttp,
        lt_yttstm0001             TYPE TABLE OF lty_yttstm0001,
        lw_yttstm0001             TYPE lty_yttstm0001,
        lt_zlog_exec_var          TYPE TABLE OF lty_zlog_exec_var,
        lw_zlog_exec_var          TYPE lty_zlog_exec_var,
        lw_zlog_exec_var_1        TYPE lty_zlog_exec_var,
        lt_rail_location_config   TYPE TABLE OF lty_rail_location_config,
        lw_rail_location_config   TYPE lty_rail_location_config,
        lt_zscm_chainship         TYPE TABLE OF lty_zscm_chainship,
        lw_zscm_chainship         TYPE lty_zscm_chainship,
        lt_zscm_chainship_temp    TYPE TABLE OF lty_zscm_chainship,
        lw_zscm_chainship_temp    TYPE lty_zscm_chainship,
        lt_vttk_rail              TYPE TABLE OF lty_vttk_rail,
        lw_vttk_rail              TYPE lty_vttk_rail,
        lt_vttk_rail_temp         TYPE TABLE OF lty_vttk_rail,
        lw_vttk_rail_temp         TYPE lty_vttk_rail,
        lt_rail_location_map      TYPE TABLE OF lty_rail_location_map,
        lw_rail_location_map      TYPE lty_rail_location_map,
        lt_all_chainship          TYPE TABLE OF lty_zscm_chainship,
        lw_all_chainship          TYPE lty_zscm_chainship,
        lt_all_chainship_temp     TYPE TABLE OF lty_zscm_chainship,
        lw_all_chainship_temp     TYPE lty_zscm_chainship,
        lt_rail_routes            TYPE TABLE OF routr,
        lw_rail_routes            TYPE routr,
        lw_rtm_details            TYPE zscm_rtm_details_s,
        lv_tabix                  TYPE sy-tabix,
        lw_chargecodes            TYPE char10,
        lw_return                 TYPE bapiret2,
        lv_chainid                TYPE char40,
        lv_odpairid               TYPE char40,
        lv_rail_route             TYPE routr,
        lv_rail_source            TYPE knota,
        lv_rail_dest              TYPE knotz.

* BEGIN: Cursor Generated Code - Added variables for ZSCM_CHAINITEM processing
  DATA: lt_zscm_chainitem         TYPE TABLE OF lty_zscm_chainitem,
        lw_zscm_chainitem         TYPE lty_zscm_chainitem,
        lt_zscm_chainitem_temp    TYPE TABLE OF lty_zscm_chainitem,
        lw_zscm_chainitem_temp    TYPE lty_zscm_chainitem,
        lt_chainitem_dest_map      TYPE TABLE OF lty_chainitem_dest_map,
        lw_chainitem_dest_map     TYPE lty_chainitem_dest_map,
        lv_chainitem_destination  TYPE char40.
* END: Cursor Generated Code

  CONSTANTS: lc_zscm_get_mm_business    TYPE rvari_vnam VALUE 'ZSCM_GET_MM_BUSINESS',
             lc_zscm_get_mm_subbusiness TYPE rvari_vnam VALUE 'ZSCM_GET_MM_SUBBUSINESS',
             lc_zscm_get_ril_prodsub    TYPE rvari_vnam VALUE 'ZSCM_GET_RIL_PRODSUB',
             lc_scme_pf_tms_servcat     TYPE rvari_vnam VALUE 'SCME_PF_TMS_SERVCAT',
             lc_zscm_get_rtm_chargecode TYPE rvari_vnam VALUE 'ZSCM_GET_RTM_CHARGECODE',
             lc_zscm_get_rail_location  TYPE rvari_vnam VALUE 'ZSCM_GET_RAIL_LOCATION'.

  REFRESH:lt_shipment,lt_vttk,lt_tvrab.
  lt_shipment = it_shipment.
  SORT lt_shipment BY tknum.
  DELETE ADJACENT DUPLICATES FROM lt_shipment COMPARING tknum.
  IF lt_shipment IS NOT INITIAL.

    SELECT tknum
           shtyp
           tplst
           route
           signi
           tdlnr
    FROM vttk CLIENT SPECIFIED
    INTO TABLE lt_vttk
    FOR ALL ENTRIES IN lt_shipment
    WHERE mandt = sy-mandt
    AND   tknum = lt_shipment-tknum.
    IF sy-subrc = 0.

      REFRESH:lt_vttk_temp,lt_vttp.
      lt_vttk_temp = lt_vttk.
      SORT lt_vttk_temp BY tknum.
      DELETE ADJACENT DUPLICATES FROM lt_vttk_temp COMPARING tknum.
      IF lt_vttk_temp IS NOT INITIAL.

        SELECT tknum
               tpnum
               vbeln
        FROM vttp CLIENT SPECIFIED
        INTO TABLE lt_vttp
        FOR ALL ENTRIES IN lt_vttk_temp
        WHERE mandt = sy-mandt
        AND   tknum = lt_vttk_temp-tknum.
        IF sy-subrc = 0.

          REFRESH lt_vttp_temp.
          lt_vttp_temp = lt_vttp.
          DELETE lt_vttp_temp WHERE vbeln IS INITIAL.
          SORT   lt_vttp_temp BY vbeln.
          DELETE ADJACENT DUPLICATES FROM lt_vttp_temp COMPARING vbeln.
          IF lt_vttp_temp IS NOT INITIAL.

            SELECT  vbeln
                    posnr
                    spart
              FROM lips CLIENT SPECIFIED
              INTO TABLE lt_lips
              FOR ALL ENTRIES IN lt_vttp_temp
              WHERE mandt = sy-mandt
              AND   vbeln = lt_vttp_temp-vbeln.
            IF sy-subrc = 0.
              SORT lt_lips BY vbeln.
            ELSE.
              CLEAR lw_return.
              lw_return-type    = 'E'.
              lw_return-message = text-001.
              APPEND lw_return TO et_return.
              CLEAR  lw_return.
            ENDIF.
          ENDIF.
        ELSE.
          CLEAR lw_return.
          lw_return-type    = 'E'.
          lw_return-message = text-001.
          APPEND lw_return TO et_return.
          CLEAR  lw_return.
        ENDIF.
      ENDIF.

      REFRESH lt_vttk_temp.
      lt_vttk_temp = lt_vttk.
      DELETE lt_vttk_temp WHERE route IS INITIAL.
      SORT   lt_vttk_temp BY route.
      DELETE ADJACENT DUPLICATES FROM lt_vttk_temp COMPARING route.
      IF lt_vttk_temp IS NOT INITIAL.

        SELECT route
               abnum
               knanf
               knend
          FROM tvrab CLIENT SPECIFIED
          INTO TABLE lt_tvrab
          FOR ALL ENTRIES IN lt_vttk_temp
          WHERE mandt = sy-mandt
          AND   route = lt_vttk_temp-route.
        IF sy-subrc = 0.
          SORT lt_tvrab BY route.
        ELSE.
          CLEAR lw_return.
          lw_return-type    = 'E'.
          lw_return-message = text-001.
          APPEND lw_return TO et_return.
          CLEAR  lw_return.
        ENDIF.
      ENDIF.

      REFRESH lt_vttk_temp.
      lt_vttk_temp = lt_vttk.
      DELETE lt_vttk_temp WHERE signi IS INITIAL.
      SORT   lt_vttk_temp BY signi.
      DELETE ADJACENT DUPLICATES FROM lt_vttk_temp COMPARING signi.
      IF lt_vttk_temp IS NOT INITIAL.

        lwr_truck_no-sign   = 'I'.
        lwr_truck_no-option = 'EQ'.
        LOOP AT lt_vttk_temp INTO lw_vttk_temp.
          lwr_truck_no-low = lw_vttk_temp-signi+0(15).
          APPEND lwr_truck_no TO ltr_truck_no.
          CLEAR:lwr_truck_no-low,lw_vttk_temp.
        ENDLOOP.

        IF ltr_truck_no[] IS NOT INITIAL.
          SELECT  truck_no
                  qwik_vehi_type
          FROM yttstm0001 CLIENT SPECIFIED
          INTO TABLE lt_yttstm0001
          WHERE mandt    = sy-mandt
          AND   truck_no IN ltr_truck_no[].
          IF sy-subrc = 0.
            SORT lt_yttstm0001 BY truck_no.
          ELSE.
            CLEAR lw_return.
            lw_return-type    = 'E'.
            lw_return-message = text-001.
            APPEND lw_return TO et_return.
            CLEAR  lw_return.
          ENDIF.
        ENDIF.
      ENDIF.

      REFRESH lt_vttk_temp.
      lt_vttk_temp = lt_vttk.
      DELETE lt_vttk_temp WHERE tplst IS INITIAL.
      SORT   lt_vttk_temp BY tplst.
      DELETE ADJACENT DUPLICATES FROM lt_vttk_temp COMPARING tplst.
      IF lt_vttk_temp IS NOT INITIAL.

        SELECT tplst
               bukrs
          FROM ttds CLIENT SPECIFIED
          INTO TABLE lt_ttds
          FOR ALL ENTRIES IN lt_vttk_temp
          WHERE mandt = sy-mandt
          AND   tplst = lt_vttk_temp-tplst.
        IF sy-subrc = 0.
          SORT lt_ttds BY tplst.
        ELSE.
          CLEAR lw_return.
          lw_return-type    = 'E'.
          lw_return-message = text-001.
          APPEND lw_return TO et_return.
          CLEAR  lw_return.
        ENDIF.
      ENDIF.
    ELSE.
      CLEAR lw_return.
      lw_return-type    = 'E'.
      lw_return-message = text-001.
      APPEND lw_return TO et_return.
      CLEAR  lw_return.
    ENDIF.

    SELECT  name
            numb
            shtyp
            remarks
            transplpt
            spart
            rfcdest
            ewb_uom_d
            errormsg
            bukrs
            vsart
       FROM zlog_exec_var CLIENT SPECIFIED
       INTO TABLE lt_zlog_exec_var
       WHERE mandt = sy-mandt
       AND   name  IN (lc_zscm_get_mm_business,
                       lc_zscm_get_mm_subbusiness,
                       lc_zscm_get_ril_prodsub,
                       lc_scme_pf_tms_servcat,
                       lc_zscm_get_rtm_chargecode,
                       lc_zscm_get_rail_location)
       AND   active = abap_true.
       IF sy-subrc NE 0.
         REFRESH lt_zlog_exec_var.
       ENDIF.

    " BEGIN: Cursor Generated Code
    " Read rail location configuration from ZLOG_EXEC_VAR
    REFRESH lt_rail_location_config.
    LOOP AT lt_zlog_exec_var INTO lw_zlog_exec_var
      WHERE name = lc_zscm_get_rail_location.
      IF lw_zlog_exec_var-bukrs IS NOT INITIAL
      AND lw_zlog_exec_var-vsart IS NOT INITIAL.
        lw_rail_location_config-bukrs = lw_zlog_exec_var-bukrs.
        lw_rail_location_config-vsart = lw_zlog_exec_var-vsart.
        APPEND lw_rail_location_config TO lt_rail_location_config.
        CLEAR lw_rail_location_config.
      ENDIF.
      CLEAR lw_zlog_exec_var.
    ENDLOOP.
    SORT lt_rail_location_config BY bukrs.
    DELETE ADJACENT DUPLICATES FROM lt_rail_location_config
      COMPARING bukrs.

    " BEGIN: Cursor Generated Code
    " Fetch all chain shipment and rail location data upfront to avoid SELECT in loops
    REFRESH: lt_rail_location_map, lt_all_chainship, lt_rail_routes.
    
    " Step 1: Identify shipments that need rail location processing
    " Collect shipment numbers that match rail location configuration
    IF lt_rail_location_config IS NOT INITIAL AND lt_vttk IS NOT INITIAL.
      LOOP AT lt_vttk INTO lw_vttk.
        CLEAR lw_ttds.
        READ TABLE lt_ttds INTO lw_ttds WITH KEY tplst = lw_vttk-tplst BINARY SEARCH.
        IF sy-subrc = 0.
          CLEAR lw_rail_location_config.
          READ TABLE lt_rail_location_config INTO lw_rail_location_config
            WITH KEY bukrs = lw_ttds-bukrs
            BINARY SEARCH.
          IF sy-subrc = 0.
            " This shipment needs rail location processing
            CLEAR lw_rail_location_map.
            lw_rail_location_map-tknum = lw_vttk-tknum.
            lw_rail_location_map-bukrs = lw_ttds-bukrs.
            lw_rail_location_map-shtyp = lw_vttk-shtyp.
            lw_rail_location_map-trmode = lw_rail_location_config-vsart.
            APPEND lw_rail_location_map TO lt_rail_location_map.
          ENDIF.
        ENDIF.
        CLEAR lw_vttk.
      ENDLOOP.
    ENDIF.

    " Step 2: Fetch all chain shipment data for identified shipments upfront
    IF lt_rail_location_map IS NOT INITIAL.
      REFRESH lt_all_chainship_temp.
      LOOP AT lt_rail_location_map INTO lw_rail_location_map.
        CLEAR lw_all_chainship_temp.
        lw_all_chainship_temp-shnumber = lw_rail_location_map-tknum.
        APPEND lw_all_chainship_temp TO lt_all_chainship_temp.
        CLEAR lw_rail_location_map.
      ENDLOOP.
      
      IF lt_all_chainship_temp IS NOT INITIAL.
        SORT lt_all_chainship_temp BY shnumber.
        DELETE ADJACENT DUPLICATES FROM lt_all_chainship_temp COMPARING shnumber.
        
        SELECT shnumber
               chainid
               odpairid
               trmode
          FROM zscm_chainship CLIENT SPECIFIED
          INTO TABLE lt_all_chainship
          FOR ALL ENTRIES IN lt_all_chainship_temp
          WHERE mandt = sy-mandt
          AND   shnumber = lt_all_chainship_temp-shnumber.
        IF sy-subrc = 0.
          SORT lt_all_chainship BY shnumber.
        ENDIF.
      ENDIF.
      FREE lt_all_chainship_temp.

      " Step 3: Collect unique chainid/odpairid/trmode combinations and fetch all related shipments
      REFRESH lt_all_chainship_temp.
      LOOP AT lt_rail_location_map INTO lw_rail_location_map.
        CLEAR lw_all_chainship.
        READ TABLE lt_all_chainship INTO lw_all_chainship
          WITH KEY shnumber = lw_rail_location_map-tknum
          BINARY SEARCH.
        IF sy-subrc = 0.
          lw_rail_location_map-chainid = lw_all_chainship-chainid.
          lw_rail_location_map-odpairid = lw_all_chainship-odpairid.
          MODIFY lt_rail_location_map FROM lw_rail_location_map.
          
          " Collect chainid/odpairid/trmode combinations
          CLEAR lw_all_chainship_temp.
          lw_all_chainship_temp-chainid = lw_all_chainship-chainid.
          lw_all_chainship_temp-odpairid = lw_all_chainship-odpairid.
          lw_all_chainship_temp-trmode = lw_rail_location_map-trmode.
          APPEND lw_all_chainship_temp TO lt_all_chainship_temp.
        ENDIF.
        CLEAR lw_rail_location_map.
      ENDLOOP.
      
      " Deduplicate chainid/odpairid/trmode combinations
      IF lt_all_chainship_temp IS NOT INITIAL.
        SORT lt_all_chainship_temp BY chainid odpairid trmode.
        DELETE ADJACENT DUPLICATES FROM lt_all_chainship_temp
          COMPARING chainid odpairid trmode.
        
        " Fetch all related chain shipments matching these combinations
        SELECT shnumber
               chainid
               odpairid
               trmode
          FROM zscm_chainship CLIENT SPECIFIED
          INTO TABLE lt_all_chainship
          FOR ALL ENTRIES IN lt_all_chainship_temp
          WHERE mandt = sy-mandt
          AND   chainid = lt_all_chainship_temp-chainid
          AND   odpairid = lt_all_chainship_temp-odpairid
          AND   trmode = lt_all_chainship_temp-trmode.
        IF sy-subrc = 0.
          SORT lt_all_chainship BY shnumber.
        ENDIF.
      ENDIF.
      FREE lt_all_chainship_temp.

      " Step 4: Fetch routes from related shipments and build mapping
      IF lt_all_chainship IS NOT INITIAL.
        REFRESH lt_all_chainship_temp.
        LOOP AT lt_all_chainship INTO lw_all_chainship.
          CLEAR lw_all_chainship_temp.
          lw_all_chainship_temp-shnumber = lw_all_chainship-shnumber.
          APPEND lw_all_chainship_temp TO lt_all_chainship_temp.
          CLEAR lw_all_chainship.
        ENDLOOP.
        
        IF lt_all_chainship_temp IS NOT INITIAL.
          SORT lt_all_chainship_temp BY shnumber.
          DELETE ADJACENT DUPLICATES FROM lt_all_chainship_temp COMPARING shnumber.
          
          " Fetch routes from all related shipments
          REFRESH lt_vttk_rail_temp.
          LOOP AT lt_all_chainship_temp INTO lw_all_chainship_temp.
            CLEAR lw_vttk_rail_temp.
            lw_vttk_rail_temp-tknum = lw_all_chainship_temp-shnumber.
            APPEND lw_vttk_rail_temp TO lt_vttk_rail_temp.
            CLEAR lw_all_chainship_temp.
          ENDLOOP.
          
          IF lt_vttk_rail_temp IS NOT INITIAL.
            SORT lt_vttk_rail_temp BY tknum.
            DELETE ADJACENT DUPLICATES FROM lt_vttk_rail_temp COMPARING tknum.
            
            SELECT tknum
                   route
              FROM vttk CLIENT SPECIFIED
              INTO TABLE lt_vttk_rail
              FOR ALL ENTRIES IN lt_vttk_rail_temp
              WHERE mandt = sy-mandt
              AND   tknum = lt_vttk_rail_temp-tknum
              AND   route <> space.
            IF sy-subrc = 0.
              SORT lt_vttk_rail BY tknum.
              
              " Build rail location mapping
              LOOP AT lt_rail_location_map INTO lw_rail_location_map.
                IF lw_rail_location_map-chainid IS NOT INITIAL
                AND lw_rail_location_map-odpairid IS NOT INITIAL
                AND lw_rail_location_map-trmode IS NOT INITIAL.
                  " Find related shipment with matching chainid/odpairid/trmode
                  CLEAR lw_all_chainship.
                  LOOP AT lt_all_chainship INTO lw_all_chainship
                    WHERE chainid = lw_rail_location_map-chainid
                    AND   odpairid = lw_rail_location_map-odpairid
                    AND   trmode = lw_rail_location_map-trmode.
                    " Get route from related shipment
                    CLEAR lw_vttk_rail.
                    READ TABLE lt_vttk_rail INTO lw_vttk_rail
                      WITH KEY tknum = lw_all_chainship-shnumber
                      BINARY SEARCH.
                    IF sy-subrc = 0 AND lw_vttk_rail-route IS NOT INITIAL.
                      lw_rail_location_map-rail_route = lw_vttk_rail-route.
                      MODIFY lt_rail_location_map FROM lw_rail_location_map.
                      EXIT.
                    ENDIF.
                    CLEAR lw_all_chainship.
                  ENDLOOP.
                ENDIF.
                CLEAR lw_rail_location_map.
              ENDLOOP.
              
              " Collect routes for TVRAB lookup
              LOOP AT lt_vttk_rail INTO lw_vttk_rail.
                IF lw_vttk_rail-route IS NOT INITIAL.
                  CLEAR lw_rail_routes.
                  lw_rail_routes = lw_vttk_rail-route.
                  READ TABLE lt_rail_routes TRANSPORTING NO FIELDS
                    WITH KEY table_line = lw_rail_routes
                    BINARY SEARCH.
                  IF sy-subrc <> 0.
                    INSERT lw_rail_routes INTO lt_rail_routes
                      INDEX sy-tabix.
                  ENDIF.
                ENDIF.
                CLEAR lw_vttk_rail.
              ENDLOOP.
            ENDIF.
          ENDIF.
          FREE lt_all_chainship_temp.
        ENDIF.
      ENDIF.
    ENDIF.

    " Step 4: Fetch all TVRAB data for rail routes upfront
    IF lt_rail_routes IS NOT INITIAL.
      SORT lt_rail_routes.
      DELETE ADJACENT DUPLICATES FROM lt_rail_routes.
      
      REFRESH lt_vttk_rail_temp.
      LOOP AT lt_rail_routes INTO lw_rail_routes.
        CLEAR lw_vttk_rail_temp.
        lw_vttk_rail_temp-route = lw_rail_routes.
        APPEND lw_vttk_rail_temp TO lt_vttk_rail_temp.
        CLEAR lw_rail_routes.
      ENDLOOP.
      
      IF lt_vttk_rail_temp IS NOT INITIAL.
        SORT lt_vttk_rail_temp BY route.
        DELETE ADJACENT DUPLICATES FROM lt_vttk_rail_temp COMPARING route.
        
        " Check which routes are not already in lt_tvrab
        REFRESH lt_vttk_rail_temp.
        LOOP AT lt_rail_routes INTO lw_rail_routes.
          CLEAR lw_tvrab.
          READ TABLE lt_tvrab INTO lw_tvrab
            WITH KEY route = lw_rail_routes
            BINARY SEARCH.
          IF sy-subrc <> 0.
            " Route not in lt_tvrab, need to fetch it
            CLEAR lw_vttk_rail_temp.
            lw_vttk_rail_temp-route = lw_rail_routes.
            APPEND lw_vttk_rail_temp TO lt_vttk_rail_temp.
          ENDIF.
          CLEAR lw_rail_routes.
        ENDLOOP.
        
        " Fetch missing TVRAB data
        IF lt_vttk_rail_temp IS NOT INITIAL.
          SORT lt_vttk_rail_temp BY route.
          DELETE ADJACENT DUPLICATES FROM lt_vttk_rail_temp COMPARING route.
          
          SELECT route
                 abnum
                 knanf
                 knend
            FROM tvrab CLIENT SPECIFIED
            INTO TABLE lt_tvrab
            FOR ALL ENTRIES IN lt_vttk_rail_temp
            WHERE mandt = sy-mandt
            AND   route = lt_vttk_rail_temp-route.
          IF sy-subrc = 0.
            " Merge with existing lt_tvrab and sort
            SORT lt_tvrab BY route.
          ENDIF.
        ENDIF.
      ENDIF.
      FREE lt_vttk_rail_temp.
    ENDIF.

    " Step 5: Build final rail location map with source and destination
    LOOP AT lt_rail_location_map INTO lw_rail_location_map.
      IF lw_rail_location_map-rail_route IS NOT INITIAL.
        CLEAR lw_tvrab.
        READ TABLE lt_tvrab INTO lw_tvrab
          WITH KEY route = lw_rail_location_map-rail_route
          BINARY SEARCH.
        IF sy-subrc = 0.
          lw_rail_location_map-rail_source = lw_tvrab-knanf.
          lw_rail_location_map-rail_dest = lw_tvrab-knend.
          MODIFY lt_rail_location_map FROM lw_rail_location_map.
        ENDIF.
      ENDIF.
      CLEAR lw_rail_location_map.
    ENDLOOP.
    SORT lt_rail_location_map BY tknum.
    " END: Cursor Generated Code

* BEGIN: Cursor Generated Code
* Fetch ZSCM_CHAINITEM data based on chainid and odpairid from ZSCM_CHAINSHIP
* This is required to get destination from chainitem table sorted by legid descending
    REFRESH: lt_zscm_chainitem, lt_chainitem_dest_map.
    
    " Collect unique chainid/odpairid combinations from all chainship data
    IF lt_all_chainship IS NOT INITIAL.
      REFRESH lt_zscm_chainitem_temp.
      LOOP AT lt_all_chainship INTO lw_all_chainship.
        IF lw_all_chainship-chainid IS NOT INITIAL
        AND lw_all_chainship-odpairid IS NOT INITIAL.
          CLEAR lw_zscm_chainitem_temp.
          lw_zscm_chainitem_temp-chainid = lw_all_chainship-chainid.
          lw_zscm_chainitem_temp-odpairid = lw_all_chainship-odpairid.
          APPEND lw_zscm_chainitem_temp TO lt_zscm_chainitem_temp.
        ENDIF.
        CLEAR lw_all_chainship.
      ENDLOOP.
      
      " Deduplicate chainid/odpairid combinations
      IF lt_zscm_chainitem_temp IS NOT INITIAL.
        SORT lt_zscm_chainitem_temp BY chainid odpairid.
        DELETE ADJACENT DUPLICATES FROM lt_zscm_chainitem_temp
          COMPARING chainid odpairid.
        
        " Fetch chainitem data for all unique chainid/odpairid combinations
        SELECT chainid
               odpairid
               legid
               destination
          FROM zscm_chainitem CLIENT SPECIFIED
          INTO TABLE lt_zscm_chainitem
          FOR ALL ENTRIES IN lt_zscm_chainitem_temp
          WHERE mandt = sy-mandt
          AND   chainid = lt_zscm_chainitem_temp-chainid
          AND   odpairid = lt_zscm_chainitem_temp-odpairid.
        IF sy-subrc = 0.
          " Sort by chainid, odpairid, and legid descending as per requirement
          SORT lt_zscm_chainitem BY chainid odpairid legid DESCENDING.
          
          " Build destination mapping table - take first record (highest legid) for each chainid/odpairid
          LOOP AT lt_zscm_chainitem INTO lw_zscm_chainitem.
            CLEAR lw_chainitem_dest_map.
            READ TABLE lt_chainitem_dest_map INTO lw_chainitem_dest_map
              WITH KEY chainid = lw_zscm_chainitem-chainid
                      odpairid = lw_zscm_chainitem-odpairid
              BINARY SEARCH.
            IF sy-subrc <> 0.
              " First occurrence for this chainid/odpairid (highest legid due to descending sort)
              lw_chainitem_dest_map-chainid = lw_zscm_chainitem-chainid.
              lw_chainitem_dest_map-odpairid = lw_zscm_chainitem-odpairid.
              lw_chainitem_dest_map-destination = lw_zscm_chainitem-destination.
              APPEND lw_chainitem_dest_map TO lt_chainitem_dest_map.
              SORT lt_chainitem_dest_map BY chainid odpairid.
            ENDIF.
            CLEAR lw_zscm_chainitem.
          ENDLOOP.
        ENDIF.
      ENDIF.
      FREE lt_zscm_chainitem_temp.
    ENDIF.
* END: Cursor Generated Code

    SORT lt_vttp       BY tknum.
    LOOP AT lt_vttk INTO lw_vttk.

      READ TABLE lt_vttp TRANSPORTING NO FIELDS WITH KEY tknum = lw_vttk-tknum BINARY SEARCH.
      IF sy-subrc = 0.
        lv_tabix = sy-tabix.

        LOOP AT lt_vttp INTO lw_vttp FROM lv_tabix.
          IF lw_vttp-tknum NE lw_vttk-tknum.
            EXIT.
          ELSE.
            lw_rtm_details-shipmentno = lw_vttk-tknum.
            lw_rtm_details-vendor     = lw_vttk-tdlnr.

            CLEAR lw_tvrab.
            READ TABLE lt_tvrab INTO lw_tvrab WITH KEY route = lw_vttk-route BINARY SEARCH.
            IF sy-subrc = 0.
              lw_rtm_details-source      = lw_tvrab-knanf.
* BEGIN: Cursor Generated Code - Modified destination assignment logic
* Check if destination should come from ZSCM_CHAINITEM instead of TVRAB
              CLEAR: lv_chainitem_destination, lw_all_chainship.
              " Get chainid and odpairid for current shipment
              READ TABLE lt_all_chainship INTO lw_all_chainship
                WITH KEY shnumber = lw_vttk-tknum
                BINARY SEARCH.
              IF sy-subrc = 0
              AND lw_all_chainship-chainid IS NOT INITIAL
              AND lw_all_chainship-odpairid IS NOT INITIAL.
                " Check if destination exists in chainitem mapping
                CLEAR lw_chainitem_dest_map.
                READ TABLE lt_chainitem_dest_map INTO lw_chainitem_dest_map
                  WITH KEY chainid = lw_all_chainship-chainid
                          odpairid = lw_all_chainship-odpairid
                  BINARY SEARCH.
                IF sy-subrc = 0
                AND lw_chainitem_dest_map-destination IS NOT INITIAL.
                  " Use destination from chainitem (sorted by legid descending)
                  lw_rtm_details-destination = lw_chainitem_dest_map-destination.
                ELSE.
                  " Fallback to TVRAB destination if chainitem not found
                  lw_rtm_details-destination = lw_tvrab-knend.
                ENDIF.
              ELSE.
                " Fallback to TVRAB destination if chainship data not found
                lw_rtm_details-destination = lw_tvrab-knend.
              ENDIF.
* END: Cursor Generated Code
            ENDIF.

            CLEAR lw_yttstm0001.
            READ TABLE lt_yttstm0001 INTO lw_yttstm0001 WITH KEY truck_no = lw_vttk-signi+0(15) BINARY SEARCH.
            IF sy-subrc = 0.
              lw_rtm_details-vehicletype = lw_yttstm0001-qwik_vehi_type.
            ENDIF.

            CLEAR lw_ttds.
            READ TABLE lt_ttds INTO lw_ttds WITH KEY tplst = lw_vttk-tplst BINARY SEARCH.
            IF sy-subrc = 0.
              CLEAR lw_zlog_exec_var.
              READ TABLE lt_zlog_exec_var INTO lw_zlog_exec_var WITH KEY name  = lc_zscm_get_mm_business
                                                                         bukrs = lw_ttds-bukrs. " param table less records no binary search required
              IF sy-subrc = 0.
                lw_rtm_details-businessid = lw_zlog_exec_var-remarks.

                CLEAR lw_zlog_exec_var_1.
                READ TABLE lt_zlog_exec_var INTO lw_zlog_exec_var_1 WITH KEY name    = lc_zscm_get_mm_subbusiness
                                                                             remarks = lw_zlog_exec_var-remarks.  " param table less records no binary search required
                IF sy-subrc = 0.
                  lw_rtm_details-subbusinessid = lw_zlog_exec_var_1-errormsg.
                ENDIF.

              ENDIF.
            ENDIF.

            CLEAR lw_lips.
            READ TABLE lt_lips INTO lw_lips WITH KEY vbeln = lw_vttp-vbeln BINARY SEARCH.
            IF sy-subrc = 0.

              CLEAR lw_zlog_exec_var.
              READ TABLE lt_zlog_exec_var INTO lw_zlog_exec_var WITH KEY name    = lc_zscm_get_ril_prodsub
                                                                         remarks = lw_zlog_exec_var_1-errormsg+0(72)
                                                                         spart   = lw_lips-spart. " param table less records no binary search required
              IF sy-subrc = 0.
                lw_rtm_details-subformatcode = lw_zlog_exec_var-rfcdest.
              ENDIF.
            ENDIF.


            CLEAR lw_zlog_exec_var.
            READ TABLE lt_zlog_exec_var INTO lw_zlog_exec_var WITH KEY name  = lc_scme_pf_tms_servcat
                                                                       shtyp = lw_vttk-shtyp. " param table less records no binary search required
            IF sy-subrc = 0.
              lw_rtm_details-servicecategory = lw_zlog_exec_var-remarks.
            ENDIF.


            CLEAR:lw_chargecodes,lw_zlog_exec_var.
            READ TABLE lt_zlog_exec_var INTO lw_zlog_exec_var WITH KEY name      = lc_zscm_get_rtm_chargecode
                                                                       shtyp     = lw_vttk-shtyp
                                                                       transplpt = lw_vttk-tplst.  " param table less records no binary search required
            IF sy-subrc = 0.
              lw_chargecodes = lw_zlog_exec_var-remarks.
              APPEND lw_chargecodes TO lw_rtm_details-specificchargecodes.
            ENDIF.

            " BEGIN: Cursor Generated Code
            " Read rail yard locations from pre-fetched mapping table
            CLEAR: lv_rail_source, lv_rail_dest.
            CLEAR lw_rail_location_map.
            READ TABLE lt_rail_location_map INTO lw_rail_location_map
              WITH KEY tknum = lw_vttk-tknum
              BINARY SEARCH.
            IF sy-subrc = 0.
              lv_rail_source = lw_rail_location_map-rail_source.
              lv_rail_dest = lw_rail_location_map-rail_dest.
            ENDIF.
            
            " Populate rail yard locations in output structure
            lw_rtm_details-railyardsourcelocation = lv_rail_source.
            lw_rtm_details-railyarddestinationlocation = lv_rail_dest.
            " END: Cursor Generated Code
          ENDIF.
          lw_rtm_details-date = |{ sy-datum+6(2) }{ '.' }{ sy-datum+4(2) }{ '.' }{ sy-datum+0(4) } |.

          APPEND lw_rtm_details TO et_rtm_details.
          CLEAR: lw_rtm_details,lw_vttp.

        ENDLOOP.
      ENDIF.
      CLEAR lw_vttk.
    ENDLOOP.
  ENDIF.


ENDFUNCTION.

