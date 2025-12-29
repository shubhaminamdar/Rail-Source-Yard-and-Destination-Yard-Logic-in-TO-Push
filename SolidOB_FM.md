FUNCTION z_scm_solids_ob_getdet.
*"----------------------------------------------------------------------
*"*"Local Interface: *" IMPORTING *" REFERENCE(I_TKNUM) TYPE
ZSCE_TKNUM_RANGE_TT OPTIONAL *" REFERENCE(I_DISPT_DT) TYPE
ZSCE_DATBG_RANGE_TT *" REFERENCE(I_TPLST) TYPE ZSCE_TPLST_RANGE_TT
OPTIONAL *" EXPORTING *" REFERENCE(ET_SOB_HEADER_DATA) TYPE
ZSCE_ORDER_HDR_DATA_T *" REFERENCE(ET_SOB_CN_DATA) TYPE ZSCE_CN_DATA_T
*" REFERENCE(ET_SOB_CUST_DOC_DATA) TYPE ZSCE_CUST_DOC_DATA_T
*"----------------------------------------------------------------------
\* Create Date : 21.04.2020 \* Release : 1.0 \* Technical Author : Ravi
M. \* Functional Author : Minal Tike
*----------------------------------------------------------------------*
\* Description : FM to fetch a details for solids outbound
*----------------------------------------------------------------------*
\* CHANGE HISTORY
*----------------------------------------------------------------------*
*SrNo\| Date \| User ID \| Description \| Change Label \|
*----------------------------------------------------------------------* *
1 \| \| \| \| \|
*----------------------------------------------------------------------*
TYPES : BEGIN OF lty_addrnum, addrnumber TYPE ad_addrnum, END OF
lty_addrnum,

         BEGIN OF lty_qwik_vehtyp,
            qwik_vehi_type TYPE zvehtype,
           END OF lty_qwik_vehtyp,

        BEGIN OF lty_trstlmnt,
            tknum  TYPE tknum,
            vbeln  TYPE vbeln_vl,
            bill_doc_qty TYPE fkimg,
            lr_no  TYPE zlr_no_stl,
            lr_dt  TYPE zlr_dt_stl,
            lr_qty TYPE zfkimg_stl,
            lr_uom TYPE zlr_uom,
          END OF lty_trstlmnt,

          BEGIN OF lty_vekp,
            venum    TYPE venum,
            vhilm    TYPE vhilm,
            vhart    TYPE vhiart,
            vpobj    TYPE vpobj,
            vpobjkey TYPE vpobjkey,
            status   TYPE hu_status,
          END OF lty_vekp,

          BEGIN OF lty_vpobjkey,
            vpobjkey TYPE vpobjkey,
          END OF lty_vpobjkey,

          BEGIN OF lty_mara,
            matnr TYPE matnr,
            matkl TYPE matkl,
          END OF lty_mara,

          BEGIN OF lty_yttstx0001,
              area       TYPE yarea,
              report_no  TYPE yreport_no,
              truck_no   TYPE ytruck_no,
              shnumber   TYPE oig_shnum,
              reject_res TYPE yreasoncd,
              trk_purpos TYPE ytrk_purps,
          END OF lty_yttstx0001,

          BEGIN OF lty_marc,
            matnr TYPE matnr,
            werks TYPE werks_d,
            mfrgr TYPE mfrgr ,
          END OF lty_marc,

          BEGIN OF lty_zfcplbill,
            vbeln     TYPE vbeln_va,
            billno    TYPE vbeln_vf,
            zfcplbill TYPE vbeln_vf,
            fksto     TYPE fksto,
            fkart     TYPE fkart,
          END OF lty_zfcplbill,

          BEGIN OF lty_zlog_exec_var1,
             name TYPE zlog_exec_var-name,
             active TYPE zlog_exec_var-active,
             remarks TYPE zlog_exec_var-remarks,
             ewb_uom_d TYPE zlog_exec_var-ewb_uom_d,
          END OF lty_zlog_exec_var1.

" soc by omkar more on 23.11.2024 CD:8079928 TR:RD2K9A4ZJE TYPES: BEGIN
OF lty_zlog_exec_var_sub_prod, name TYPE rvari_vnam, numb TYPE
tvarv_numb, active TYPE zactive_flag, remarks TYPE textr, spart TYPE
spart, rfcdest TYPE rfcdest, errormsg TYPE natxt, END OF
lty_zlog_exec_var_sub_prod.

DATA: lw_zlog_exec_var_sub_prod TYPE gty_zlog_exec_var. " eoc by omkar
more on 23.11.2024 CD:8079928 TR:RD2K9A4ZJE

"BOC - Railyard Location Enhancement TYPES: BEGIN OF lty_zlog_rail_loc,
         mandt    TYPE mandt,
         name     TYPE rvari_vnam,
         active   TYPE zactive_flag,
         bukrs    TYPE bukrs,
         remarks  TYPE textr,
       END OF lty_zlog_rail_loc,

         BEGIN OF lty_ekpv,
         ebeln    TYPE ebeln,
         ebelp    TYPE ebelp,
         route    TYPE route,
       END OF lty_ekpv,

         BEGIN OF lty_vbap_route,
         vbeln    TYPE vbeln_va,
         posnr    TYPE posnr,
         route    TYPE route,
       END OF lty_vbap_route,

         BEGIN OF lty_zscm_chainship,
         shnumber TYPE tknum,
         chainid  TYPE zchain_id,
         odpairid TYPE zodpair_id,
       END OF lty_zscm_chainship,

         BEGIN OF lty_tvrab_rail,
         route    TYPE route,
         vsart    TYPE vsart,
         knanf    TYPE knota,
         knend    TYPE knotz,
       END OF lty_tvrab_rail.
"EOC - Railyard Location Enhancement

TYPES:BEGIN OF lty_vbrk_1, vbeln TYPE vbeln_vf, fkart TYPE fkart, fksto
TYPE fksto, END OF lty_vbrk_1, BEGIN OF lty_vbrp_1, vbeln TYPE vbeln_vf,
posnr TYPE posnr_vf, vgbel TYPE vgbel, END OF lty_vbrp_1.

DATA: lt_vbrk_1 TYPE TABLE OF lty_vbrk_1, lt_vbrk_1\_temp TYPE TABLE OF
lty_vbrk_1, lw_vbrk_1 TYPE lty_vbrk_1, ltr_fkart TYPE RANGE OF fkart,
lwr_fkart LIKE LINE OF ltr_fkart, lt_vbrp_1 TYPE TABLE OF lty_vbrp_1,
lt_vbrp_1\_temp TYPE TABLE OF lty_vbrp_1, lw_vbrp_1 TYPE lty_vbrp_1.

DATA:lt_zlog_exec_var1 TYPE TABLE OF lty_zlog_exec_var1,
lw_zlog_exec_var1 TYPE lty_zlog_exec_var1.

TYPES:BEGIN OF ty_naroda_lr, name TYPE rvari_vnam, numb TYPE tvarv_numb,
shtyp TYPE shtyp, active TYPE zactive_flag, remarks TYPE textr, END OF
ty_naroda_lr.

DATA: lt_naroda_lr TYPE STANDARD TABLE OF ty_naroda_lr, lw_naroda_lr
TYPE ty_naroda_lr.

DATA : lr_shtyp TYPE RANGE OF shtyp, lw_shtyp LIKE LINE OF lr_shtyp.

DATA : lw_tknum TYPE tknum, lw_tknum1 TYPE tknum, lw_tdlnr TYPE tdlnr,
lw_index TYPE sy-tabix, lw_index_i TYPE sy-tabix, lw_rcode TYPE char3,
lw_rdesc(254) TYPE c, lw_matnr_prev TYPE matnr, lw_vbrk_vbeln TYPE
vbeln.

DATA : lt_route TYPE TABLE OF route_vl, lw_route TYPE route_vl,
lt_addrnum TYPE TABLE OF lty_addrnum, lw_addrnum TYPE lty_addrnum.

DATA : lr_sdabw TYPE RANGE OF sdabw, lw_sdabw LIKE LINE OF lr_sdabw,
lw_fkimg TYPE fkimg.

DATA : lw_nettax TYPE kbetr, lt_invoice TYPE TABLE OF vbeln_vf,
lw_invoice TYPE vbeln_vf, lt_total TYPE TABLE OF zsce_ewb_total,
lw_total TYPE zsce_ewb_total, lw_cn_itm_no TYPE char16, lw_tran_dur TYPE
traztd, lv_knanf TYPE knota, lv_knend TYPE knotz, lv_zfst TYPE kwert.
"Added By Kalpesh/Gaurav 28.08.2025 RD2K9A5BBT

DATA : lr_objectid TYPE RANGE OF cdobjectv, lw_objectid LIKE LINE OF
lr_objectid.

DATA : lt_qwik_vehtyp TYPE TABLE OF lty_qwik_vehtyp, lw_qwik_vehtyp TYPE
lty_qwik_vehtyp, lt_trstlmn TYPE TABLE OF lty_trstlmnt, lt_trstlmn_zocc
TYPE TABLE OF lty_trstlmnt, lt_trstlmn_zocc_t TYPE TABLE OF
lty_trstlmnt, lw_trstlmn TYPE lty_trstlmnt, lw_trstlmn_zocc TYPE
lty_trstlmnt, lt_add02 TYPE TABLE OF zvehtype, lw_add02 TYPE zvehtype.

"added on 19.05.2020 (For QWIK vehicle type) DATA: lt_truckno TYPE
zscm_truckno_t, lt_truckno_tmp TYPE zscm_truckno_t, lw_truckno TYPE
zscm_truckno_s, lt_vehtype TYPE zscm_vehtyp_tt, lw_vehtype TYPE
zscm_vehtyp_st, lt_return TYPE bapiret2_t."end on 19.05.2020

DATA : lt_vpobjkey TYPE TABLE OF lty_vpobjkey, lw_vpobjkey TYPE
lty_vpobjkey, lt_vekp TYPE TABLE OF lty_vekp, lt_vekp_t TYPE TABLE OF
lty_vekp, lw_vekp TYPE lty_vekp, lt_mara TYPE TABLE OF lty_mara, lw_mara
TYPE lty_mara, lt_yttstx0001 TYPE TABLE OF lty_yttstx0001, lw_yttstx0001
TYPE lty_yttstx0001, lt_marc TYPE TABLE OF lty_marc, lw_marc TYPE
lty_marc, lt_zfcplbill TYPE STANDARD TABLE OF lty_zfcplbill,
lw_zfcplbill TYPE lty_zfcplbill, lt_bill_no TYPE TABLE OF
zsce_vbeln_str, lw_bill_no TYPE zsce_vbeln_str, lw_dest TYPE char70,
lt_frtinv_val TYPE TABLE OF zsce_il_netwr_s, lw_frtinv_val TYPE
zsce_il_netwr_s, lw_zlog_exec_var_tmp TYPE gty_zlog_exec_var.

DATA : lr_billno TYPE RANGE OF vbeln_vf, lw_billno LIKE LINE OF
lr_billno, lr_trk_purps TYPE RANGE OF ytrk_purps, lw_trk_purps LIKE LINE
OF lr_trk_purps, lt_zscm_efrcontyp TYPE STANDARD TABLE OF
zscm_efrcontyp, lw_zscm_efrcontyp TYPE zscm_efrcontyp, lw_tab TYPE
sy-tabix.

DATA : lw_weight TYPE string, lw_uom TYPE string.

DATA: lv_flag TYPE char1. """"""""""Shashank code added 30.09.2022

TYPES: BEGIN OF lty_vbap, vbeln TYPE vbap-vbeln, vgbel TYPE vgbel, END
OF lty_vbap, BEGIN OF lty_lips_zocc, vbeln TYPE lips-vbeln, posnr TYPE
lips-posnr, meins TYPE lips-meins, ntgew TYPE lips-ntgew, vgbel TYPE
vgbel, END OF lty_lips_zocc, BEGIN OF lty_zptc_lrpo, lr_no TYPE
zptc_lrpo-lr_no, quantity_l TYPE zptc_lrpo-quantity_l, meins TYPE
zptc_lrpo-meins, END OF lty_zptc_lrpo.

DATA: lt_vbap TYPE TABLE OF lty_vbap, lt_vbap_t TYPE TABLE OF lty_vbap,
lw_vbap TYPE lty_vbap, lv_shtyp TYPE shtyp, lv_tplst TYPE tplst,
lt_lips_zocc TYPE TABLE OF lty_lips_zocc, lt_lips_zocc_t TYPE TABLE OF
lty_lips_zocc, lw_lips_zocc TYPE lty_lips_zocc, lt_zptc_lrpo TYPE TABLE
OF lty_zptc_lrpo, lw_zptc_lrpo TYPE lty_zptc_lrpo.

-   BOC Eswara DATA: lt_shipment_det TYPE zscm_efr_shp_tt,
    lw_shipment_det TYPE zscm_efr_shp, lt_shipmentoprd_cat TYPE
    zscm_efr_shp_tt, lw_shipmentoprd_cat TYPE zscm_efr_shp.
-   EOC Eswara

"BOC By Arpit H. Patel 10.04.2023 17:43:18 TYPES : BEGIN OF
lty_zlog_exec_var, name TYPE rvari_vnam, shtyp TYPE shtyp, rfcdest TYPE
rfcdest, END OF lty_zlog_exec_var.

DATA : lt_zlog_exec_var TYPE STANDARD TABLE OF lty_zlog_exec_var,
lt_zlog_exec_zocc TYPE STANDARD TABLE OF lty_zlog_exec_var,
lw_zlog_exec_var TYPE lty_zlog_exec_var, lw_zlog_exec_zocc TYPE
lty_zlog_exec_var, lw_scm_get_sub_prod_id TYPE gty_zlog_exec_var.

"EOC By Arpit H. Patel 10.04.2023 17:43:18 CONSTANTS : lc_ob_ship_types
TYPE rvari_vnam VALUE 'SCME_SOL_OB_TO_SHTYP', lc_nrd_contract TYPE
rvari_vnam VALUE 'SCME_PF_NRD_CONTRACT', lc_charge_wt TYPE rvari_vnam
VALUE 'Z_SCM_CHARGE_WT_FETCH', lc_package_get TYPE rvari_vnam VALUE
'ZSCM_PACKAGE_GET'," Added By Husna Basri TR : 07/02/2025
gc_scm_qwik_rsncode TYPE rvari_vnam VALUE 'ZSCM_QWIK_GLOBAL_RSNCODE',
gc_zscm_freight_value_solids TYPE rvari_vnam VALUE
'ZSCM_FREIGHT_VALUE_SOLIDS', gc_zscm_export_road_shtyp TYPE rvari_vnam
VALUE 'ZSCM_EXPORT_ROAD_SHTYP', lc_zscm_get_rpl_sub TYPE rvari_vnam
VALUE 'ZSCM_GET_RPL_SUB'," added by omkar more on 23.11.2024 CD:8079928
TR:RD2K9A4ZJE lc_scm_get_sub_prod_id TYPE rvari_vnam VALUE
'Z_SCM_GET_SUB_PROD_ID', lc_subformat TYPE rvari_vnam VALUE
'ZSCM_RPL_GET_SUBFORMAT', "Added By Kalpesh/Shubham 10.12.2024
RD2K9A50AK lc_naroda_to_push TYPE rvari_vnam VALUE
'NARODA_TO_PUSH',"added by omkar more on 24.12.2024 TR:RD2K9A510H
lc_zscm_get_ril_prodsub TYPE rvari_vnam VALUE 'ZSCM_GET_RIL_PRODSUB',
lc_rail_loc_config TYPE rvari_vnam VALUE 'ZSCM_GET_RAIL_LOCATION'.
"Added for Railyard Location Enhancement

REFRESH : gt_zlog_exec_var, gt_vttk, gt_yttstx0002, gt_yttstx0001,
gt_zsce_cnnt, gt_vbrk, gt_zlog_stlmntvr, gt_ylicm, gt_tvtk, gt_vttp,
gt_tvro, gt_likp, gt_tvrab, gt_vbrp, gt_kna1, gt_lips, gt_vbak, gt_likp,
gt_ekko, gt_ekpo, gt_t001w, gt_adrc, gt_vbfa.

FIELD-SYMBOLS : `<lfs_yttstx0002>`{=html} TYPE gty_yttstx0002,
`<lfs_charge>`{=html} TYPE any.

"""BOC BY Kalpesh 31.01.2024 TYPES : BEGIN OF lty_ztrstlmnt, tknum TYPE
tknum, lr_dt TYPE zlr_dt_stl,"Added by Ajay on March 15th 2024 FE :
Sbhubham Inamdar - RD2K9A4NWT bill_regime TYPE textr, END OF
lty_ztrstlmnt,

          BEGIN OF lty_par,
          name TYPE rvari_vnam,
          active TYPE zactive_flag,
          remarks TYPE textr,
          bill_vendor TYPE zbill_vendor,
          errormsg TYPE natxt,
          END OF lty_par,

          BEGIN OF lty_ship,
          tknum TYPE tknum,
          END OF lty_ship.

DATA : lt_ztrstlmnt TYPE TABLE OF lty_ztrstlmnt, lt_ztrstlmnt_t TYPE
TABLE OF lty_ztrstlmnt, lw_ztrstlmnt TYPE lty_ztrstlmnt, lt_par TYPE
TABLE OF lty_par, lw_par TYPE lty_par, lt_ship TYPE TABLE OF lty_ship,
lw_ship TYPE lty_ship, lw_shipment TYPE zsce_tknum_range, lv_date TYPE
datum, "Added by Ajay on March 15th 2024 FE : Sbhubham Inamdar -
RD2K9A4NWT lv_billreg TYPE char10,"Added by Ajay on March 15th 2024 FE :
Sbhubham Inamdar - RD2K9A4NWT lw_subformat_t TYPE gty_zlog_exec_var.
"Added By Kalpesh/Shubham 10.12.2024 RD2K9A50AK

CONSTANTS : lc_name TYPE string VALUE 'ZSCM_VEND_BILL_MAP'.

FIELD-SYMBOLS: `<lfs_ztrstlmnt>`{=html} TYPE lty_ztrstlmnt. "Vankudoth
Rajkumar/shubham

""""BOC BY Kalpesh/Biswa 27.06.2024 TYPES : BEGIN OF
lty_zscm_fcm_ven_map, mandt TYPE mandt, lifnr TYPE lifnr, bill_regime
TYPE zbill_regime, active TYPE zscm_active, fcm5 TYPE zscm_active, END
OF lty_zscm_fcm_ven_map,

          BEGIN OF lty_zlog,
          mandt       TYPE mandt,
          name        TYPE rvari_vnam,
          active      TYPE zactive_flag,
          remarks     TYPE textr,
          bill_vendor TYPE zbill_vendor,
          errormsg    TYPE natxt,
          END OF lty_zlog.

DATA : lt_zscm_fcm_ven_map TYPE TABLE OF lty_zscm_fcm_ven_map,
lw_zscm_fcm_ven_map TYPE lty_zscm_fcm_ven_map, lt_zlog TYPE TABLE OF
lty_zlog, lw_zlog TYPE lty_zlog, lv_bussid_flg TYPE c. " Business id
Flag """EOC By Kalpesh /Biswa 27.06.2024

" Soc Husna Basri TR : RD2K9A4Z4J Dated : 13/11/2024 TYPES: BEGIN OF
lty_zlog_exec, mandt TYPE zlog_exec_var-mandt, name TYPE
zlog_exec_var-name, active TYPE zlog_exec_var-active, END OF
lty_zlog_exec. DATA : lw_zlog_exec TYPE lty_zlog_exec.

DATA : lt_tknum TYPE zscm_ship_tt, lw_tknum2 TYPE zscm_ship_st,
lt_bus_details TYPE zbus_subbus_details_t, lw_bus_details TYPE
zbus_subbus_details.

-   DATA : ltr_tknum TYPE zsce_tknum_range_tt,

-     lwr_tknum TYPE zsce_tknum_range.

    " Eoc Husna Basri TR : RD2K9A4Z4J Dated : 13/11/2024

-   Added by SN Das CD:8079928(Start) TYPES : BEGIN OF lty_sub_business,
    name TYPE zlog_exec_var-name, numb TYPE zlog_exec_var-numb, active
    TYPE zlog_exec_var-active, remarks TYPE zlog_exec_var-remarks, spart
    TYPE zlog_exec_var-spart, END OF lty_sub_business. " SOC Husna Basri
    TR : Dated : 07/02/2025 TYPES: BEGIN OF lty_likp, vbeln TYPE
    likp-vbeln, anzpk TYPE likp-anzpk, END OF lty_likp.

    DATA : lt_likp TYPE TABLE OF lty_likp, lw_likp TYPE lty_likp.

    " EOC Husna Basri TR : Dated : 07/02/2025 DATA : lw_remark TYPE
    textr, lw_subusiness_id TYPE char40, lw_sub_business TYPE
    lty_sub_business, lt_sub_business TYPE TABLE OF lty_sub_business.

    RANGES: lr_parvw FOR gw_vbpa-parvw.

-   Added by SN Das CD:8079928(End) CONSTANTS : lc_business TYPE
    rvari_vnam VALUE 'ZSCM_GET_RPL_BUS', "Added By Kalpesh/Shubham
    28.11.2024 RD2K9A4ZRP lc_subbusiness TYPE rvari_vnam VALUE
    'ZSCM_GET_RPL_SUB'."Added By Kalpesh/Shubham 28.11.2024 RD2K9A4ZRP

-   -   Added by SN Das CD:8085996(Start) TYPES:BEGIN OF lty_exec_var,
        name TYPE zlog_exec_var-name, numb TYPE zlog_exec_var-numb,
        active TYPE zlog_exec_var-active, remarks TYPE
        zlog_exec_var-remarks, END OF lty_exec_var.

TYPES:BEGIN OF lty_vbrk, vbeln TYPE vbrk-vbeln, fkart TYPE vbrk-fkart,
fksto TYPE vbrk-fksto, END OF lty_vbrk.

DATA:lw_exec_var TYPE lty_exec_var, lt_exec_var TYPE TABLE OF
lty_exec_var, lw_vbrk TYPE lty_vbrk, lt_vbrk TYPE TABLE OF lty_vbrk,
lt_vbap_t\_1 TYPE TABLE OF lty_vbap.

RANGES:lr_fkart FOR lw_vbrk-fkart, lr_inv FOR lw_vbrk-vbeln. " Added by
SN Das CD:8085996(End)

DATA:lw_parvw TYPE parvw, lw_field TYPE char25.

FIELD-SYMBOLS:`<fs_field>`{=html} TYPE any, `<fs_val>`{=html} TYPE any.
\* \* Added by SN Das CD:8083938(Start)

""""""BOC BY Kalpesh/Shubham 18.11.2025 RD2K9A5E49 TYPES : BEGIN OF
lty_ttds, mandt TYPE mandt, tplst TYPE tplst, bukrs TYPE bukrs, END OF
lty_ttds,

            BEGIN OF lty_zlogs,
            mandt    TYPE mandt,
            name     TYPE rvari_vnam,
            active   TYPE zactive_flag,
            remarks  TYPE textr,
            errormsg TYPE natxt,
            bukrs    TYPE bukrs,
            END OF lty_zlogs.

DATA : lt_ttds TYPE TABLE OF lty_ttds, lw_ttds TYPE lty_ttds, lt_zlogs
TYPE TABLE OF lty_zlogs, lw_zlogs TYPE lty_zlogs, lw_zlogs1 TYPE
lty_zlogs. CONSTANTS : lc_business_name TYPE rvari_vnam VALUE
'ZSCM_GET_MM_BUSINESS', lc_subusiness_name TYPE rvari_vnam VALUE
'ZSCM_GET_MM_SUBBUSINESS'. """"""EOC BY Kalpesh/Shubham 18.11.2025
RD2K9A5E49

"BOC - Railyard Location Enhancement
DATA: lt_zlog_rail_loc TYPE TABLE OF lty_zlog_rail_loc,
      lw_zlog_rail_loc TYPE lty_zlog_rail_loc,
      lw_ekpv TYPE lty_ekpv,
      lw_vbap_route TYPE lty_vbap_route,
      lw_zscm_chainship TYPE lty_zscm_chainship,
      lw_tvrab_rail TYPE lty_tvrab_rail,
      lv_route TYPE route,
      lv_multimode_route TYPE route,
      lv_bukrs TYPE bukrs,
      lv_rail_loc_flag TYPE char1.
"EOC - Railyard Location Enhancement

SELECT name active remarks ewb_uom_d FROM zlog_exec_var "Added by
Gagan/Arya 24/04/2024 RD2K9A4PZF INTO TABLE lt_zlog_exec_var1 WHERE (
name = 'ZSCM_VEND_BILL_MAP' OR name = 'ZSCM_GET_TOPUSH_PARTNFN' )."Added
by SN Das CD:8083938 IF sy-subrc = 0."Added by SN Das CD:8083938
CLEAR:lw_zlog_exec_var1,lr_parvw,lr_parvw\[\]. LOOP AT lt_zlog_exec_var1
INTO lw_zlog_exec_var1 WHERE name = 'ZSCM_GET_TOPUSH_PARTNFN' AND active
= 'X'. lr_parvw-sign = 'I'.lr_parvw-option = 'EQ'.lr_parvw-low =
lw_zlog_exec_var1-remarks. lr_parvw-high = ''. APPEND lr_parvw TO
lr_parvw. CLEAR:lr_parvw,lw_zlog_exec_var1. ENDLOOP. ENDIF."Added by SN
Das CD:8083938 "Fetch shipment types & Other param details SELECT name
shtyp shtype mfrgr" eswara active remarks transplpt spart rfcdest
ewb_uom_d zzpmatkl1 errormsg FROM zlog_exec_var CLIENT SPECIFIED INTO
CORRESPONDING FIELDS OF TABLE gt_zlog_exec_var WHERE mandt = sy-mandt
AND name IN (lc_ob_ship_types, gc_business, gc_trans_movt, gc_servcat,
gc_gst_vend_rd, gc_nrd_shtyp,gc_product_cat, gc_business_id,
gc_subform_id, lc_nrd_contract, lc_charge_wt,gc_nrd_ogp_shp_exclude,
gc_subformat, gc_scm_qwik_rsncode, gc_pol_subform_id,
gc_shtyp_subform_id, gc_mfg_marc_subform_id
,gc_zscm_freight_value_solids,
gc_zscm_export_road_shtyp,lc_scm_get_sub_prod_id,lc_zscm_get_rpl_sub,lc_subformat,lc_package_get,lc_zscm_get_ril_prodsub)
AND active = abap_true . IF sy-subrc \<\> 0. CLEAR : gt_zlog_exec_var.
ENDIF.

SELECT \* FROM zscm_efrcontyp INTO TABLE lt_zscm_efrcontyp. IF sy-subrc
\<\> 0. CLEAR:lt_zscm_efrcontyp. ENDIF.

"Prepare range for shipment type lw_shtyp-option = 'EQ'. lw_shtyp-sign =
'I'. LOOP AT gt_zlog_exec_var INTO gw_zlog_exec_var. IF NOT
gw_zlog_exec_var-shtyp IS INITIAL AND gw_zlog_exec_var-name =
lc_ob_ship_types . lw_shtyp-low = gw_zlog_exec_var-shtyp. APPEND
lw_shtyp TO lr_shtyp. ENDIF. CLEAR : lw_shtyp-low. ENDLOOP.

IF i_dispt_dt IS NOT INITIAL AND lr_shtyp IS NOT INITIAL. SELECT tknum
shtyp tplst erdat vsart route signi exti2 tpbez "added by arpit dareg
uareg dplbg uplbg datbg uatbg daten uaten sttrg tdlnr sdabw add02 text4
tndr_trkid zzlr_no zzlr_dt zzlr_qty zz_uom zzogpno zzogptyp zzwerks
zzvhicap zzvhiuom zzserv_plant zzres_des FROM vttk CLIENT SPECIFIED INTO
TABLE gt_vttk WHERE mandt EQ sy-mandt AND datbg IN i_dispt_dt AND tplst
IN i_tplst AND shtyp IN lr_shtyp AND sttrg GE '6'. IF sy-subrc = 0.
DELETE gt_vttk WHERE shtyp NOT IN lr_shtyp. DELETE gt_vttk WHERE vsart
NE 'RD'. IF i_tknum IS NOT INITIAL. DELETE gt_vttk WHERE tknum NOT IN
i_tknum. ENDIF. SORT gt_vttk BY tknum. ENDIF.

    "vankudoth rajkumar(soc).
    IF gt_vttk[] IS NOT INITIAL.
      gt_vttk_ob[] = gt_vttk[].
      SORT gt_vttk_ob BY tknum.
      DELETE ADJACENT DUPLICATES FROM gt_vttk_ob COMPARING tknum.
    ENDIF.

    IF gt_vttk_ob[] IS NOT INITIAL.
      SELECT tknum lr_dt bill_regime
        INTO TABLE lt_ztrstlmnt
        FROM ztrstlmnt
        FOR ALL ENTRIES IN gt_vttk_ob
        WHERE tknum = gt_vttk_ob-tknum.
      IF sy-subrc = 0.
        SORT : lt_ztrstlmnt BY tknum.
      ENDIF.

      LOOP AT lt_ztrstlmnt ASSIGNING <lfs_ztrstlmnt>.
        IF <lfs_ztrstlmnt> IS ASSIGNED.
          IF <lfs_ztrstlmnt>-bill_regime IS INITIAL AND <lfs_ztrstlmnt>-lr_dt IS NOT INITIAL AND <lfs_ztrstlmnt>-tknum IS NOT INITIAL. "lw_ztrstlmnt-bill_regime IS INITIAL.
            "Call FM
            CLEAR : lv_date.
            lv_date = <lfs_ztrstlmnt>-lr_dt.
            CALL FUNCTION 'Z_SCM_FCM_VEND_ELGBTY_CHK'
              EXPORTING
                iv_shipment_number = <lfs_ztrstlmnt>-tknum
                iv_validity_date   = lv_date
              IMPORTING

-             ET_RETURN          =
                  ev_billing_regime  = lv_billreg.
              <lfs_ztrstlmnt>-bill_regime = lv_billreg.

            ENDIF.
          ENDIF.
        ENDLOOP.
        IF <lfs_ztrstlmnt> IS ASSIGNED.
          UNASSIGN <lfs_ztrstlmnt>.
        ENDIF.

        CLEAR : lt_ztrstlmnt_t[].
        lt_ztrstlmnt_t[] = lt_ztrstlmnt[].
        SORT : lt_ztrstlmnt_t BY bill_regime.
        DELETE ADJACENT DUPLICATES FROM lt_ztrstlmnt_t COMPARING bill_regime .   "Added by Gagan/Arya 24/04/2024 RD2K9A4PZF

        CLEAR : lt_par[].
        IF lt_ztrstlmnt_t IS NOT INITIAL.
          SELECT name
                 active
                 remarks
                 bill_vendor
                 errormsg
                 FROM zlog_exec_var
                 INTO TABLE lt_par
                 FOR ALL ENTRIES IN lt_ztrstlmnt_t
                 WHERE name = lc_name
                 AND active = 'X'
                 AND remarks = lt_ztrstlmnt_t-bill_regime.
          IF sy-subrc = 0.
            SORT : lt_par BY name remarks.
          ENDIF.
        ENDIF.

    ENDIF. "vankudoth rajkumar(eoc)."""BOC BY Kalpesh/Biswa 27.06.2024
    CLEAR : gt_vttk_ob\[\]. gt_vttk_ob\[\] = gt_vttk\[\]. SORT :
    gt_vttk_ob BY tdlnr. DELETE gt_vttk_ob WHERE tdlnr IS INITIAL.
    DELETE ADJACENT DUPLICATES FROM gt_vttk_ob COMPARING tdlnr. IF
    gt_vttk_ob\[\] IS NOT INITIAL. CLEAR : lt_zscm_fcm_ven_map\[\].
    SELECT mandt lifnr bill_regime active fcm5 FROM zscm_fcm_ven_map
    CLIENT SPECIFIED INTO TABLE lt_zscm_fcm_ven_map FOR ALL ENTRIES IN
    gt_vttk_ob WHERE mandt = sy-mandt AND lifnr = gt_vttk_ob-tdlnr AND
    active = abap_true AND fcm5 = abap_true. IF sy-subrc = 0. SORT :
    lt_zscm_fcm_ven_map BY lifnr. ENDIF. CLEAR : lt_zlog\[\]. SELECT
    mandt name active remarks bill_vendor errormsg FROM zlog_exec_var
    CLIENT SPECIFIED INTO TABLE lt_zlog WHERE mandt = sy-mandt AND name
    = 'ZSCM_VEND_BILL_RULE_FCM' AND active = abap_true. IF sy-subrc = 0.
    SORT : lt_zlog BY name. ENDIF. ENDIF.""""EOC By Kalpesh/Biswa
    27.06.2024 ENDIF."BOC By Arpit H. Patel 10.04.2023 17:40:27 SELECT
    name shtyp rfcdest FROM zlog_exec_var INTO TABLE lt_zlog_exec_var
    WHERE name EQ 'ZSCE_NARODA_CHWT_OB' AND active EQ 'X'. IF sy-subrc
    EQ 0. SORT lt_zlog_exec_var BY shtyp. ENDIF.

    "EOC By Arpit H. Patel 10.04.2023 17:40:27" Exclude shipments for
    Naroda OGP REFRESH gt_vttk_t. gt_vttk_t\[\] = gt_vttk\[\]. LOOP AT
    gt_vttk_t INTO gw_vttk. READ TABLE lt_zlog_exec_var INTO
    lw_zlog_exec_var WITH KEY shtyp = gw_vttk-shtyp BINARY SEARCH. IF
    sy-subrc EQ 0 AND gw_vttk-tpbez NE 'X'. DELETE gt_vttk WHERE tknum =
    gw_vttk-tknum. ENDIF. READ TABLE gt_zlog_exec_var INTO
    gw_zlog_exec_var WITH KEY name = gc_nrd_ogp_shp_exclude shtyp =
    gw_vttk-shtyp transplpt = gw_vttk-tplst. "Binary search not required
    IF sy-subrc = 0. DELETE gt_vttk WHERE tknum = gw_vttk-tknum. ENDIF.
    CLEAR : gw_vttk, gw_zlog_exec_var,lw_zlog_exec_var. ENDLOOP. REFRESH
    gt_vttk_t.

    IF gt_vttk IS INITIAL. RETURN. """"""BOC BY Kalpesh/Shubham
    18.11.2025 RD2K9A5E49 ELSE.

    CLEAR : gt_vttk_t\[\]. gt_vttk_t\[\] = gt_vttk\[\]. SORT : gt_vttk_t
    BY tplst. DELETE gt_vttk_t WHERE tplst IS INITIAL. DELETE ADJACENT
    DUPLICATES FROM gt_vttk_t COMPARING tplst. IF gt_vttk_t\[\] IS NOT
    INITIAL. CLEAR : lt_ttds\[\]. SELECT mandt tplst bukrs FROM ttds
    CLIENT SPECIFIED INTO TABLE lt_ttds FOR ALL ENTRIES IN gt_vttk_t
    WHERE mandt = sy-mandt AND tplst = gt_vttk_t-tplst. IF sy-subrc = 0.
    SORT : lt_ttds BY tplst. ENDIF. ENDIF.

    CLEAR : lt_zlogs\[\]. SELECT mandt name active remarks errormsg
    bukrs FROM zlog_exec_var CLIENT SPECIFIED INTO TABLE lt_zlogs WHERE
    mandt = sy-mandt AND name IN (lc_business_name,lc_subusiness_name)
    AND active = abap_true. IF sy-subrc = 0. SORT : lt_zlogs BY name.
    ENDIF. """"""EOC BY Kalpesh/Shubham 18.11.2025 RD2K9A5E49 ENDIF.

    IF gt_vttk IS NOT INITIAL. SELECT tknum vbeln FROM vttp CLIENT
    SPECIFIED INTO TABLE gt_vttp FOR ALL ENTRIES IN gt_vttk WHERE mandt
    = sy-mandt AND tknum = gt_vttk-tknum. IF sy-subrc EQ 0. SORT gt_vttp
    BY vbeln. ENDIF. ENDIF. \*\*\*BOC For MM Export Destination state
    code gt_vttk_t = gt_vttk. SORT gt_vttk_t BY route. DELETE ADJACENT
    DUPLICATES FROM gt_vttk_t COMPARING route. IF gt_vttk_t IS NOT
    INITIAL. SELECT route abcat knend FROM tvrab INTO TABLE
    gt_mm_exp_tvrab FOR ALL ENTRIES IN gt_vttk_t WHERE route =
    gt_vttk_t-route. IF sy-subrc = 0. SORT gt_mm_exp_tvrab BY route
    abcat DESCENDING. ENDIF. CLEAR gt_vttk_t. ENDIF.

    gt_mm_exp_tvrab_t = gt_mm_exp_tvrab. SORT gt_mm_exp_tvrab_t BY
    knend. DELETE ADJACENT DUPLICATES FROM gt_mm_exp_tvrab_t COMPARING
    knend. IF gt_mm_exp_tvrab_t IS NOT INITIAL. SELECT knote adrnr FROM
    tvkn INTO TABLE gt_mm_exp_tvkn FOR ALL ENTRIES IN gt_mm_exp_tvrab_t
    WHERE knote = gt_mm_exp_tvrab_t-knend. IF sy-subrc = 0. SORT
    gt_mm_exp_tvkn BY knote. ENDIF. CLEAR gt_mm_exp_tvrab_t. ENDIF.

    gt_mm_exp_tvkn_t = gt_mm_exp_tvkn. SORT gt_mm_exp_tvkn_t BY knote.
    DELETE ADJACENT DUPLICATES FROM gt_mm_exp_tvkn_t COMPARING knote. IF
    gt_mm_exp_tvkn_t IS NOT INITIAL. SELECT addrnumber post_code1 region
    FROM adrc INTO TABLE gt_mm_exp_adrc FOR ALL ENTRIES IN
    gt_mm_exp_tvkn_t WHERE addrnumber = gt_mm_exp_tvkn_t-adrnr. IF
    sy-subrc = 0. SORT gt_mm_exp_adrc BY addrnumber. ENDIF. CLEAR
    gt_mm_exp_tvkn_t. ENDIF.

\*\*\*EOC For MM Export Destination state code

IF gt_vttp IS NOT INITIAL. "Fetch shipments from YTTS0002 SELECT area
report_no item_no bukrs dlvry_qty1 desp_uom lr_no lr_dt delivery billno
shnumber FROM yttstx0002 CLIENT SPECIFIED INTO TABLE gt_yttstx0002 FOR
ALL ENTRIES IN gt_vttp"gt_vttk WHERE mandt = sy-mandt \* AND shnumber =
gt_vttk-tknum. AND delivery = gt_vttp-vbeln. IF sy-subrc EQ 0. SORT
gt_yttstx0002 BY report_no . UNASSIGN `<lfs_yttstx0002>`{=html}. LOOP AT
gt_yttstx0002 ASSIGNING `<lfs_yttstx0002>`{=html}. IF
`<lfs_yttstx0002>`{=html} IS ASSIGNED AND
`<lfs_yttstx0002>`{=html}-shnumber IS INITIAL. READ TABLE gt_vttp INTO
gw_vttp WITH KEY vbeln = `<lfs_yttstx0002>`{=html}-delivery BINARY
SEARCH. IF sy-subrc = 0. `<lfs_yttstx0002>`{=html}-shnumber =
gw_vttp-tknum. ENDIF. ENDIF. CLEAR : gw_vttp. ENDLOOP. ENDIF.

    SORT gt_yttstx0002 BY shnumber.

    "( BOC by NUM_005 for Cd-8048948 Tr-RD2K9A32Q3 on 01.10.2020
    lw_trk_purps-sign   = 'I'.
    lw_trk_purps-option = 'EQ'.
    lw_trk_purps-low    = 'D'.
    APPEND lw_trk_purps TO lr_trk_purps.

    CLEAR lw_trk_purps-low.
    lw_trk_purps-low   = 'S'.
    APPEND lw_trk_purps TO lr_trk_purps.
    CLEAR lw_trk_purps.
    " EOC by NUM_005 for Cd-8048948 Tr-RD2K9A32Q3 on 01.10.2020 )

    "Check the TRUCK_PURPOS=D and FUCTION=MGX status for the shipments from YTTS001.
    REFRESH gt_yttstx0002_t.
    gt_yttstx0002_t = gt_yttstx0002.
    SORT gt_yttstx0002_t BY report_no.
    DELETE ADJACENT DUPLICATES FROM gt_yttstx0002_t COMPARING report_no.
    IF gt_yttstx0002_t IS NOT INITIAL.
      SELECT   area
               report_no
               shnumber
               trk_purpos
               pp_entr_dt
               pp_entr_tm
               function
               licno
               mobno
        FROM yttstx0001
        CLIENT SPECIFIED
        INTO TABLE gt_yttstx0001
        FOR ALL ENTRIES IN gt_yttstx0002_t
        WHERE mandt = sy-mandt
        AND   report_no = gt_yttstx0002_t-report_no.
      IF sy-subrc = 0.
        DELETE gt_yttstx0001 WHERE trk_purpos NOT IN lr_trk_purps.     "NE 'D'. "Changed by NUM_005 on 01.10.2020 Fnc-Susheel V
        DELETE gt_yttstx0001 WHERE function NE 'MGX'.
        SORT gt_yttstx0001 BY shnumber.
      ENDIF.
    ENDIF.

    "Consider those shipments which are TRUCK_PURPOS=D and FUCTION=MGX from YTTS0002 table
    REFRESH : gt_yttstx0002, gt_yttstx0001_t.
    gt_yttstx0001_t = gt_yttstx0001.
    SORT gt_yttstx0001_t BY report_no.
    DELETE ADJACENT DUPLICATES FROM gt_yttstx0001_t COMPARING report_no.
    IF gt_yttstx0001_t  IS NOT INITIAL .
      SELECT area
             report_no
             item_no
             bukrs
             dlvry_qty1
             desp_uom
             lr_no
             lr_dt
             delivery
             billno
             shnumber
        FROM yttstx0002 CLIENT SPECIFIED
        INTO TABLE gt_yttstx0002
        FOR ALL ENTRIES IN gt_yttstx0001_t
        WHERE mandt    = sy-mandt
          AND report_no = gt_yttstx0001_t-report_no.
      IF sy-subrc EQ 0.
        DELETE gt_yttstx0002 WHERE delivery IS INITIAL . " Eswara
        SORT gt_yttstx0002 BY report_no.
        UNASSIGN <lfs_yttstx0002>.
        LOOP AT gt_yttstx0002 ASSIGNING <lfs_yttstx0002>.
          IF <lfs_yttstx0002> IS ASSIGNED AND <lfs_yttstx0002>-shnumber IS INITIAL.
            READ TABLE gt_vttp INTO gw_vttp WITH KEY vbeln = <lfs_yttstx0002>-delivery BINARY SEARCH.
            IF sy-subrc = 0.
              <lfs_yttstx0002>-shnumber = gw_vttp-tknum.
            ENDIF.
          ENDIF.
          CLEAR : gw_vttp.
        ENDLOOP.
        SORT gt_yttstx0002 BY shnumber .
      ENDIF.
    ENDIF.

    REFRESH gt_yttstx0002_t.
    gt_yttstx0002_t = gt_yttstx0002.
    SORT gt_yttstx0002_t BY shnumber.
    DELETE ADJACENT DUPLICATES FROM gt_yttstx0002_t COMPARING shnumber.
    IF gt_yttstx0002_t IS NOT INITIAL.
      SELECT tknum
             vbeln
             bill_doc_qty
             lr_no
             lr_dt
             lr_qty
             lr_uom
        FROM ztrstlmnt CLIENT SPECIFIED
        INTO TABLE lt_trstlmn
        FOR ALL ENTRIES IN gt_yttstx0002_t
        WHERE mandt = sy-mandt
          AND tknum = gt_yttstx0002_t-shnumber.
      IF sy-subrc = 0.
        SORT lt_trstlmn BY tknum  vbeln  lr_no lr_dt . " eswara
      ENDIF.
    ENDIF.

    SELECT name
           numb
           shtyp
           active
           remarks
      FROM zlog_exec_var
      INTO TABLE lt_naroda_lr
      WHERE name IN ('ZSCM_NARODA_QWIK_CN',
                     'ZSCM_NRD_CANC_BILLDOC_UPD','ZSCM_COAL_CANCBILL_DEL',
                      lc_naroda_to_push ) "added by omkar more on 24.12.2024 TR:RD2K9A510H
       AND active = abap_true.
    IF sy-subrc = 0.
      SORT lt_naroda_lr BY name shtyp.
    ENDIF.
    "Naroda Scenario
    IF gt_vttk IS NOT INITIAL.
      SELECT tknum
             vbeln
             bill_doc_no
             lr_no
             lr_dt
             lr_qty
             lr_uom
             trans_cn_no
             trans_cn_dt
             trans_lr_qty
             trans_lr_uom

-           CERTIFY
               FROM zsce_cnnt CLIENT SPECIFIED
               INTO TABLE gt_zsce_cnnt
               FOR ALL ENTRIES IN gt_vttk
               WHERE mandt = sy-mandt
               AND tknum = gt_vttk-tknum.
        IF sy-subrc = 0.
          SORT gt_zsce_cnnt BY tknum.

-      LOOP at gt_vttk INTO gw_vttk. "commented By Kalpesh 8069971

-        READ TABLE gt_zsce_cnnt INTO gw_zsce_cnnt WITH KEY tknum = gw_vttk-tknum BINARY SEARCH.

-        IF sy-subrc = 0.

          "soc by omkar more on 24.12.2024 TR:RD2K9A48QI
          CLEAR gt_zsce_cnnt_t[].
          gt_zsce_cnnt_t = gt_zsce_cnnt.
          SORT gt_zsce_cnnt_t BY vbeln.
          DELETE ADJACENT DUPLICATES FROM gt_zsce_cnnt_t COMPARING vbeln.
          IF gt_zsce_cnnt_t[] IS NOT INITIAL.

            CLEAR lt_vbrp_1[].
            SELECT vbeln posnr vgbel
            FROM vbrp CLIENT SPECIFIED
            INTO TABLE lt_vbrp_1
            FOR ALL ENTRIES IN gt_zsce_cnnt_t
            WHERE mandt = sy-mandt
            AND   vgbel = gt_zsce_cnnt_t-vbeln
            %_HINTS ORACLE 'INDEX("VBRP""VBRP~Y01")'.
            IF sy-subrc = 0.


              CLEAR lt_vbrp_1_temp[].
              lt_vbrp_1_temp[] = lt_vbrp_1[].
              SORT lt_vbrp_1_temp BY vbeln.
              DELETE ADJACENT DUPLICATES FROM lt_vbrp_1_temp COMPARING vbeln.
              IF lt_vbrp_1_temp[] IS NOT INITIAL.

                CLEAR lt_vbrk_1[].
                SELECT  vbeln
                fkart
                fksto
                FROM vbrk CLIENT SPECIFIED
                INTO TABLE lt_vbrk_1
                FOR ALL ENTRIES IN lt_vbrp_1_temp
                WHERE mandt  = sy-mandt
                AND   vbeln  = lt_vbrp_1_temp-vbeln
                AND   fksto  = ''
                %_HINTS ORACLE 'INDEX("VBRK""VBRK~Z02")'.
                IF sy-subrc = 0.
                  SORT lt_vbrk_1 BY vbeln.

                  lwr_fkart-sign   = 'I'.
                  lwr_fkart-option = 'EQ'.
                  LOOP AT lt_naroda_lr INTO lw_naroda_lr WHERE name  = lc_naroda_to_push.
                    IF lw_naroda_lr-remarks IS NOT INITIAL.
                      lwr_fkart-low = lw_naroda_lr-remarks+0(4).
                      APPEND lwr_fkart TO ltr_fkart.
                      CLEAR lwr_fkart-low.
                    ENDIF.
                  ENDLOOP.
                  DELETE lt_vbrk_1 WHERE fkart NOT IN ltr_fkart.
                ENDIF.
              ENDIF.
            ENDIF.

-        CLEAR lt_vbrk_1[].

-        SELECT  vbeln

-                fkart

-                fksto

-        FROM vbrk CLIENT SPECIFIED

-        INTO TABLE lt_vbrk_1

-        FOR ALL ENTRIES IN gt_zsce_cnnt_t

-        WHERE mandt  = sy-mandt

-        AND   vbeln  = gt_zsce_cnnt_t-bill_doc_no

-        AND   fksto  = abap_true

-        %_HINTS ORACLE 'INDEX("VBRK""VBRK~Z02")'.

-        IF sy-subrc = 0.

-          SORT lt_vbrk_1 BY vbeln.

-   

-          lwr_fkart-sign   = 'I'.

-          lwr_fkart-option = 'EQ'.

-          LOOP AT lt_naroda_lr INTO lw_naroda_lr WHERE name  = lc_naroda_to_push.

-            IF lw_naroda_lr-remarks IS NOT INITIAL.

-              lwr_fkart-low = lw_naroda_lr-remarks+0(4).

-              APPEND lwr_fkart TO ltr_fkart.

-              CLEAR lwr_fkart-low.

-            ENDIF.

-          ENDLOOP.

-   

-          DELETE lt_vbrk_1 WHERE fkart NOT IN ltr_fkart.

-   

-          CLEAR lt_vbrk_1_temp[].

-          lt_vbrk_1_temp  = lt_vbrk_1.

-          SORT lt_vbrk_1_temp BY vbeln.

-          DELETE ADJACENT DUPLICATES FROM lt_vbrk_1_temp COMPARING vbeln.

-          IF lt_vbrk_1_temp IS NOT INITIAL.

-   

-            CLEAR lt_vbrp_1[].

-            SELECT vbeln posnr vgbel

-            FROM vbrp CLIENT SPECIFIED

-            INTO TABLE lt_vbrp_1

-            FOR ALL ENTRIES IN lt_vbrk_1_temp

-            WHERE mandt = sy-mandt

-            AND   vbeln = lt_vbrk_1_temp-vbeln.

-            IF sy-subrc = 0.

-              SORT lt_vbrp_1 BY vbeln.

-            ENDIF.

-          ENDIF.

-        ENDIF.

          ENDIF.
          SORT lt_vbrp_1 BY vgbel.

          CLEAR gw_zsce_cnnt .
          LOOP AT gt_zsce_cnnt INTO gw_zsce_cnnt. "Added By Kalpesh 27.07.2023 8069971
            CLEAR gw_vttk.
            READ TABLE gt_vttk INTO gw_vttk WITH KEY tknum = gw_zsce_cnnt-tknum.
            IF sy-subrc = 0.
              CLEAR : lw_naroda_lr.
              READ TABLE lt_naroda_lr INTO lw_naroda_lr WITH KEY  name  = 'ZSCM_NARODA_QWIK_CN'
                                                                  shtyp = gw_vttk-shtyp BINARY SEARCH.
              IF sy-subrc = 0.

                CLEAR lw_vbrp_1.
                READ TABLE lt_vbrp_1 INTO lw_vbrp_1 WITH KEY vgbel = gw_zsce_cnnt-vbeln BINARY SEARCH.
                IF sy-subrc = 0.
                  CLEAR lw_vbrk_1.
                  READ TABLE lt_vbrk_1 INTO lw_vbrk_1 WITH KEY vbeln = lw_vbrp_1-vbeln BINARY SEARCH.
                  IF sy-subrc EQ 0.
                    " Relevent Delivery
                    gw_yttstx0002-dlvry_qty1 = gw_zsce_cnnt-lr_qty.
                    gw_yttstx0002-desp_uom   = gw_zsce_cnnt-lr_uom.
                    gw_yttstx0002-lr_no      = gw_zsce_cnnt-lr_no.
                    gw_yttstx0002-lr_dt      = gw_zsce_cnnt-lr_dt.
                    gw_yttstx0002-delivery   = gw_zsce_cnnt-vbeln.
                    gw_yttstx0002-billno     = lw_vbrk_1-vbeln."gw_zsce_cnnt-bill_doc_no.
                    gw_yttstx0002-shnumber   = gw_zsce_cnnt-tknum.
                    APPEND gw_yttstx0002 TO gt_yttstx0002.
                    CLEAR : gw_yttstx0002,gw_zsce_cnnt.
                  ENDIF.
                ELSE. " Valid Delivery
                  gw_yttstx0002-dlvry_qty1 = gw_zsce_cnnt-lr_qty.
                  gw_yttstx0002-desp_uom   = gw_zsce_cnnt-lr_uom.
                  gw_yttstx0002-lr_no      = gw_zsce_cnnt-lr_no.
                  gw_yttstx0002-lr_dt      = gw_zsce_cnnt-lr_dt.
                  gw_yttstx0002-delivery   = gw_zsce_cnnt-vbeln.
                  gw_yttstx0002-billno     = gw_zsce_cnnt-bill_doc_no.
                  gw_yttstx0002-shnumber   = gw_zsce_cnnt-tknum.
                  APPEND gw_yttstx0002 TO gt_yttstx0002.
                  CLEAR : gw_yttstx0002,gw_zsce_cnnt.
                ENDIF.

              ELSE.
                gw_yttstx0002-dlvry_qty1 = gw_zsce_cnnt-trans_lr_qty.
                gw_yttstx0002-desp_uom   = gw_zsce_cnnt-trans_lr_uom.
                gw_yttstx0002-lr_no      = gw_zsce_cnnt-trans_cn_no.
                gw_yttstx0002-lr_dt      = gw_zsce_cnnt-trans_cn_dt.
                gw_yttstx0002-delivery   = gw_zsce_cnnt-vbeln.
                " Added by SN Das CD:8085996(Start)
                CLEAR : lw_naroda_lr.
                READ TABLE lt_naroda_lr INTO lw_naroda_lr WITH KEY  name  = 'ZSCM_NRD_CANC_BILLDOC_UPD'
                                                                    shtyp = gw_vttk-shtyp BINARY SEARCH.
                IF sy-subrc = 0.
                  CLEAR lw_vbrk_1.
                  READ TABLE lt_vbrk_1 INTO lw_vbrk_1 INDEX 1. "  always one billing document
                  IF sy-subrc = 0 AND lw_vbrk_1-vbeln NE gw_zsce_cnnt-bill_doc_no.
                    gw_yttstx0002-billno  = lw_vbrk_1-vbeln.
                  ELSE.
                    gw_yttstx0002-billno  = gw_zsce_cnnt-bill_doc_no.
                  ENDIF.
                ELSE.
                  gw_yttstx0002-billno =  gw_zsce_cnnt-bill_doc_no.
                ENDIF.
                " Added by SN Das CD:8085996(End)
                gw_yttstx0002-shnumber   = gw_zsce_cnnt-tknum.
                APPEND gw_yttstx0002 TO gt_yttstx0002.
                CLEAR : gw_yttstx0002,gw_zsce_cnnt.
              ENDIF.
            ENDIF.
          ENDLOOP.

-        ENDIF.

-      ENDLOOP.

-      LOOP AT gt_zsce_cnnt INTO gw_zsce_cnnt.

-        gw_yttstx0002-dlvry_qty1 = gw_zsce_cnnt-lr_qty.

-        gw_yttstx0002-desp_uom   = gw_zsce_cnnt-lr_uom.

-        gw_yttstx0002-lr_no      = gw_zsce_cnnt-lr_no.

-        gw_yttstx0002-lr_dt      = gw_zsce_cnnt-lr_dt.

-        gw_yttstx0002-delivery   = gw_zsce_cnnt-vbeln.

-        gw_yttstx0002-billno     = gw_zsce_cnnt-bill_doc_no.

-        gw_yttstx0002-shnumber   = gw_zsce_cnnt-tknum.

-        APPEND gw_yttstx0002 TO gt_yttstx0002.

-        CLEAR : gw_yttstx0002,gw_zsce_cnnt.

-      ENDLOOP.
        ENDIF.

        "BOC - by NUM_005 for Cd-8052495 Tr-RD2K9A392T on 25.02.2020
        SELECT area
              report_no
              truck_no
              shnumber
              reject_res
              trk_purpos
              FROM yttstx0001 CLIENT SPECIFIED
              INTO TABLE lt_yttstx0001
              FOR ALL ENTRIES IN gt_vttk
              WHERE mandt      = sy-mandt
              AND   shnumber   = gt_vttk-tknum
              AND   trk_purpos = 'D'.
        IF sy-subrc = 0.
          DELETE lt_yttstx0001 WHERE reject_res NE space.
          SORT lt_yttstx0001 BY shnumber.
        ENDIF.
        "EOC - by NUM_005 for Cd-8052495 Tr-RD2K9A392T on 25.02.2020

    ENDIF. ENDIF. "SOC Suraj Mutha 8071076

    " SOC Husna Basri TR : RD2K9A56L2 Dated : 05/05/2025 CLEAR :
    gt_vttk_t\[\]. gt_vttk_t\[\] = gt_vttk\[\]. SORT gt_vttk_t BY tknum.
    DELETE ADJACENT DUPLICATES FROM gt_vttk_t COMPARING tknum. " EOC
    Husna Basri TR : RD2K9A56L2 Dated : 05/05/2025

-   IF gt_yttstx0002 IS INITIAL. " Commented by Husna Basri

IF gt_vttp IS NOT INITIAL. IF gt_vttk_t\[\] IS NOT INITIAL. SELECT name
shtyp rfcdest FROM zlog_exec_var INTO TABLE lt_zlog_exec_zocc FOR ALL
ENTRIES IN gt_vttk_t WHERE name EQ 'ZSCM_ZOCC_OB_SHTYP' AND shtyp =
gt_vttk_t-shtyp " Added by husna Basri TR : RD2K9A56L2 Dated :
05/05/2025 AND active EQ 'X'. IF sy-subrc EQ 0. SORT lt_zlog_exec_zocc
BY shtyp. ENDIF.

      " Soc by husna Basri TR : RD2K9A56L2 Dated : 06/05/2025
      LOOP AT gt_vttk_t ASSIGNING <lfs_vttk>.
        CLEAR : lw_zlog_exec_zocc.
        READ TABLE  lt_zlog_exec_zocc INTO lw_zlog_exec_zocc WITH KEY shtyp = <lfs_vttk>-shtyp
                                                                      BINARY SEARCH.
        IF sy-subrc <> 0.
          CLEAR : <lfs_vttk>-tknum.
        ENDIF.
      ENDLOOP.
      DELETE gt_vttk_t WHERE tknum IS INITIAL.
    ENDIF.

    CLEAR : gt_vttk_tt[].
    gt_vttk_tt[] = gt_vttk_t[].
    SORT gt_vttk_tt BY tknum.
    DELETE ADJACENT DUPLICATES FROM  gt_vttk_tt COMPARING tknum.
    IF gt_vttk_tt IS NOT INITIAL.
      SELECT tknum
             vbeln
        FROM vttp CLIENT SPECIFIED
        INTO TABLE gt_vttp_tt
        FOR ALL ENTRIES IN gt_vttk_tt
        WHERE mandt = sy-mandt
        AND   tknum = gt_vttk_tt-tknum.
      IF sy-subrc EQ 0.
        SORT gt_vttp_tt BY vbeln.
      ENDIF.
    ENDIF.
    CLEAR :gt_vttp_tt1[].
    gt_vttp_tt1[] = gt_vttp_tt[].
    DELETE ADJACENT DUPLICATES FROM gt_vttp_tt1 COMPARING vbeln.
    " EOC by husna Basri TR : RD2K9A56L2 Dated : 06/05/2025

-   SELECT SINGLE shtyp tplst FROM vttk

-    INTO (lv_shtyp , lv_tplst)

-    WHERE tknum IN i_tknum.  " commented by husna Basri TR : RD2K9A56L2 Dated : 06/05/2025

-   READ TABLE lt_zlog_exec_zocc TRANSPORTING NO FIELDS WITH KEY shtyp =
    lv_shtyp.

-   IF sy-subrc IS NOT INITIAL.

-    RETURN.

-   ELSE. IF gt_vttp_tt IS NOT INITIAL. " Added by Husna SELECT vbeln
    posnr meins ntgew vgbel FROM lips CLIENT SPECIFIED INTO TABLE
    lt_lips_zocc FOR ALL ENTRIES IN gt_vttp_tt1 WHERE mandt = sy-mandt
    AND vbeln = gt_vttp_tt1-vbeln. IF sy-subrc EQ 0. lt_lips_zocc_t\[\]
    = lt_lips_zocc\[\]. SORT lt_lips_zocc_t BY vgbel. DELETE ADJACENT
    DUPLICATES FROM lt_lips_zocc_t COMPARING vgbel. ENDIF. IF
    lt_lips_zocc_t IS NOT INITIAL. SELECT vbeln FROM vbap INTO TABLE
    lt_vbap FOR ALL ENTRIES IN lt_lips_zocc_t WHERE vbeln =
    lt_lips_zocc_t-vgbel. ENDIF.

-    ENDIF.

-   ENDIF. SELECT vbeln vgbel FROM vbrp INTO TABLE lt_vbap_t FOR ALL
    ENTRIES IN gt_vttp_tt1 WHERE vgbel = gt_vttp_tt1-vbeln. IF sy-subrc
    IS INITIAL. SORT lt_vbap_t BY vgbel. ENDIF.

-   Added by SN Das CD:8085996(Start) CLEAR:lr_fkart,lr_fkart\[\]. LOOP
    AT lt_naroda_lr INTO lw_naroda_lr"lt_exec_var WHERE name =
    'ZSCM_COAL_CANCBILL_DEL'."less records CONDENSE lw_naroda_lr-remarks
    NO-GAPS. lr_fkart-sign = 'I'.lr_fkart-option = 'EQ'. lr_fkart-low =
    lw_naroda_lr-remarks.lr_fkart-high = ''. APPEND lr_fkart TO
    lr_fkart. CLEAR:lr_fkart. ENDLOOP.

        lt_vbap_t_1[] = lt_vbap_t[].
        SORT lt_vbap_t_1 BY vbeln.
        DELETE ADJACENT DUPLICATES FROM lt_vbap_t_1 COMPARING vbeln.
        IF NOT lt_vbap_t_1[] IS INITIAL.
          SELECT vbeln
                 fkart
                 fksto
            FROM vbrk INTO TABLE lt_vbrk
            FOR ALL ENTRIES IN lt_vbap_t_1
            WHERE vbeln = lt_vbap_t_1-vbeln.
          IF sy-subrc = 0.
            SORT lt_vbrk BY vbeln.
            DELETE lt_vbrk WHERE fksto = 'X'.
            DELETE lt_vbrk WHERE fkart NOT IN lr_fkart[].
            CLEAR:lr_inv,lr_inv[].
            LOOP AT lt_vbrk INTO lw_vbrk.
              lr_inv-sign = 'I'.lr_inv-option = 'EQ'.
              lr_inv-low = lw_vbrk-vbeln.lr_inv-high = ''.
              APPEND lr_inv TO lr_inv.
              CLEAR:lw_vbrk,lr_inv.
            ENDLOOP.
            DELETE lt_vbap_t WHERE vbeln NOT IN lr_inv[].
          ENDIF.
        ENDIF.

-   Added by SN Das CD:8085996(End) " SOC Husna Basri TR : RD2K9A56L2
    Dated : 05/05/2025 IF gt_vttp_tt1\[\] IS NOT INITIAL.

          SELECT tknum
                 vbeln
                 bill_doc_qty
                 lr_no
                 lr_dt
                 lr_qty
                 lr_uom
              FROM ztrstlmnt CLIENT SPECIFIED
              INTO TABLE lt_trstlmn_zocc
              FOR ALL ENTRIES IN gt_vttp_tt1
              WHERE mandt = sy-mandt

-      AND tknum IN i_tknum.
               AND tknum = gt_vttp_tt1-tknum.  " added by Husna Basri TR : RD2K9A56L2 Dated : 05/05/2025
          IF sy-subrc = 0.
            SORT lt_trstlmn_zocc BY tknum  vbeln  lr_no lr_dt .
            lt_trstlmn_zocc_t[] =  lt_trstlmn_zocc[].
            SORT  lt_trstlmn_zocc_t BY lr_no.
            DELETE ADJACENT DUPLICATES FROM lt_trstlmn_zocc_t COMPARING lr_no.
          ENDIF.
          CLEAR : gt_vttk_t[].
        ENDIF.
        IF lt_trstlmn_zocc_t IS NOT INITIAL.
          SELECT lr_no
            quantity_l
            meins
            FROM zptc_lrpo
            INTO TABLE lt_zptc_lrpo
            FOR ALL ENTRIES IN lt_trstlmn_zocc_t
            WHERE lr_no = lt_trstlmn_zocc_t-lr_no.
          IF sy-subrc IS INITIAL.
            SORT lt_zptc_lrpo BY lr_no.
          ENDIF.
        ENDIF.
        LOOP AT gt_vttp_tt INTO gw_vttp.  " GT_VTTP  commented
          gw_yttstx0002-shnumber = gw_vttp-tknum.
          gw_yttstx0002-delivery = gw_vttp-vbeln.
          " SOC by Husna Basri TR : RD2K9A56L2 Dated : 05/05/2025
          CLEAR : gw_vttk.
          READ TABLE gt_vttk_tt INTO gw_vttk WITH KEY tknum =  gw_vttp-tknum
                                                      BINARY SEARCH.
          IF sy-subrc = 0.
            gw_yttstx0002-bukrs = gw_vttk-tplst.
          ENDIF.

-      gw_yttstx0002-bukrs = lv_tplst.
          " EOC by Husna Basri TR : RD2K9A56L2 Dated : 05/05/2025
          READ TABLE lt_lips_zocc INTO lw_lips_zocc WITH KEY vbeln = gw_vttp-vbeln.
          gw_yttstx0002-dlvry_qty1 = lw_lips_zocc-ntgew.
          gw_yttstx0002-desp_uom = lw_lips_zocc-meins.
          READ TABLE lt_trstlmn_zocc INTO lw_trstlmn_zocc WITH KEY tknum = gw_vttp-tknum.
          gw_yttstx0002-lr_no = lw_trstlmn_zocc-lr_no.
          gw_yttstx0002-lr_dt = lw_trstlmn_zocc-lr_dt.
          READ TABLE lt_vbap_t INTO lw_vbap WITH KEY vgbel = gw_vttp-vbeln.
          gw_yttstx0002-billno = lw_vbap-vbeln.
          APPEND gw_yttstx0002 TO gt_yttstx0002.
          CLEAR :gw_yttstx0002,gw_vttp.
        ENDLOOP.

    ENDIF.

-   ENDIF.

-   ENDIF. ENDIF. "EOC Suraj Mutha 8071076

IF gt_yttstx0002 IS INITIAL. RETURN. ENDIF.

"Fetch Published_Vendor lw_objectid-sign = 'I'. lw_objectid-option =
'EQ'. LOOP AT gt_vttk INTO gw_vttk. lw_objectid-low = gw_vttk-tknum.
APPEND lw_objectid TO lr_objectid. CLEAR : gw_vttk, lw_objectid-low.
ENDLOOP. CLEAR : lw_objectid.

DELETE lr_objectid WHERE low IS INITIAL. SORT lr_objectid BY low. DELETE
ADJACENT DUPLICATES FROM lr_objectid COMPARING low. IF lr_objectid IS
NOT INITIAL. SELECT objectclas objectid tabname fname value_new
value_old FROM cdpos CLIENT SPECIFIED INTO TABLE gt_cdpos \* FOR ALL
ENTRIES IN gt_vttk WHERE mandant = sy-mandt AND objectclas = 'TRANSPORT'
AND objectid IN lr_objectid "gt_vttk-tknum AND tabname = 'VTTK' AND
fname = 'TDLNR'. IF sy-subrc = 0. SORT gt_cdpos BY objectid. ENDIF.
ENDIF.

"Param for GTA applicable SELECT name shtyp lifnr FROM zlog_stlmntvr
CLIENT SPECIFIED INTO TABLE gt_zlog_stlmntvr WHERE mandt = sy-mandt AND
name = gc_gst_vend_rd AND active = abap_true. IF sy-subrc \<\> 0. CLEAR
: gt_zlog_stlmntvr. ENDIF.

"Fetch LIC details gt_yttstx0001_t = gt_yttstx0001. DELETE
gt_yttstx0001_t WHERE licno IS INITIAL. SORT gt_yttstx0001_t BY licno.
DELETE ADJACENT DUPLICATES FROM gt_yttstx0001_t COMPARING licno. IF
gt_yttstx0001_t IS NOT INITIAL. SELECT licno state name vlddt FROM ylicm
CLIENT SPECIFIED INTO TABLE gt_ylicm FOR ALL ENTRIES IN gt_yttstx0001_t
WHERE mandt = sy-mandt AND licno = gt_yttstx0001_t-licno. IF sy-subrc =
0. SORT gt_ylicm BY licno. ENDIF. ENDIF.

"Fetch delivery details REFRESH : gt_yttstx0002_t. gt_yttstx0002_t =
gt_yttstx0002. DELETE gt_yttstx0002_t WHERE shnumber IS INITIAL. SORT
gt_yttstx0002_t BY shnumber. DELETE ADJACENT DUPLICATES FROM
gt_yttstx0002_t COMPARING shnumber. IF gt_yttstx0002_t IS NOT INITIAL.
\* SELECT tknum \* vbeln \* FROM vttp CLIENT SPECIFIED \* INTO TABLE
gt_vttp \* FOR ALL ENTRIES IN gt_yttstx0002_t \* WHERE mandt = sy-mandt
\* AND tknum = gt_yttstx0002_t-shnumber. \* IF sy-subrc EQ 0. \* SORT
gt_vttp BY vbeln. \* ENDIF.

    SELECT shnumber
          ca_date
          ca_time
     FROM zlog_taa CLIENT SPECIFIED
     INTO TABLE gt_zlog_taa
     FOR ALL ENTRIES IN gt_yttstx0002_t
      WHERE mandt    = sy-mandt
        AND shnumber = gt_yttstx0002_t-shnumber.
    IF sy-subrc = 0.
      SORT gt_zlog_taa BY shnumber.
    ENDIF.

ENDIF.

REFRESH : gt_vttk_t. gt_vttk_t = gt_vttk. SORT gt_vttk_t BY route.
DELETE ADJACENT DUPLICATES FROM gt_vttk_t COMPARING route. IF gt_vttk_t
IS NOT INITIAL. SELECT route traztd distz medst tdlnr FROM tvro CLIENT
SPECIFIED INTO TABLE gt_tvro FOR ALL ENTRIES IN gt_vttk_t WHERE mandt =
sy-mandt AND route = gt_vttk_t-route. IF sy-subrc EQ 0. SORT gt_tvro BY
route. ENDIF.

    "Collect VTTK routes to fetch a details from TVRAB
    LOOP AT gt_vttk_t INTO gw_vttk.
      IF gw_vttk-route IS NOT INITIAL.
        lw_route = gw_vttk-route.
        APPEND lw_route TO lt_route.
      ENDIF.
      CLEAR : gw_vttk, lw_route.
    ENDLOOP.

ENDIF.

"BOC by Eswara on 25.03.2021 19:08:09

DATA : lt_zlog_ship_flag TYPE TABLE OF zlog_ship_flag, lw_zlog_ship_flag
TYPE zlog_ship_flag . DATA : lt_zlog_shipfllog TYPE TABLE OF
zlog_shipfllog, lw_zlog_shipfllog TYPE zlog_shipfllog .

REFRESH : gt_vttk_t. gt_vttk_t = gt_vttk. SORT gt_vttk_t BY tknum tdlnr.
IF gt_vttk_t IS NOT INITIAL. SELECT \* FROM zlog_ship_flag INTO TABLE
lt_zlog_ship_flag FOR ALL ENTRIES IN gt_vttk_t WHERE tknum =
gt_vttk_t-tknum . IF sy-subrc IS INITIAL. SORT lt_zlog_ship_flag BY
tknum carrier. ENDIF. ENDIF.

REFRESH : gt_vttk_t. gt_vttk_t = gt_vttk. SORT gt_vttk_t BY tknum . IF
gt_vttk_t IS NOT INITIAL. SELECT \* FROM zlog_shipfllog INTO TABLE
lt_zlog_shipfllog FOR ALL ENTRIES IN gt_vttk_t WHERE tknum =
gt_vttk_t-tknum . IF sy-subrc IS INITIAL. DELETE lt_zlog_shipfllog WHERE
new_status NE 'TF' . SORT lt_zlog_shipfllog BY tknum seqno DESCENDING .
ENDIF. ENDIF.

"BOC by Eswara on 25.03.2021 19:08:09

IF gt_yttstx0002 IS NOT INITIAL. SELECT vbeln route kunnr btgew ntgew
gewei FROM likp CLIENT SPECIFIED INTO TABLE gt_likp FOR ALL ENTRIES IN
gt_yttstx0002 WHERE mandt = sy-mandt AND vbeln = gt_yttstx0002-delivery.
IF sy-subrc = 0. SORT gt_likp BY vbeln. ENDIF. ENDIF.

"Collect LIKP routes to fetch a details from TVRAB LOOP AT gt_likp INTO
gw_likp. IF gw_likp-route IS NOT INITIAL. lw_route = gw_likp-route.
APPEND lw_route TO lt_route. ENDIF. CLEAR : gw_likp, lw_route. ENDLOOP.

"Fetch a details from TVRAB for VTTK & LIKP route lw_sdabw-sign = 'I'.
lw_sdabw-option = 'EQ'. lw_sdabw-low = 'Z001'. APPEND lw_sdabw TO
lr_sdabw. CLEAR lw_sdabw-low. lw_sdabw-low = space. APPEND lw_sdabw TO
lr_sdabw.

IF lt_route IS NOT INITIAL. SELECT route knanf knend sdabw FROM tvrab
CLIENT SPECIFIED INTO TABLE gt_tvrab FOR ALL ENTRIES IN lt_route WHERE
mandt = sy-mandt AND route = lt_route-table_line. \* AND sdabw IN
('Z001',space) . IF sy-subrc = 0. DELETE gt_tvrab WHERE sdabw NOT IN
lr_sdabw. SORT gt_tvrab BY route sdabw. ENDIF. ENDIF.

REFRESH gt_likp_t. gt_likp_t = gt_likp. SORT gt_likp_t BY kunnr. DELETE
ADJACENT DUPLICATES FROM gt_likp_t COMPARING kunnr. IF gt_likp_t IS NOT
INITIAL. SELECT kunnr name1 adrnr FROM kna1 CLIENT SPECIFIED INTO TABLE
gt_kna1 FOR ALL ENTRIES IN gt_likp_t WHERE mandt = sy-mandt AND kunnr =
gt_likp_t-kunnr. IF sy-subrc EQ 0. SORT gt_kna1 BY adrnr. ""Collect
address no from KNA1 to fetch a details from ADRC LOOP AT gt_kna1 INTO
gw_kna1. IF gw_kna1-adrnr IS NOT INITIAL. lw_addrnum-addrnumber =
gw_kna1-adrnr. APPEND lw_addrnum TO lt_addrnum. ENDIF. CLEAR : gw_kna1,
lw_addrnum. ENDLOOP. ENDIF. ENDIF.

IF gt_yttstx0002 IS NOT INITIAL. SELECT vbeln posnr matnr matkl werks
lfimg vrkme arktx vgbel vtweg spart vgtyp mfrgr FROM lips CLIENT
SPECIFIED INTO TABLE gt_lips FOR ALL ENTRIES IN gt_yttstx0002 WHERE
mandt = sy-mandt AND vbeln = gt_yttstx0002-delivery. IF sy-subrc EQ 0.
SORT gt_lips BY vbeln.

      CLEAR gt_lips_t.
      gt_lips_t = gt_lips.
      DELETE gt_lips_t WHERE vgbel IS INITIAL.
      SORT gt_lips_t BY vgbel.   "vbeln.
      DELETE ADJACENT DUPLICATES FROM gt_lips_t COMPARING vgbel.   "vbeln.
      IF gt_lips_t IS NOT INITIAL.
        SELECT vbeln
             bukrs_vf
             zzwerk
        FROM vbak CLIENT SPECIFIED
        INTO TABLE gt_vbak
        FOR ALL ENTRIES IN gt_lips_t
        WHERE mandt = sy-mandt
          AND vbeln = gt_lips_t-vgbel.
        IF sy-subrc = 0.
          SORT gt_vbak BY vbeln.
        ENDIF.

        SELECT  vbeln
                route
                kunnr
                btgew
                ntgew
                gewei
         FROM likp
         CLIENT SPECIFIED
         APPENDING TABLE gt_likp
         FOR ALL ENTRIES IN gt_lips_t
         WHERE mandt = sy-mandt
         AND   vbeln = gt_lips_t-vgbel.
        IF sy-subrc = 0.
          SORT gt_likp BY vbeln.
        ENDIF.

        SELECT ebeln
               bukrs
               lifnr
               reswk
               inco1
          FROM ekko CLIENT SPECIFIED
          INTO TABLE gt_ekko
          FOR ALL ENTRIES IN gt_lips_t
          WHERE mandt = sy-mandt
            AND ebeln = gt_lips_t-vgbel.
        IF sy-subrc = 0.
          SORT gt_ekko BY ebeln.
        ENDIF.

        SELECT ebeln
               ebelp
               werks
          FROM ekpo CLIENT SPECIFIED
          INTO TABLE gt_ekpo
          FOR ALL ENTRIES IN gt_lips_t
          WHERE mandt = sy-mandt
            AND ebeln = gt_lips_t-vgbel.
        IF sy-subrc = 0.
          SORT gt_ekpo BY ebeln.
        ENDIF.

        SELECT  vbeln
                posnr
                parvw
                kunnr
                parnr
                FROM vbpa CLIENT SPECIFIED
                INTO TABLE gt_vbpa
                FOR ALL ENTRIES IN gt_lips_t
                WHERE mandt = sy-mandt
                AND vbeln = gt_lips_t-vgbel
                AND  parvw IN lr_parvw[]."(gc_ac,gc_ap).
        IF sy-subrc = 0.
          SORT gt_vbpa BY vbeln parvw.
        ENDIF.

      ENDIF.
    ENDIF.

    " SOC Husna Basri TR : RD2K9A52Y6 Dated : 07/02/2025

    CLEAR: gt_lips_t[].
    gt_lips_t[] = gt_lips[].
    SORT gt_lips_t BY vbeln.
    DELETE ADJACENT DUPLICATES FROM gt_lips_t COMPARING vbeln.
    CLEAR : lt_likp[].
    IF gt_lips_t[] IS NOT INITIAL.
      SELECT vbeln
             anzpk
             FROM likp CLIENT SPECIFIED
             INTO TABLE lt_likp
             FOR ALL ENTRIES IN gt_lips_t
             WHERE mandt = sy-mandt
             AND   vbeln = gt_lips_t-vbeln.
      IF sy-subrc = 0.
        SORT lt_likp BY vbeln.
      ENDIF.
    ENDIF.
    " EOC Husna Basri TR : RD2K9A52Y6 Dated : 07/02/2025

    REFRESH  gt_lips_t.
    gt_lips_t = gt_lips.
    SORT gt_lips_t BY werks.
    DELETE ADJACENT DUPLICATES FROM gt_lips_t COMPARING werks.
    IF gt_lips_t IS NOT INITIAL.
      SELECT werks
             name1
             adrnr
        FROM t001w  CLIENT SPECIFIED
        INTO TABLE gt_t001w
        FOR ALL ENTRIES IN gt_lips_t
        WHERE mandt = sy-mandt
        AND   werks = gt_lips_t-werks.
      IF sy-subrc = 0.
        SORT gt_t001w BY werks.
        ""Collection address no from T001W to fetch a details from ADRC
        LOOP AT gt_t001w INTO gw_t001w.
          IF gw_t001w-adrnr IS NOT INITIAL.
            lw_addrnum-addrnumber = gw_t001w-adrnr.
            APPEND lw_addrnum TO lt_addrnum.
          ENDIF.
          CLEAR : gw_t001w, lw_addrnum.
        ENDLOOP.
      ENDIF.
    ENDIF.

    "BOC - by NUM_005 for Cd-8052495 Tr-RD2K9A392T on 25.02.2020
    REFRESH  gt_lips_t.
    gt_lips_t = gt_lips.
    SORT gt_lips_t BY matnr werks.
    DELETE ADJACENT DUPLICATES FROM gt_lips_t COMPARING matnr werks.
    IF gt_lips_t IS NOT INITIAL.
      SELECT matnr
             werks
             mfrgr
             FROM marc CLIENT SPECIFIED
             INTO TABLE lt_marc
             FOR ALL ENTRIES IN gt_lips_t
             WHERE mandt = sy-mandt
             AND   matnr = gt_lips_t-matnr
             AND   werks = gt_lips_t-werks.
      IF sy-subrc = 0.
        SORT lt_marc BY matnr werks.
      ENDIF.
    ENDIF.
    REFRESH  gt_lips_t.
    "EOC - by NUM_005 for Cd-8052495 Tr-RD2K9A392T on 25.02.2020

ENDIF.

SORT lt_addrnum BY addrnumber. DELETE ADJACENT DUPLICATES FROM
lt_addrnum COMPARING addrnumber. IF lt_addrnum IS NOT INITIAL. SELECT
addrnumber post_code1 transpzone region FROM adrc CLIENT SPECIFIED INTO
TABLE gt_adrc FOR ALL ENTRIES IN lt_addrnum WHERE client = sy-mandt AND
addrnumber = lt_addrnum-addrnumber. IF sy-subrc IS INITIAL. SORT gt_adrc
BY addrnumber. ENDIF. ENDIF. "BOC by Eswara on 25.08.2020 15:27:00"
collecting bill no records from ytts2 table

lw_billno-sign = 'I'. lw_billno-option = 'EQ'. LOOP AT gt_yttstx0002
INTO gw_yttstx0002. lw_billno-low = gw_yttstx0002-billno . APPEND
lw_billno TO lr_billno . CLEAR : lw_billno-low. ENDLOOP.

"BOC by Eswara on 25.08.2020 15:27:00 REFRESH gt_vttp_t. gt_vttp_t =
gt_vttp. SORT gt_vttp_t BY vbeln. DELETE gt_vttp_t WHERE vbeln IS
INITIAL. DELETE ADJACENT DUPLICATES FROM gt_vttp_t COMPARING vbeln. IF
gt_vttp_t IS NOT INITIAL. SELECT vbelv vbeln erdat FROM vbfa CLIENT
SPECIFIED INTO TABLE gt_vbfa FOR ALL ENTRIES IN gt_vttp_t WHERE mandt =
sy-mandt AND vbelv = gt_vttp_t-vbeln AND vbtyp_n IN ('M','U'). IF
sy-subrc = 0. SORT gt_vbfa BY vbelv."ASCENDING erdat DESCENDING. \*
DELETE ADJACENT DUPLICATES FROM gt_vbfa COMPARING vbelv. CLEAR
gt_vbfa_t. DELETE gt_vbfa WHERE vbeln NOT IN lr_billno . " eswara
gt_vbfa_t = gt_vbfa. SORT gt_vbfa_t BY vbeln. DELETE gt_vbfa_t WHERE
vbeln IS INITIAL. DELETE ADJACENT DUPLICATES FROM gt_vbfa_t COMPARING
vbeln. IF gt_vbfa_t IS NOT INITIAL. SELECT vbeln waerk fkdat inco1 kurrf
netwr kunag " eswara spart fksto FROM vbrk CLIENT SPECIFIED INTO TABLE
gt_vbrk FOR ALL ENTRIES IN gt_vbfa_t WHERE mandt = sy-mandt AND vbeln =
gt_vbfa_t-vbeln. IF sy-subrc = 0. SORT gt_vbrk BY vbeln. DELETE gt_vbrk
WHERE fksto EQ 'X'. IF sy-subrc = 0.

          ENDIF.
          IF gt_vbrk IS NOT INITIAL.
            SELECT  vbeln
                    posnr
                    fkimg
                    vrkme
                    netwr
                    vgbel
                    matnr
                    arktx
                   FROM vbrp CLIENT SPECIFIED
                   INTO TABLE gt_vbrp
                   FOR ALL ENTRIES IN  gt_vbrk
                   WHERE mandt = sy-mandt
                   AND   vbeln =  gt_vbrk-vbeln.
            IF sy-subrc = 0.
              SORT gt_vbrp BY vbeln.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      CLEAR gt_vbfa_t.
      gt_vbfa_t = gt_vbfa.
      LOOP AT gt_vbfa INTO gw_vbfa.
        READ TABLE gt_vbrk INTO gw_vbrk WITH KEY vbeln = gw_vbfa-vbeln BINARY SEARCH.
        IF sy-subrc NE 0.
          DELETE gt_vbfa_t WHERE vbeln = gw_vbfa-vbeln.
        ENDIF.
      ENDLOOP.
      gt_vbfa = gt_vbfa_t.

***BOC BY ARPIT H. PATEL
RD2K9A3LFF***\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*
IF gt_vbrk IS NOT INITIAL. SELECT vbeln billno zfcplbill fksto fkart
FROM zfcplbill INTO TABLE lt_zfcplbill FOR ALL ENTRIES IN gt_vbrk WHERE
billno = gt_vbrk-vbeln. IF lt_zfcplbill IS NOT INITIAL . SORT
lt_zfcplbill BY vbeln billno. DELETE lt_zfcplbill WHERE fksto IS NOT
INITIAL. DELETE lt_zfcplbill WHERE fkart NE 'Z509'. SORT lt_zfcplbill BY
billno. LOOP AT lt_zfcplbill INTO lw_zfcplbill. lw_bill_no-billno =
lw_zfcplbill-zfcplbill. APPEND lw_bill_no TO lt_bill_no. CLEAR :
lw_bill_no, lw_zfcplbill. ENDLOOP. ENDIF. IF lt_bill_no IS NOT INITIAL.
"Class & method to fetch RFC details for RP5 related server and clients
CALL METHOD zcl_log_fcpl=\>fcpl_rfc_dest IMPORTING ex_rfc_dest =
lw_dest. IF lw_dest IS NOT INITIAL. CALL FUNCTION
'Z_SCE_QWIK_IL_FRTINV_VAL' DESTINATION lw_dest EXPORTING it_bill_no =
lt_bill_no IMPORTING et_frtinv_val = lt_frtinv_val EXCEPTIONS
system_failure = 1 communication_failure = 2 no_data_found = 3 OTHERS =
4. IF sy-subrc = 0. SORT lt_frtinv_val BY zfcplbill. ENDIF. ENDIF.
ENDIF. ENDIF. ***EOC BY ARPIT H. PATEL
RD2K9A3LFF***\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*
\*\*\* IF gt_vbfa_t IS NOT INITIAL. \*\*\* SELECT vbeln \*\*\* posnr
\*\*\* fkimg \*\*\* vrkme \*\*\* netwr \*\*\* vgbel \*\*\* matnr \*\*\*
arktx \*\*\* FROM vbrp CLIENT SPECIFIED \*\*\* INTO TABLE gt_vbrp \*\*\*
FOR ALL ENTRIES IN gt_vbfa_t \*\*\* WHERE mandt = sy-mandt \*\*\* AND
vbeln = gt_vbfa_t-vbeln. \*\*\* IF sy-subrc = 0. \*\*\*\* DELETE gt_vbrp
WHERE fkimg = 0. \*\*\* SORT gt_vbrp BY vbeln. \*\*\* DELETE ADJACENT
DUPLICATES FROM gt_vbrp COMPARING vbeln. \*\*\* CLEAR gt_vbrp_t. \*\*\*
gt_vbrp_t = gt_vbrp. \*\*\* DELETE gt_vbrp_t WHERE vbeln IS INITIAL.
\*\*\* DELETE ADJACENT DUPLICATES FROM gt_vbrp_t COMPARING vbeln. \*\*\*
IF gt_vbrp_t IS NOT INITIAL. \*\*\* SELECT vbeln \*\*\* waerk \*\*\*
fkdat \*\*\* inco1 \*\*\* kurrf \*\*\* netwr \*\*\* spart \*\*\* fksto
\*\*\* FROM vbrk CLIENT SPECIFIED \*\*\* INTO TABLE gt_vbrk \*\*\* FOR
ALL ENTRIES IN gt_vbrp_t \*\*\* WHERE mandt = sy-mandt \*\*\* AND vbeln
= gt_vbrp_t-vbeln. \*\*\* IF sy-subrc EQ 0. \*\*\* DELETE gt_vbrk WHERE
fksto NE space. \*\*\* SORT gt_vbrk BY vbeln. \*\*\* DELETE ADJACENT
DUPLICATES FROM gt_vbrk COMPARING vbeln. \*\*\* ENDIF. \*\*\* ENDIF.
\*\*\* CLEAR gt_vbrp_t. \*\*\* ENDIF. \*\*\* ENDIF. ENDIF. ENDIF.

"added on 19.05.2020 (To get QWIK vehicle type) LOOP AT gt_vttk INTO
gw_vttk. lw_truckno-tknum = gw_vttk-tknum. lw_truckno-truck_no =
gw_vttk-signi. APPEND lw_truckno TO lt_truckno.

    IF gw_vttk-add02 IS NOT INITIAL.
      lw_add02 = gw_vttk-add02.
      APPEND lw_add02 TO lt_add02.
    ENDIF.

    lw_vpobjkey-vpobjkey = gw_vttk-tknum.
    APPEND lw_vpobjkey TO lt_vpobjkey.

    CLEAR : lw_add02, lw_add02, lw_vpobjkey.

ENDLOOP.

SORT lt_add02. DELETE ADJACENT DUPLICATES FROM lt_add02 COMPARING ALL
FIELDS. IF lt_add02 IS NOT INITIAL. SELECT qwik_vehi_type FROM
zscm_qwik_vehtyp CLIENT SPECIFIED INTO TABLE lt_qwik_vehtyp FOR ALL
ENTRIES IN lt_add02 WHERE mandt = sy-mandt AND qwik_vehi_type =
lt_add02-table_line. IF sy-subrc = 0. SORT lt_qwik_vehtyp BY
qwik_vehi_type. ENDIF. ENDIF.

CALL FUNCTION 'Z_SCM_GET_OB_QWIKVEH' EXPORTING it_truckno = lt_truckno
IMPORTING et_return = lt_return et_vehtyp = lt_vehtype.

\*\*\* IF lt_vehtype IS INITIAL. \*\*\* CLEAR:lt_truckno_tmp. \*\*\*
lt_truckno_tmp = lt_truckno. \*\*\* SORT lt_truckno_tmp BY truck_no.
\*\*\* DELETE lt_truckno_tmp WHERE truck_no IS INITIAL. \*\*\* DELETE
ADJACENT DUPLICATES FROM lt_truckno_tmp COMPARING truck_no. \*\*\* IF
lt_truckno_tmp IS NOT INITIAL. \*\*\* SELECT truck_no \*\*\*
qwik_vehi_type \*\*\* INTO TABLE lt_vehtype \*\*\* FROM zscm_trk_mstr
CLIENT SPECIFIED \*\*\* FOR ALL ENTRIES IN lt_truckno_tmp \*\*\* WHERE
mandt = sy-mandt \*\*\* AND truck_no = lt_truckno_tmp-truck_no. \*\*\*
IF sy-subrc = 0. \*\*\* SORT lt_vehtype BY truck_no. \*\*\* ENDIF.
\*\*\* ENDIF. \*\*\* ENDIF. \* CALL FUNCTION 'Z_SCM_GET_QWIKVEH' \*
EXPORTING \* it_truckno = lt_truckno \* IMPORTING \* et_return =
lt_return \* et_vehtyp = lt_vehtype. SORT lt_vehtype BY truck_no. "end
on 19.05.2020

"(BOC - by NUM_005 for CD-8050371 Tr-RD2K9A3708 IF lt_vpobjkey IS NOT
INITIAL. SELECT venum vhilm vhart vpobj vpobjkey status FROM vekp CLIENT
SPECIFIED INTO TABLE lt_vekp FOR ALL ENTRIES IN lt_vpobjkey WHERE mandt
= sy-mandt AND vhart = 'Z001' AND vpobj = '04' AND vpobjkey =
lt_vpobjkey-vpobjkey. IF sy-subrc = 0. DELETE lt_vekp WHERE status EQ
'0060'. SORT lt_vekp BY vpobjkey. ENDIF.

    lt_vekp_t[] = lt_vekp[].
    SORT lt_vekp_t BY vhilm.
    DELETE ADJACENT DUPLICATES FROM lt_vekp_t COMPARING vhilm.
    IF lt_vekp_t IS NOT INITIAL.
      SELECT matnr
             matkl
        FROM mara CLIENT SPECIFIED
        INTO TABLE lt_mara
        FOR ALL ENTRIES IN lt_vekp_t
        WHERE mandt = sy-mandt
        AND   matnr = lt_vekp_t-vhilm.
      IF sy-subrc = 0.
        SORT lt_mara BY matnr.
      ENDIF.
    ENDIF.
    REFRESH lt_vekp_t.

ENDIF. "EOC - by NUM_005 for CD-8050371 Tr-RD2K9A3708 )

"BOC ESWARA LOOP AT gt_vttk INTO gw_vttk. lw_shipment_det-tknum =
gw_vttk-tknum. lw_shipment_det-cn_date = gw_vttk-datbg.
lw_shipment_det-tdlnr = gw_vttk-tdlnr. APPEND lw_shipment_det TO
lt_shipment_det. CLEAR lw_shipment_det. ENDLOOP. IF lt_shipment_det IS
NOT INITIAL. CALL FUNCTION 'Z_EFR_PROD_CAT' EXPORTING it_shipment_det =
lt_shipment_det IMPORTING et_shipmentoprd_cat = lt_shipmentoprd_cat. IF
lt_shipmentoprd_cat\[\] IS NOT INITIAL. SORT lt_shipmentoprd_cat BY
tknum cn_date."Added 04.01.2021 Vandan 8059020 ENDIF. ENDIF. " SOC Husna
Basri TR : Dated : 14/11/2024 CLEAR : lw_zlog_exec. SELECT mandt name
active FROM zlog_exec_var CLIENT SPECIFIED INTO lw_zlog_exec UP TO 1
ROWS WHERE mandt = sy-mandt AND name = 'Z_SCM_GET_BUSINESS' AND active =
'X'. ENDSELECT. IF sy-subrc = 0. lv_bussid_flg = 'X'. ELSE. CLEAR :
lv_bussid_flg. ENDIF. " EOC Husna Basri TR : Dated : 14/11/2024 "EOC
ESWARA

"----\>Header data processing SORT gt_kna1 BY kunnr. SORT gt_yttstx0001
BY report_no. SORT gt_yttstx0002 BY shnumber ." eswara SORT gt_vttp BY
tknum. \* Added by SN Das CD:8079928(Start) CLEAR :
lw_subusiness_id,lt_sub_business\[\]. SELECT name numb active remarks
spart FROM zlog_exec_var INTO TABLE lt_sub_business WHERE ( name =
lc_business OR name = lc_subbusiness ) AND active = 'X'. IF sy-subrc =
0. SORT : lt_sub_business BY name remarks. ENDIF. \* Added by SN Das
CD:8079928(End) LOOP AT gt_vttk INTO gw_vttk. \*
gw_order_header_data-business_id = 'RIL'. READ TABLE gt_zlog_exec_var
INTO gw_zlog_exec_var WITH KEY name = gc_business_id. "Binary search not
required IF sy-subrc = 0. gw_order_header_data-business_id =
gw_zlog_exec_var-remarks. ENDIF. gw_order_header_data-shipment_date =
gw_vttk-erdat. CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT' EXPORTING
input = gw_vttk-tknum IMPORTING output = lw_tknum.
gw_order_header_data-shipment_no = lw_tknum.
gw_order_header_data-shipment_status = '01'.
gw_order_header_data-vehicle_number = gw_vttk-signi.
gw_order_header_data-route_id = gw_vttk-route.

    lw_add02 = gw_vttk-add02.
    READ TABLE lt_qwik_vehtyp INTO lw_qwik_vehtyp WITH KEY qwik_vehi_type = lw_add02 BINARY SEARCH.
    IF sy-subrc = 0.
      gw_order_header_data-vehicle_type = gw_vttk-add02.
    ELSE.
      READ TABLE lt_vehtype INTO lw_vehtype WITH KEY truck_no = gw_vttk-signi BINARY SEARCH.
      IF sy-subrc = 0.
        gw_order_header_data-vehicle_type                          =  lw_vehtype-veh_typ.
      ENDIF.
    ENDIF.

    IF gw_vttk-signi IS NOT INITIAL.
      gw_order_header_data-container_id                             =  gw_vttk-signi .
    ELSE.
      READ TABLE lt_yttstx0001 INTO lw_yttstx0001 WITH KEY shnumber = gw_vttk-tknum BINARY SEARCH.
      IF sy-subrc = 0.
        gw_order_header_data-container_id = lw_yttstx0001-truck_no.
      ENDIF.
    ENDIF.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = gw_vttk-tdlnr
      IMPORTING
        output = lw_tdlnr.
    gw_order_header_data-vendor_code                              =  lw_tdlnr .
    gw_order_header_data-planned_vehicle_placement_date           =  gw_vttk-dplbg .
    gw_order_header_data-planned_vehicle_placement_time           =  gw_vttk-uplbg .
    gw_order_header_data-actual_date_of_checkin                   =  gw_vttk-dareg .
    gw_order_header_data-actual_time_of_checkin                   =  gw_vttk-uareg .
    gw_order_header_data-shipment_start_date                      =  gw_vttk-datbg.
    gw_order_header_data-shipment_start_time                      =  gw_vttk-uatbg.
    gw_order_header_data-transport_mode                           =  gw_vttk-vsart.
    gw_order_header_data-attendance_applicable                    =  'N'.

    IF gw_vttk-zzres_des IS NOT INITIAL.
      SPLIT gw_vttk-zzres_des AT '-' INTO lw_rcode lw_rdesc.
      CONDENSE : lw_rcode, lw_rdesc.
      gw_order_header_data-vendor_change_reason_code   = lw_rcode.  "gw_vttk-zzres_des.

-    gw_order_header_data-vendor_change_reason_descr  = lw_rdesc.  "gw_vttk-zzres_des.

    ENDIF.

-   READ TABLE gt_cdpos INTO gw_cdpos WITH KEY objectid = gw_vttk-tknum
    BINARY SEARCH.

-   IF sy-subrc = 0 AND gw_vttk-tdlnr \<\> gw_cdpos-value_old.

-    gw_order_header_data-published_vendor = gw_cdpos-value_old.

-   ENDIF. "BOC by Eswara on 25.03.2021 19:21:20

```{=html}
<!-- -->
```
    READ TABLE lt_zlog_ship_flag INTO lw_zlog_ship_flag WITH KEY tknum = gw_vttk-tknum
                                                                carrier = gw_vttk-tdlnr BINARY SEARCH .
    IF sy-subrc IS INITIAL AND lw_zlog_ship_flag-executable = 'EXE'.
      READ TABLE lt_zlog_shipfllog INTO lw_zlog_shipfllog WITH KEY tknum = gw_vttk-tknum .
      IF sy-subrc IS INITIAL AND lw_zlog_shipfllog-new_status = 'TF'.
        gw_order_header_data-published_date = lw_zlog_ship_flag-svpt_date.
        gw_order_header_data-published_time = lw_zlog_ship_flag-svpt_time.

      ENDIF.
    ENDIF.
    LOOP AT lt_zlog_ship_flag INTO lw_zlog_ship_flag WHERE  tknum = gw_vttk-tknum AND
                                                             carrier NE gw_vttk-tdlnr .
      IF sy-subrc IS INITIAL AND lw_zlog_ship_flag-executable = 'EXE'.
        gw_order_header_data-published_vendor = lw_zlog_ship_flag-carrier.
        SHIFT gw_order_header_data-published_vendor LEFT DELETING LEADING '0'.
        EXIT .
      ENDIF.
    ENDLOOP.


    IF  gw_order_header_data-published_date IS INITIAL AND
         gw_order_header_data-published_time IS  INITIAL.
      "BOC  by Eswara on 25.03.2021 19:21:20
      READ TABLE gt_zlog_taa INTO gw_zlog_taa WITH KEY shnumber = gw_vttk-tknum BINARY SEARCH.
      IF sy-subrc = 0.
        gw_order_header_data-published_date = gw_zlog_taa-ca_date.
        gw_order_header_data-published_time = gw_zlog_taa-ca_time.
      ENDIF.

    ENDIF.  " eswara


    gw_order_header_data-movt_dir    = 'O'.

    READ TABLE gt_tvro INTO gw_tvro WITH KEY route = gw_vttk-route BINARY SEARCH.
    IF sy-subrc = 0.
      gw_order_header_data-route_distance     = gw_tvro-distz.
      gw_order_header_data-route_distance_uom = gw_tvro-medst.

      CALL FUNCTION 'CONVERSION_EXIT_TSTRG_OUTPUT'
        EXPORTING
          input  = gw_tvro-traztd
        IMPORTING
          output = lw_tran_dur.

      gw_order_header_data-transit_dur_days = lw_tran_dur.
    ENDIF.

    READ TABLE gt_tvrab INTO gw_tvrab WITH KEY route = gw_vttk-route sdabw = space BINARY SEARCH.
    IF sy-subrc = 0.
      gw_order_header_data-source_location      = gw_tvrab-knanf.
      gw_order_header_data-destination_location = gw_tvrab-knend.
    ELSE.                                             "BOC Gagan/Arya 24/04/2024 RD2K9A4PZF
      CALL FUNCTION 'Z_SCM_SOURCE_DESTDTLS_GET'
        EXPORTING
          im_tknum = gw_order_header_data-shipment_no
        IMPORTING
          em_knanf = lv_knanf
          em_knend = lv_knend.
      gw_order_header_data-source_location      = lv_knanf.
      gw_order_header_data-destination_location = lv_knend.
    ENDIF.                                         "EOC Gagan/Arya 24/04/2024 RD2K9A4PZF

    READ TABLE gt_yttstx0002 INTO gw_yttstx0002 WITH KEY shnumber = gw_vttk-tknum BINARY SEARCH.
    IF sy-subrc EQ 0.
      READ TABLE gt_lips INTO gw_lips WITH KEY vbeln = gw_yttstx0002-delivery BINARY SEARCH.
      IF sy-subrc = 0.
        IF gw_lips-vgtyp = 'C'.
          gw_order_header_data-cpod_applicable = 'A'.
        ELSE.
          gw_order_header_data-cpod_applicable = 'N'.
        ENDIF.
        READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_business spart = gw_lips-spart  zzpmatkl1 = gw_lips-matkl.
        IF sy-subrc = 0.
          gw_order_header_data-subusiness_id     = gw_zlog_exec_var-remarks.
        ELSE.
          READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_business spart = gw_lips-spart .    ""Binary Sear not Required
          IF sy-subrc IS INITIAL.
            gw_order_header_data-subusiness_id     = gw_zlog_exec_var-remarks.
          ENDIF.
        ENDIF.

        CLEAR gw_zlog_exec_var.
        READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_product_cat shtyp = gw_vttk-shtyp.
        IF sy-subrc = 0.
          gw_order_header_data-subusiness_id = gw_zlog_exec_var-rfcdest.
        ENDIF.

        READ TABLE gt_t001w INTO gw_t001w WITH KEY werks = gw_lips-werks BINARY SEARCH.
        IF sy-subrc EQ 0.
          READ TABLE gt_adrc INTO gw_adrc WITH KEY addrnumber = gw_t001w-adrnr BINARY SEARCH.
          IF sy-subrc = 0.
            gw_order_header_data-source_postalcode = gw_adrc-post_code1.
            gw_order_header_data-source_statecode  = gw_adrc-region.
          ENDIF.
        ENDIF.
      ENDIF.

      CLEAR : gw_adrc.
      READ TABLE gt_likp INTO gw_likp WITH KEY route = gw_vttk-route.       "BINARY SEARCH not required
      IF sy-subrc IS INITIAL.
        READ TABLE gt_kna1 INTO gw_kna1 WITH KEY  kunnr = gw_likp-kunnr BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          CLEAR : gw_adrc.
          READ TABLE gt_adrc INTO gw_adrc WITH KEY addrnumber = gw_kna1-adrnr BINARY SEARCH.
          IF sy-subrc = 0.
            gw_order_header_data-destination_postalcode = gw_adrc-post_code1.
            gw_order_header_data-destination_statecode  = gw_adrc-region.
          ENDIF.
        ENDIF.
      ELSE.
        READ TABLE gt_vttp INTO gw_vttp WITH KEY tknum = gw_vttk-tknum BINARY SEARCH.
        IF sy-subrc = 0.
          READ TABLE gt_likp INTO gw_likp WITH KEY vbeln = gw_vttp-vbeln BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            READ TABLE gt_kna1 INTO gw_kna1 WITH KEY  kunnr = gw_likp-kunnr BINARY SEARCH.
            IF sy-subrc IS INITIAL.
              CLEAR gw_adrc.
              READ TABLE gt_adrc INTO gw_adrc WITH KEY addrnumber = gw_kna1-adrnr BINARY SEARCH.
              IF sy-subrc = 0.
                gw_order_header_data-destination_postalcode = gw_adrc-post_code1.
                gw_order_header_data-destination_statecode  = gw_adrc-region.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.


      READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_zscm_export_road_shtyp
                                                                 shtyp = gw_vttk-shtyp.
      IF sy-subrc = 0.
        READ TABLE gt_mm_exp_tvrab INTO gw_mm_exp_tvrab WITH KEY route = gw_vttk-route BINARY SEARCH.
        IF sy-subrc = 0.
          READ TABLE gt_mm_exp_tvkn INTO gw_mm_exp_tvkn WITH KEY knote = gw_mm_exp_tvrab-knend BINARY SEARCH.
          IF sy-subrc = 0.
            READ TABLE gt_mm_exp_adrc INTO gw_mm_exp_adrc WITH KEY addrnumber = gw_mm_exp_tvkn-adrnr BINARY SEARCH.
            IF sy-subrc = 0.
              gw_order_header_data-destination_postalcode = gw_mm_exp_adrc-post_code1.
              gw_order_header_data-destination_statecode  = gw_mm_exp_adrc-region.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      READ TABLE gt_yttstx0001 INTO gw_yttstx0001 WITH KEY report_no = gw_yttstx0002-report_no BINARY SEARCH.
      IF sy-subrc EQ 0.
        gw_order_header_data-licence_no1 = gw_yttstx0001-licno.
        gw_order_header_data-actual_placement_date = gw_yttstx0001-pp_entr_dt.
        gw_order_header_data-actual_placement_time = gw_yttstx0001-pp_entr_tm.
        gw_order_header_data-driver_mob_no1 = gw_yttstx0001-mobno.
        READ TABLE gt_ylicm INTO gw_ylicm WITH KEY licno = gw_yttstx0001-licno BINARY SEARCH.
        IF sy-subrc EQ 0.
          gw_order_header_data-expiry_date1           = gw_ylicm-vlddt.
          gw_order_header_data-licence_issuing_state1 = gw_ylicm-state.
          gw_order_header_data-driver_name1           = gw_ylicm-name.
        ENDIF.
      ENDIF.

      READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_trans_movt.
      IF sy-subrc = 0.
        gw_order_header_data-trans_movt    = gw_zlog_exec_var-remarks.
      ENDIF.

-    BREAK-POINT.
        " Soc Husna Basri TR : RD2K9A4Z4J Dated : 13/11/2024
        IF lv_bussid_flg = 'X'.
          CLEAR : lw_tknum2,lt_tknum.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = gw_order_header_data-shipment_no
            IMPORTING
              output = lw_tknum2-tknum.

          APPEND lw_tknum2 TO lt_tknum.
          CLEAR : lw_tknum2,lt_bus_details.

          CALL FUNCTION 'Z_SCM_GET_BUSINESS'
            EXPORTING
              it_tknum       = lt_tknum
            IMPORTING
              et_bus_details = lt_bus_details.

          IF lt_bus_details IS NOT INITIAL.
            CLEAR : lw_bus_details .
            READ TABLE lt_bus_details INTO lw_bus_details INDEX 1.
            IF sy-subrc = 0 .
              gw_order_header_data-business_id = lw_bus_details-business_id.

-   Added by SN Das CD:8079928(Start) READ TABLE lt_sub_business INTO
    lw_sub_business WITH KEY name = 'ZSCM_GET_RPL_BUS'. IF sy-subrc = 0
    AND ( lw_sub_business-remarks = lw_bus_details-business_id ). READ
    TABLE gt_vttp INTO gw_vttp WITH KEY tknum = gw_vttk-tknum. IF
    sy-subrc = 0. READ TABLE gt_lips INTO gw_lips WITH KEY vbeln =
    gw_vttp-vbeln. IF sy-subrc = 0. CLEAR : lw_sub_business. READ TABLE
    lt_sub_business INTO lw_sub_business WITH KEY name =
    'ZSCM_GET_RPL_SUB' spart = gw_lips-spart. IF sy-subrc = 0.
    lw_subusiness_id = gw_order_header_data-subusiness_id =
    lw_sub_business-remarks. ENDIF. ENDIF. ENDIF. ENDIF.

-   Added by SN Das CD:8079928(End) ENDIF. ENDIF. ENDIF. " Eoc Husna
    Basri TR : RD2K9A4Z4J Dated : 13/11/2024

        ""BOC By Kalpesh/Shubham 18.11.2025 RD2K9A5E49
        CLEAR : lw_ttds.
        READ TABLE lt_ttds INTO lw_ttds WITH KEY tplst = gw_vttk-tplst BINARY SEARCH.
        IF sy-subrc = 0.
          CLEAR : lw_zlogs.
          READ TABLE lt_zlogs INTO lw_zlogs WITH KEY name  = lc_business_name
                                                   bukrs = lw_ttds-bukrs. "Binary search not needed less records
          IF sy-subrc = 0.
            CLEAR : lw_zlogs1.
            READ TABLE lt_zlogs INTO lw_zlogs1 WITH KEY name = lc_subusiness_name
                                                   remarks = lw_zlogs-remarks."Binary search not needed less records
            IF sy-subrc = 0.
              gw_order_header_data-business_id = lw_zlogs-remarks.
              gw_order_header_data-subusiness_id = lw_zlogs1-errormsg.
            ENDIF.
          ENDIF.
        ENDIF.
        ""EOC By Kalpesh/Shubham 18.11.2025 RD2K9A5E49
        APPEND gw_order_header_data TO et_sob_header_data.

    ENDIF.

    CLEAR: gw_order_header_data,
    gw_vttk,gw_likp,gw_tvtk,gw_adrc,gw_lfa1,gw_ylicm,gw_yttstx0001,
    lw_rcode, lw_rdesc, lw_add02, gw_yttstx0002, gw_kna1,
    gw_lips,gw_t001w,lw_tknum ,lw_tdlnr, gw_zlog_exec_var,
    gw_zlog_taa,lw_tran_dur, lw_qwik_vehtyp,
    lw_remark,lw_sub_business,lw_subusiness_id. ENDLOOP.

    "----\>CN data processing

-   REFRESH gt_vbrp_t.

-   gt_vbrp_t = gt_vbrp.

-   SORT gt_vbrp_t BY vbeln matnr.

-   DELETE ADJACENT DUPLICATES FROM gt_vbrp_t COMPARING vbeln matnr.

-   SORT gt_vbrp_t BY vbeln posnr matnr. SORT lt_zscm_efrcontyp BY
    source_location destination_location. SORT gt_vbrp BY vbeln posnr.
    SORT et_sob_header_data BY shipment_no. SORT gt_vttp BY vbeln.
    REFRESH gt_vbrp_t. gt_vbrp_t = gt_vbrp.     SORT gt_vbrp_t STABLE BY
    vgbel. DELETE ADJACENT DUPLICATES FROM gt_vbrp_t COMPARING vgbel.

" BOC Kalpesh/Shubham TR : RD2K9A528V Dated : 24/01/2025 CLEAR :
gt_vttp_t\[\]. gt_vttp_t\[\] = gt_vttp\[\]. SORT gt_vttp_t BY tknum. "
EOC Kalpesh/Shubham TR : RD2K9A528V Dated : 24/01/2025

"BOC - Railyard Location Enhancement - Initial Data Fetch
"Fetch configuration for railyard location eligibility
CLEAR: lt_zlog_rail_loc[].
SELECT mandt
       name
       active
       bukrs
       remarks
  FROM zlog_exec_var
  CLIENT SPECIFIED
  INTO TABLE lt_zlog_rail_loc
  WHERE mandt = sy-mandt
    AND name = lc_rail_loc_config
    AND active = abap_true.
IF sy-subrc = 0.
  SORT lt_zlog_rail_loc BY bukrs.
ENDIF.
"EOC - Railyard Location Enhancement - Initial Data Fetch

LOOP AT gt_vttk INTO gw_vttk. CALL FUNCTION
'CONVERSION_EXIT_ALPHA_OUTPUT' EXPORTING input = gw_vttk-tknum IMPORTING
output = lw_tknum. CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
EXPORTING input = gw_vttk-tdlnr IMPORTING output = lw_tdlnr.

    READ TABLE gt_yttstx0002 INTO gw_yttstx0002 WITH KEY shnumber = gw_vttk-tknum BINARY SEARCH.
    IF sy-subrc = 0.
      lw_index = sy-tabix.
      LOOP AT gt_yttstx0002 INTO gw_yttstx0002_t FROM lw_index.
        IF gw_yttstx0002-shnumber <> gw_yttstx0002_t-shnumber.
          EXIT.
        ENDIF.

        gw_cn_data-state_of_material     =  'SOLIDS'.

-      gw_cn_data-business_id           =  'RIL'.
          CLEAR gw_zlog_exec_var.
          READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_business_id.     "Binary search not required
          IF sy-subrc = 0.
            gw_cn_data-business_id         = gw_zlog_exec_var-remarks.
          ENDIF.

          gw_cn_data-shipment_no           =  lw_tknum.

          ""BOC BY Kalpesh 31.01.2024
          lw_tknum1 = lw_tknum.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lw_tknum1
            IMPORTING
              output = lw_tknum1.
          ""BOC By Kalpesh/Biswa 27.06.2024
          CLEAR : lw_zscm_fcm_ven_map.
          READ TABLE lt_zscm_fcm_ven_map INTO lw_zscm_fcm_ven_map WITH KEY lifnr = gw_vttk-tdlnr BINARY SEARCH.
          IF sy-subrc = 0 AND lw_zscm_fcm_ven_map-fcm5 EQ abap_true AND lw_zscm_fcm_ven_map-active EQ abap_true.
            CLEAR : lw_zlog.
            READ TABLE lt_zlog INTO lw_zlog WITH KEY name = 'ZSCM_VEND_BILL_RULE_FCM' BINARY SEARCH.
            IF sy-subrc = 0.
              gw_cn_data-gtabillingrule = lw_zlog-errormsg.
              gw_cn_data-gta_applicable = lw_zlog-bill_vendor.
            ENDIF.
          ELSE.
            ""EOC By Kalpesh/Biswa 27.06.2024
            CLEAR : lw_ztrstlmnt.
            READ TABLE lt_ztrstlmnt INTO lw_ztrstlmnt WITH KEY tknum = lw_tknum1 BINARY SEARCH.
            IF sy-subrc = 0.
              CLEAR : lw_par.
              READ TABLE lt_par INTO lw_par WITH KEY name = lc_name
                                                     remarks = lw_ztrstlmnt-bill_regime BINARY SEARCH.
              IF sy-subrc = 0.
                gw_cn_data-gtabillingrule = lw_par-errormsg.

                READ TABLE lt_zlog_exec_var1 INTO lw_zlog_exec_var1 WITH KEY name = 'ZSCM_VEND_BILL_MAP' BINARY SEARCH.  "Added Gagan/Arya 24/04/2024 RD2K9A4PZF
                IF sy-subrc = 0.
                  IF lw_ztrstlmnt-bill_regime EQ lw_zlog_exec_var1-remarks.
                    gw_cn_data-gta_applicable = lw_par-bill_vendor.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF. "Added By Kalpesh 27.06.2024
          ""EOC BY Kalpesh 31.01.2024

          CLEAR gw_zlog_exec_var.
          READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_servcat shtyp = gw_vttk-shtyp.             ""Binary Search not Required
          IF sy-subrc IS INITIAL.
            gw_cn_data-consignment_category  =  gw_zlog_exec_var-remarks.
          ENDIF.

          "(BOC - by num_005 for Cd-8047014 Tr-RD2K9A2YGI on 25.07.2020 - Logic for Express Scenario
          READ TABLE gt_zlog_stlmntvr INTO gw_zlog_stlmntvr WITH KEY name  = gc_gst_vend_rd
                                                                     shtyp = gw_vttk-shtyp.

-                                                                 lifnr = gw_vttk-tdlnr.  "Binary npt required
          IF sy-subrc = 0.
            gw_cn_data-consignment_category  =  'EXP'.
          ENDIF.
          "EOC - by num_005 for Cd-8047014 Tr-RD2K9A2YGI on 25.07.2020 - Logic for Express Scenario )

          gw_cn_data-vendor_code           =  lw_tdlnr.
          gw_cn_data-server                =  sy-sysid.

-      gw_cn_data-cn_qty        = gw_yttstx0002_t-dlvry_qty1.

-      gw_cn_data-cn_uom        = gw_yttstx0002_t-desp_uom.

          READ TABLE lt_trstlmn INTO lw_trstlmn WITH KEY tknum = gw_yttstx0002_t-shnumber
                                                         vbeln = gw_yttstx0002_t-delivery " eswara
                                                         lr_no = gw_yttstx0002_t-lr_no
                                                         lr_dt = gw_yttstx0002_t-lr_dt BINARY SEARCH.
          IF sy-subrc = 0.
            gw_cn_data-cn_qty        = lw_trstlmn-bill_doc_qty.
            gw_cn_data-cn_uom        = lw_trstlmn-lr_uom.
          ENDIF.

          IF gw_cn_data-cn_qty IS INITIAL. " AND gw_cn_data-cn_uom IS INITIAL.
            CLEAR : gw_cn_qty, gw_vbrp_t, gw_vbrp, lw_index.
            READ TABLE gt_vbrp INTO gw_vbrp_t WITH KEY vbeln = gw_yttstx0002_t-billno BINARY SEARCH.
            IF sy-subrc = 0.
              lw_index = sy-tabix.
              LOOP AT gt_vbrp INTO gw_vbrp FROM lw_index.
                IF gw_vbrp-vbeln <> gw_vbrp_t-vbeln.
                  EXIT.
                ENDIF.
                gw_cn_qty = gw_cn_qty + gw_vbrp-fkimg.
                CLEAR : gw_vbrp.
              ENDLOOP.
              gw_cn_data-cn_qty        = gw_cn_qty. "gw_vbrp-fkimg.
              gw_cn_data-cn_uom        = gw_vbrp_t-vrkme.
            ENDIF.
          ENDIF.

          gw_cn_data-cn_leg_no     = '001'.

-      READ TABLE gt_vbrp INTO gw_vbrp WITH KEY vgbel = gw_yttstx0002_t-delivery BINARY SEARCH.

-      IF sy-subrc = 0.

-        SHIFT gw_vbrp-vbeln LEFT DELETING LEADING '0'.

-        SHIFT gw_vbrp-posnr LEFT DELETING LEADING '0'.

-        CONCATENATE gw_vbrp-vbeln '_' gw_vbrp-posnr INTO lw_cn_itm_no.

-        gw_cn_data-cn_item_no = lw_cn_itm_no.

-      ENDIF.

-      gw_cn_data-cn_item_no    = '001'.

          CLEAR lw_rcode.
          IF gw_vttk-zzres_des IS NOT INITIAL.
            SPLIT gw_vttk-zzres_des AT '-' INTO lw_rcode lw_rdesc.
            CONDENSE : lw_rcode, lw_rdesc.
          ENDIF.
          CLEAR gw_zlog_exec_var.
          READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_scm_qwik_rsncode remarks = lw_rcode. "Binary Search not Required
          IF sy-subrc = 0.
            gw_cn_data-gbl_ind      = abap_true.
            gw_cn_data-gbl_val  = gw_vttk-sdabw.
          ENDIF.

          CLEAR gw_zlog_exec_var.



          READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_nrd_shtyp shtyp = gw_vttk-shtyp. "Binary Search not Required

          IF sy-subrc = 0.       """"""""""Shashank code added 30.09.2022
            AT NEW lr_no.
              gw_cn_data-charg_wt      = gw_yttstx0002_t-dlvry_qty1.
            ENDAT.                """"""""""Shashank code added 30.09.2022
            gw_cn_data-charg_wt_uom  = gw_yttstx0002_t-desp_uom.

          ENDIF.
          IF sy-subrc = 0.
            lv_flag = 'X'.
          ENDIF.

          gw_cn_data-cn_no         = gw_yttstx0002_t-lr_no.
          gw_cn_data-cn_date       = gw_yttstx0002_t-lr_dt.

          READ TABLE gt_vttp INTO gw_vttp WITH KEY vbeln = gw_yttstx0002_t-delivery BINARY SEARCH.
          IF sy-subrc = 0.
            READ TABLE gt_likp INTO gw_likp WITH KEY vbeln = gw_vttp-vbeln BINARY SEARCH.
            IF sy-subrc EQ 0.
              gw_cn_data-cn_gross_weight = gw_likp-btgew.
              gw_cn_data-cn_net_weight   = gw_likp-ntgew.
              gw_cn_data-cn_weight_uom   = gw_likp-gewei.

              gw_cn_data-ship_to_party   = gw_likp-kunnr.  "Added by NUM_005 on 17.09.2020

              READ TABLE gt_kna1 INTO gw_kna1 WITH KEY  kunnr = gw_likp-kunnr BINARY SEARCH.
              IF sy-subrc IS INITIAL.
                CLEAR gw_adrc.
                READ TABLE gt_adrc INTO gw_adrc WITH KEY addrnumber = gw_kna1-adrnr BINARY SEARCH.
                IF sy-subrc = 0.
                  gw_cn_data-destination_statecode  =  gw_adrc-region.
                  gw_cn_data-destination_postalcode =  gw_adrc-post_code1.
                ENDIF.

              ENDIF.

              READ TABLE gt_tvrab INTO gw_tvrab WITH KEY route = gw_likp-route sdabw = space BINARY SEARCH.
              IF sy-subrc = 0.
                gw_cn_data-source_location      = gw_tvrab-knanf.
                gw_cn_data-destination_location = gw_tvrab-knend.
              ELSE.                                             "BOC Gagan/Arya 24/04/2024 RD2K9A4PZF
                CALL FUNCTION 'Z_SCM_SOURCE_DESTDTLS_GET'
                  EXPORTING
                    im_tknum = gw_cn_data-shipment_no
                  IMPORTING
                    em_knanf = lv_knanf
                    em_knend = lv_knend.
                gw_order_header_data-source_location      = lv_knanf.
                gw_order_header_data-destination_location = lv_knend.
              ENDIF.                                              "EOC Gagan/Arya 24/04/2024 RD2K9A4PZF

            ENDIF.
            CLEAR : gw_tvrab.
            READ TABLE gt_tvrab INTO gw_tvrab WITH KEY route = gw_vttk-route sdabw = 'Z001' BINARY SEARCH.
            IF sy-subrc = 0.
              gw_cn_data-empty_pick_loc = gw_tvrab-knanf.
            ENDIF.

            READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_zscm_export_road_shtyp
                                                                       shtyp = gw_vttk-shtyp.
            IF sy-subrc = 0.
              READ TABLE gt_mm_exp_tvrab INTO gw_mm_exp_tvrab WITH KEY route = gw_vttk-route BINARY SEARCH.
              IF sy-subrc = 0.
                READ TABLE gt_mm_exp_tvkn INTO gw_mm_exp_tvkn WITH KEY knote = gw_mm_exp_tvrab-knend BINARY SEARCH.
                IF sy-subrc = 0.
                  READ TABLE gt_mm_exp_adrc INTO gw_mm_exp_adrc WITH KEY addrnumber = gw_mm_exp_tvkn-adrnr BINARY SEARCH.
                  IF sy-subrc = 0.
                    gw_cn_data-destination_statecode  = gw_mm_exp_adrc-region.
                    gw_cn_data-destination_postalcode = gw_mm_exp_adrc-post_code1.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.

            READ TABLE gt_lips INTO gw_lips WITH KEY vbeln = gw_vttp-vbeln BINARY SEARCH.
            IF sy-subrc EQ 0.

"BOC - Railyard Location Enhancement
"Step 1: Eligibility Check
CLEAR: lv_rail_loc_flag, lv_bukrs.
IF lt_zlog_rail_loc IS NOT INITIAL.
  "Read TTDS to get BUKRS from TPLST
  CLEAR: lv_bukrs.
  READ TABLE lt_ttds INTO lw_ttds WITH KEY tplst = gw_vttk-tplst BINARY SEARCH.
  IF sy-subrc = 0.
    lv_bukrs = lw_ttds-bukrs.
    "Check if BUKRS is eligible
    READ TABLE lt_zlog_rail_loc INTO lw_zlog_rail_loc 
      WITH KEY bukrs = lv_bukrs BINARY SEARCH.
    IF sy-subrc = 0.
      lv_rail_loc_flag = 'X'.
    ENDIF.
  ENDIF.
ENDIF.

"Step 2: Document & Route Determination
IF lv_rail_loc_flag = 'X'.
  CLEAR: lv_route, lv_multimode_route.
  
  "gw_lips is already read, use it to get source document
  IF gw_lips-vgbel IS NOT INITIAL.
    "Try to get route from EKPV (Purchase Order)
    IF gw_lips-vgtyp = 'E' OR gw_lips-vgtyp = 'K'.
      CLEAR: lw_ekpv.
      SELECT SINGLE ebeln ebelp route
        FROM ekpv
        CLIENT SPECIFIED
        INTO lw_ekpv
        WHERE mandt = sy-mandt
          AND ebeln = gw_lips-vgbel.
      IF sy-subrc = 0 AND lw_ekpv-route IS NOT INITIAL.
        lv_route = lw_ekpv-route.
      ENDIF.
    ENDIF.
    
    "If route not found from EKPV, try VBAP (Sales Order)
    IF lv_route IS INITIAL.
      CLEAR: lw_vbap_route.
      SELECT SINGLE vbeln posnr route
        FROM vbap
        CLIENT SPECIFIED
        INTO lw_vbap_route
        WHERE mandt = sy-mandt
          AND vbeln = gw_lips-vgbel.
      IF sy-subrc = 0 AND lw_vbap_route-route IS NOT INITIAL.
        lv_route = lw_vbap_route-route.
      ENDIF.
    ENDIF.
  ENDIF.
  
  "Step 3: Chain Shipment & Multimodal Route Logic
  IF lv_route IS NOT INITIAL.
    CLEAR: lw_zscm_chainship, lv_multimode_route.
    
    "Read ZSCM_CHAINSHIP
    SELECT SINGLE shnumber chainid odpairid
      FROM zscm_chainship
      CLIENT SPECIFIED
      INTO lw_zscm_chainship
      WHERE mandt = sy-mandt
        AND shnumber = gw_vttk-tknum.
    
    IF sy-subrc = 0 AND lw_zscm_chainship-chainid IS NOT INITIAL.
      "Call FM to get multimodal route
      CALL FUNCTION 'Z_SCM_MULTIMODE_ROUTE'
        EXPORTING
          i_chainid  = lw_zscm_chainship-chainid
          i_odpairid = lw_zscm_chainship-odpairid
          i_route    = lv_route
        IMPORTING
          e_tvrab    = lv_multimode_route
        EXCEPTIONS
          no_data_found = 1
          OTHERS        = 2.
      
      IF sy-subrc = 0 AND lv_multimode_route IS NOT INITIAL.
        lv_route = lv_multimode_route.
      ENDIF.
    ENDIF.
    
    "Step 4: Railyard Source & Destination Determination
    IF lv_route IS NOT INITIAL.
      CLEAR: lw_tvrab_rail.
      SELECT SINGLE route vsart knanf knend
        FROM tvrab
        CLIENT SPECIFIED
        INTO lw_tvrab_rail
        WHERE mandt = sy-mandt
          AND route = lv_route
          AND vsart = gw_vttk-vsart.
      
      IF sy-subrc = 0.
        gw_cn_data-railyardsourcelocation = lw_tvrab_rail-knanf.
        gw_cn_data-railyarddestinationlocation = lw_tvrab_rail-knend.
      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.
"EOC - Railyard Location Enhancement

              "BOC - by NUM_005 for Cd-8052495 tr-RD2K9A392T on 25.02.2020 Fnc-Nidhi Popat
              READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_mfg_marc_subform_id mfrgr = gw_lips-mfrgr.
              IF sy-subrc = 0.
                READ TABLE lt_marc INTO lw_marc WITH KEY matnr = gw_lips-matnr werks = gw_lips-werks BINARY SEARCH.
                IF sy-subrc = 0.
                  gw_cn_data-material_freight_group = lw_marc-mfrgr.
                ENDIF.
              ELSE.
                "EOC - by NUM_005 for Cd-8052495 tr-RD2K9A392T on 25.02.2020 Fnc-Nidhi Popat
                gw_cn_data-material_freight_group = gw_lips-mfrgr.
              ENDIF.
              gw_cn_data-sending_site_code   = gw_lips-werks.

              IF ( gw_lips-vgtyp = 'V' AND gw_lips-vtweg = 30 ) OR ( gw_lips-vgtyp = 'V' AND gw_lips-vtweg = space ).
                gw_cn_data-grn_applicable = 'A'.
              ELSE.
                gw_cn_data-grn_applicable = 'N'.
              ENDIF.

              IF gw_cn_data-gta_applicable IS INITIAL.        "vankudoth rajkumar/shubham cd:8075438
                READ TABLE et_sob_header_data INTO gw_order_header_data WITH KEY shipment_no = lw_tknum BINARY SEARCH.
                IF sy-subrc = 0.
                  READ TABLE gt_zlog_stlmntvr INTO gw_zlog_stlmntvr WITH KEY name = gc_gst_vend_rd shtyp = gw_vttk-shtyp.
                  IF sy-subrc = 0. "AND gw_zlog_stlmntvr-shtyp = gw_vttk-shtyp.   "gw_zlog_stlmntvr-lifnr <> gw_order_header_data-vendor_code.
                    gw_cn_data-gta_applicable = 'N'.
                  ELSE.
                    gw_cn_data-gta_applicable = 'A'.
                  ENDIF.
                ENDIF.
              ENDIF.

              READ TABLE gt_ekpo INTO gw_ekpo  WITH KEY ebeln = gw_lips-vgbel BINARY SEARCH.
              IF sy-subrc = 0.
                gw_cn_data-receiving_site_code = gw_ekpo-werks.
              ELSE.
                READ TABLE gt_likp INTO gw_likp WITH KEY vbeln = gw_lips-vgbel BINARY SEARCH.
                IF sy-subrc = 0.
                  gw_cn_data-receiving_site_code = gw_likp-kunnr.
                ENDIF.
              ENDIF.

              CLEAR gw_zlog_exec_var.
              READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_business spart = gw_lips-spart zzpmatkl1 = gw_lips-matkl.
              IF sy-subrc = 0.
                gw_cn_data-subusiness_id         = gw_zlog_exec_var-remarks.
              ELSE.
                READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_business spart = gw_lips-spart .         "--'SCME_PF_BUSINESS'"Binary Search not Required
                IF sy-subrc IS INITIAL.
                  gw_cn_data-subusiness_id         = gw_zlog_exec_var-remarks.
                ENDIF.
              ENDIF.

              CLEAR gw_zlog_exec_var.
              READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_product_cat shtyp = gw_vttk-shtyp.
              IF sy-subrc = 0.
                gw_cn_data-subusiness_id = gw_zlog_exec_var-rfcdest.
              ENDIF.

              "( BOC by NUM_005 on 30.07.2020 Fnc-Minal

-          IF gw_cn_data-material_freight_group = 'POLMJ'.
              CLEAR gw_zlog_exec_var.
              READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_subform_id   "Binary Search not req.
                                                          mfrgr = gw_cn_data-material_freight_group.
              IF sy-subrc = 0.  "---POYY Scenario
                IF gw_zlog_exec_var-remarks IS NOT INITIAL.
                  gw_cn_data-subformat_code = gw_zlog_exec_var-remarks.
                ELSE.
                  gw_cn_data-subformat_code        = gw_zlog_exec_var-rfcdest.
                ENDIF.
              ELSE.
                READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_business spart = gw_lips-spart.
                IF sy-subrc = 0.
                  gw_cn_data-subformat_code        = gw_zlog_exec_var-rfcdest.
                ENDIF.
              ENDIF.
              "EOC by NUM_005 on 30.07.2020 Fnc-Minal )

              "BOC - by NUM_005 for Cd-8052495 tr-RD2K9A392T on 25.02.2020 Fnc-Nidhi Popat -
              READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name  = gc_pol_subform_id
                                                                         mfrgr = gw_cn_data-material_freight_group.
              IF sy-subrc = 0.  "---POLM Scenario
                gw_cn_data-subformat_code = gw_zlog_exec_var-remarks.
              ENDIF.
              "EOC - by NUM_005 for Cd-8052495 tr-RD2K9A392T on 25.02.2020 Fnc-Nidhi Popat - POLM Scenario

-            IF gw_vttk-shtyp = 'ZER1'.

-              gw_cn_data-product_category = 'PACKSOLC'.

-            ELSEIF gw_zlog_exec_var-rfcdest = 'Polyester'.

-              gw_cn_data-product_category = 'PACKSOLV'.

-            ELSE.

-              gw_cn_data-product_category = 'PACKSOLW'. gc_product_cat

-            ENDIF.

              READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var_t WITH KEY name = gc_product_cat
                                                                           shtyp = gw_vttk-shtyp. " added by santhosh chowdary
              "As per the data in prodcution there will not be more than 50 records
              IF sy-subrc = 0.
                gw_cn_data-product_category =  gw_zlog_exec_var_t-remarks.
              ELSE.
                READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_business spart = gw_lips-spart.
                IF sy-subrc = 0.
                  gw_cn_data-product_category = gw_zlog_exec_var-ewb_uom_d.
                ENDIF.
              ENDIF.


              "Logic specific to Naroda Shipments
              IF gw_cn_data-consignment_category = 'FTL'.
                CLEAR : gw_zlog_exec_var.
                READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = lc_nrd_contract shtyp = gw_vttk-shtyp.
                IF sy-subrc = 0.
                  gw_cn_data-product_category = gw_zlog_exec_var-remarks.
                ENDIF.
              ENDIF.
              "Commented by Eswara for replacing with FM logic

-          READ TABLE lt_zscm_efrcontyp INTO lw_zscm_efrcontyp WITH KEY source_location = gw_order_header_data-source_location

-                                                                       destination_location = gw_order_header_data-destination_location

-                                                                       BINARY SEARCH.

-          IF sy-subrc = 0.

-            lw_tab = sy-tabix.

-            LOOP AT lt_zscm_efrcontyp INTO lw_zscm_efrcontyp FROM lw_tab.

-              IF lw_zscm_efrcontyp-source_location <> gw_order_header_data-source_location AND

-                 lw_zscm_efrcontyp-destination_location <> gw_order_header_data-destination_location.

-                EXIT.

-              ENDIF.

-   

-              IF lw_zscm_efrcontyp-mfrgr = gw_cn_data-material_freight_group OR

-                 lw_zscm_efrcontyp-vehicle_type =  gw_order_header_data-vehicle_type OR

-                 lw_zscm_efrcontyp-vendor = gw_vttk-tdlnr.

-                gw_cn_data-product_category = gc_packsole.

-                EXIT.

-              ENDIF.

-            ENDLOOP.

-          ENDIF.
              "Commented by Eswara for replacing with FM logic
              READ TABLE lt_shipmentoprd_cat INTO lw_shipmentoprd_cat WITH KEY tknum = gw_vttk-tknum
                                                                               cn_date = gw_vttk-datbg
                                                                               BINARY SEARCH.
              IF sy-subrc = 0 AND lw_shipmentoprd_cat-product_cat IS NOT INITIAL.
                gw_cn_data-product_category = lw_shipmentoprd_cat-product_cat.
              ENDIF.
              CLEAR : gw_adrc.
              READ TABLE gt_t001w INTO gw_t001w WITH KEY werks = gw_lips-werks BINARY SEARCH.
              IF sy-subrc EQ 0.
                CLEAR gw_adrc.
                READ TABLE gt_adrc INTO gw_adrc WITH KEY addrnumber = gw_t001w-adrnr BINARY SEARCH.
                IF sy-subrc = 0.
                  gw_cn_data-source_postalcode = gw_adrc-post_code1.
                  gw_cn_data-source_statecode  = gw_adrc-region.
                ENDIF.

              ENDIF.

-        ENDIF.

              "(BOC - by NUM_005 for CD-8050371 Tr-RD2K9A3708
              READ TABLE lt_vekp INTO lw_vekp WITH KEY vpobjkey = gw_vttk-tknum BINARY SEARCH.
              IF sy-subrc = 0.
                READ TABLE lt_mara INTO lw_mara WITH KEY matnr = lw_vekp-vhilm BINARY SEARCH.
                IF sy-subrc = 0.
                  gw_cn_data-container_type = lw_mara-matkl.
                ENDIF.
              ENDIF.
              "EOC - by NUM_005 for CD-8050371 Tr-RD2K9A3708 )

              "( BOC - By NUM_005 for CD-8049941 Tr-RD2K9A34N3 on 04.11.2020 Fnc-Swapnesh
              READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name      = lc_charge_wt
                                                                         shtyp     = gw_vttk-shtyp
                                                                         mfrgr     = gw_lips-mfrgr
                                                                         ewb_uom_d = 'charg_wt'.   "Binary not possible
              IF sy-subrc = 0.
                CONCATENATE gw_zlog_exec_var-remarks '-' gw_zlog_exec_var-rfcdest INTO lw_weight.
                CONDENSE lw_weight NO-GAPS.
                ASSIGN (lw_weight) TO <lfs_charge>.
                gw_cn_data-charg_wt = <lfs_charge>.

                UNASSIGN <lfs_charge>.
                READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name      = lc_charge_wt
                                                                           shtyp     = gw_vttk-shtyp
                                                                           mfrgr     = gw_lips-mfrgr
                                                                           ewb_uom_d = 'charg_wt_uom'. "Binary not possible
                IF sy-subrc = 0.
                  CONCATENATE gw_zlog_exec_var-remarks '-' gw_zlog_exec_var-rfcdest INTO lw_uom.
                  CONDENSE lw_uom NO-GAPS.
                  ASSIGN (lw_uom) TO <lfs_charge>.
                  gw_cn_data-charg_wt_uom = <lfs_charge>.
                ENDIF.

              ELSEIF gw_cn_data-charg_wt IS INITIAL AND lv_flag NE 'X'.
                gw_cn_data-charg_wt      = gw_cn_data-cn_qty.
                gw_cn_data-charg_wt_uom  = gw_cn_data-cn_uom.
              ENDIF.
              " EOC - By NUM_005 for CD-8049941 Tr-RD2K9A34N3 on 04.11.2020 Fnc-Swapnesh )

    \*\*\* Changes for to push Anand/Minal TR: RD2K9A35NY 8050371:
    FCPL\_ TO Push Changes IF gw_cn_data-source_location(2) = 'D-'.

-            Binary search not required.
                READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var
                WITH KEY name = gc_subformat
                mfrgr = gw_cn_data-material_freight_group.
                IF sy-subrc = 0.
                  gw_cn_data-product_category = gw_zlog_exec_var-remarks."'PACKSOLW'(002).
                ENDIF.
              ENDIF.

    \*E.O.C TR: RD2K9A35NY 8050371: FCPL\_ TO Push Changes "BOC by
    Eswara on 20.04.2021 17:28:11 READ TABLE gt_vbrk INTO gw_vbrk WITH
    KEY vbeln = gw_yttstx0002_t-billno BINARY SEARCH. IF sy-subrc IS
    INITIAL . gw_cn_data-soldtoparty = gw_vbrk-kunag. ENDIF.

-   Added by SN Das CD:8083938(Start)

              LOOP AT lt_zlog_exec_var1 INTO lw_zlog_exec_var1
                WHERE name = 'ZSCM_GET_TOPUSH_PARTNFN' AND active = 'X'."less record
                CLEAR:lw_parvw.lw_parvw = lw_zlog_exec_var1-remarks.
                READ TABLE gt_vbpa INTO gw_vbpa
                WITH KEY vbeln =  gw_lips-vgbel
                         parvw = lw_parvw BINARY SEARCH."gc_ac
                IF sy-subrc = 0.
                  lw_field = 'gw_cn_data-' && lw_zlog_exec_var1-ewb_uom_d.
                  ASSIGN (lw_field) TO <fs_field>.
                  CHECK <fs_field> IS ASSIGNED.
                  <fs_field> = gw_vbpa-kunnr."gw_cn_data-agent

-              EXIT.
                ENDIF.
                CLEAR:lw_zlog_exec_var1,gw_vbpa.
              ENDLOOP.
              IF <fs_field> IS ASSIGNED.UNASSIGN <fs_field>.ENDIF.

-   Added by SN Das CD:8083938(End)

-          READ TABLE gt_vbpa INTO gw_vbpa WITH KEY vbeln =  gw_lips-vgbel"Commented by SN Das CD:8083938

-                                                   parvw = gc_ac

-                                                   BINARY SEARCH.

-          IF sy-subrc = 0."Commented by SN Das CD:8083938

-          Agent

-            gw_cn_data-agent =  gw_vbpa-kunnr."Commented by SN Das CD:8083938

-          ENDIF."Commented by SN Das CD:8083938
              READ TABLE gt_vbpa INTO gw_vbpa WITH KEY vbeln =  gw_lips-vgbel
                                                       parvw = gc_ap
                                                       BINARY SEARCH.
              IF sy-subrc = 0.

-          Contact Person
                gw_cn_data-contactperson = gw_vbpa-parnr.
              ENDIF.


              "BOC  by Eswara on 20.04.2021 17:28:11

-        CLEAR : gw_vbrp, gw_vbrp_t.

-        READ TABLE gt_vbrk INTO gw_vbrk WITH KEY vbeln = gw_yttstx0002_t-billno BINARY SEARCH.

-        IF sy-subrc = 0.

-          READ TABLE gt_vbrp INTO gw_vbrp_t WITH KEY vbeln = gw_vbrk-vbeln BINARY SEARCH.

-          IF sy-subrc = 0.

-            CLEAR : lw_index_i.

-            lw_index_i = sy-tabix.     "Parallel cursor is not possible so using WHERE

-            LOOP AT gt_vbrp_t INTO gw_vbrp WHERE vbeln = gw_vbrp_t-vbeln.  "FROM lw_index_i .
              LOOP AT gt_vbrp_t INTO gw_vbrp WHERE vgbel = gw_lips-vbeln. "Parallel cursor is not possible so using WHERE
                IF gw_vbrp-vgbel <> gw_lips-vbeln.
                  EXIT.
                ENDIF.

                SHIFT gw_vbrp-vbeln LEFT DELETING LEADING '0'.
                SHIFT gw_vbrp-posnr LEFT DELETING LEADING '0'.
                CONCATENATE gw_vbrp-vbeln '_' gw_vbrp-posnr INTO lw_cn_itm_no.
                gw_cn_data-cn_item_no = lw_cn_itm_no.

                " Soc Husna Basri TR : RD2K9A4Z4J Dated : 13/11/2024
                IF lv_bussid_flg = 'X'.
                  CLEAR : lw_tknum2,lt_tknum.
                  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                    EXPORTING
                      input  = gw_cn_data-shipment_no
                    IMPORTING
                      output = lw_tknum2-tknum.

                  APPEND lw_tknum2 TO lt_tknum.
                  CLEAR : lw_tknum2,lt_bus_details.

                  CALL FUNCTION 'Z_SCM_GET_BUSINESS'
                    EXPORTING
                      it_tknum       = lt_tknum
                    IMPORTING
                      et_bus_details = lt_bus_details.

                  IF lt_bus_details IS NOT INITIAL.
                    CLEAR : lw_bus_details .
                    READ TABLE lt_bus_details INTO lw_bus_details INDEX 1.
                    IF sy-subrc = 0 .
                      gw_cn_data-business_id = lw_bus_details-business_id.

-                  IF lw_subusiness_id IS NOT INITIAL.gw_cn_data-subusiness_id = lw_subusiness_id.ENDIF."Added by SN Das CD:8079928

-   Added by SN Das CD:8081001(Start) READ TABLE lt_sub_business INTO
    lw_sub_business WITH KEY name = 'ZSCM_GET_RPL_BUS'." BINARY SEARCH
    not required IF sy-subrc = 0 AND ( lw_sub_business-remarks =
    lw_bus_details-business_id ). READ TABLE gt_vttp_t INTO gw_vttp WITH
    KEY tknum = gw_vttk-tknum BINARY SEARCH. IF sy-subrc = 0. READ TABLE
    gt_lips INTO gw_lips WITH KEY vbeln = gw_vttp-vbeln. IF sy-subrc
    = 0. CLEAR : lw_sub_business. READ TABLE lt_sub_business INTO
    lw_sub_business WITH KEY name = 'ZSCM_GET_RPL_SUB' spart =
    gw_lips-spart. IF sy-subrc = 0. lw_subusiness_id =
    gw_cn_data-subusiness_id = lw_sub_business-remarks. ENDIF. ENDIF.
    ENDIF. ENDIF.

-   Added by SN Das CD:8081001(End) ENDIF. ENDIF. ENDIF. " Eoc Husna
    Basri TR : RD2K9A4Z4J Dated : 13/11/2024 READ TABLE gt_zlog_exec_var
    INTO lw_scm_get_sub_prod_id WITH KEY name = lc_scm_get_sub_prod_id.
    IF sy-subrc = 0. " soc by omkar more on 23.11.2024 CD:8079928
    TR:RD2K9A4ZJE CLEAR lw_zlog_exec_var_sub_prod. READ TABLE
    gt_zlog_exec_var INTO lw_zlog_exec_var_sub_prod WITH KEY name =
    lc_zscm_get_rpl_sub remarks = lw_subusiness_id spart =
    gw_lips-spart. " Param Table less records no binary search required.
    IF sy-subrc = 0. gw_cn_data-subformat_code =
    lw_zlog_exec_var_sub_prod-rfcdest.

-                gw_cn_data-product_category  = lw_zlog_exec_var_sub_prod-errormsg. "Changed by Shailesh Zala 10/01/2025 product_category already getting above
                  ENDIF.
                  "eoc by omkar more on 23.11.2024 CD:8079928 TR:RD2K9A4ZJE
                  "BOC By Kalpesh/Shubham 10.12.2024 RD2K9A50AK
                  CLEAR : lw_subformat_t.
                  READ TABLE gt_zlog_exec_var INTO lw_subformat_t WITH KEY name = lc_subformat
                                                                          mfrgr = gw_lips-mfrgr
                                                                          active = abap_true
                                                                          errormsg = lw_subusiness_id.
                  IF sy-subrc = 0.
                    CLEAR : gw_cn_data-subformat_code .
                    gw_cn_data-subformat_code = lw_subformat_t-remarks.
                  ENDIF.
                  "EOC By Kalpesh/Shubham 10.12.2024 RD2K9A50AK

                ENDIF.
                """BOC BY Kalpesh/Shubham 28.11.2024 RD2K9A4ZRP
                IF gw_cn_data-business_id IS NOT INITIAL OR gw_cn_data-subusiness_id IS NOT INITIAL.
                  CLEAR : lw_sub_business.
                  READ TABLE lt_sub_business INTO lw_sub_business WITH KEY name = lc_business
                                                                           remarks = gw_cn_data-business_id BINARY SEARCH.
                  IF sy-subrc = 0.
                    CLEAR : lw_sub_business."Added By Omkar/Shubham 03.12.2024 RD2K9A500K  "lw_subusiness_id.
                    READ TABLE lt_sub_business INTO lw_sub_business WITH KEY name = lc_subbusiness
                                                                             remarks = gw_cn_data-subusiness_id BINARY SEARCH.
                    IF sy-subrc = 0.
                      CLEAR : gw_cn_data-state_of_material.
                    ENDIF.
                  ENDIF.
                ENDIF.
                """EOC BY Kalpesh/Shubham 28.11.2024 RD2K9A4ZRP
                " SOC Husna Basri Dated : 07/02/2025
                CLEAR : gw_zlog_exec_var,lw_likp.
                READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = lc_package_get.
                IF sy-subrc = 0.
                  READ TABLE lt_likp INTO lw_likp WITH KEY vbeln = gw_lips-vbeln BINARY SEARCH.
                  IF sy-subrc = 0.
                    gw_cn_data-no_of_packages  = lw_likp-anzpk.
                  ENDIF.
                ENDIF.
                " EOC Husna Basri Dated : 07/02/2025

                ""BOC By Kalpesh/Shubham 18.11.2025 RD2K9A5E49
                CLEAR : lw_ttds.
                READ TABLE lt_ttds INTO lw_ttds WITH KEY tplst = gw_vttk-tplst BINARY SEARCH.
                IF sy-subrc = 0.
                  CLEAR : lw_zlogs.
                  READ TABLE lt_zlogs INTO lw_zlogs WITH KEY name  = lc_business_name
                                                           bukrs = lw_ttds-bukrs. "Binary search not needed less records
                  IF sy-subrc = 0.
                    CLEAR : lw_zlogs1.
                    READ TABLE lt_zlogs INTO lw_zlogs1 WITH KEY name = lc_subusiness_name
                                                           remarks = lw_zlogs-remarks."Binary search not needed less records
                    IF sy-subrc = 0.
                      gw_cn_data-business_id = lw_zlogs-remarks.
                      gw_cn_data-subusiness_id = lw_zlogs1-errormsg.
                    ENDIF.
                  ENDIF.
                ENDIF.
                ""EOC By Kalpesh/Shubham 18.11.2025 RD2K9A5E49

-   Added by SN Das CD:8086353(Start) READ TABLE gt_zlog_exec_var INTO
    gw_zlog_exec_var WITH KEY name = lc_zscm_get_ril_prodsub remarks =
    gw_cn_data-subusiness_id spart = gw_lips-spart. "BINARY SEARCH not
    required IF sy-subrc = 0. gw_cn_data-subformat_code =
    gw_zlog_exec_var-rfcdest. gw_cn_data-product_category =
    gw_zlog_exec_var-errormsg. ENDIF.

-   Added by SN Das CD:8086353(End) APPEND gw_cn_data TO et_sob_cn_data.
    CLEAR : gw_vbrp,lw_subusiness_id. ENDLOOP.

-          ENDIF.

-      ELSE.

-        APPEND gw_cn_data TO et_sob_cn_data.
            ENDIF.
          ENDIF.

          CLEAR : gw_cn_data, gw_yttstx0002_t, gw_adrc, gw_t001w, gw_zlog_exec_var, gw_likp, gw_ekpo, lw_vekp, lw_mara,
                  gw_vttp, gw_order_header_data, gw_lips, gw_vbrp, gw_zlog_exec_var_t,lw_trstlmn, lw_weight, lw_uom, lw_marc.
        ENDLOOP.
        CLEAR : lw_index.

    ENDIF. ENDLOOP.

    "----\>Cust data processing REFRESH gt_vbrp_t. gt_vbrp_t = gt_vbrp.

-   SORT gt_vbrp_t BY vbeln matnr.

-   DELETE ADJACENT DUPLICATES FROM gt_vbrp_t COMPARING vbeln matnr.

-   SORT gt_vbrp_t BY vbeln posnr matnr. SORT gt_vbrp_t BY vgbel vbeln
    posnr. DELETE ADJACENT DUPLICATES FROM gt_vbrp_t COMPARING vgbel.
    SORT gt_vbrp BY vgbel. "vbeln. SORT gt_vttp BY vbeln." SOC Husna
    Basri TR : RD2K9A51WT Dated : 16/01/2025 CLEAR : gt_vttp_t\[\].
    gt_vttp_t\[\] = gt_vttp\[\]. SORT gt_vttp_t BY tknum. " EOC Husna
    Basri TR : RD2K9A51WT Dated : 16/01/2025 LOOP AT gt_vttk INTO
    gw_vttk.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT' EXPORTING input =
    gw_vttk-tknum IMPORTING output = lw_tknum.

    CLEAR : lw_index. READ TABLE gt_yttstx0002 INTO gw_yttstx0002_t WITH
    KEY shnumber = gw_vttk-tknum BINARY SEARCH. IF sy-subrc = 0.
    "Outbound CLEAR : lw_index. lw_index = sy-tabix."Parallel Cursor
    LOOP AT gt_yttstx0002 INTO gw_yttstx0002 FROM lw_index .

         IF gw_yttstx0002-shnumber <> gw_yttstx0002_t-shnumber.
           EXIT.
         ENDIF.

         READ TABLE gt_vttp INTO gw_vttp WITH KEY vbeln = gw_yttstx0002-delivery BINARY SEARCH.
         IF sy-subrc EQ 0.
           READ TABLE gt_vbfa INTO gw_vbfa WITH KEY vbelv = gw_vttp-vbeln.
           IF sy-subrc EQ 0.
             "OBD Details
             gw_cust_doc_data_t-shipment_no           =  lw_tknum.
             gw_cust_doc_data_t-customer_doc_no       =  gw_vttp-vbeln.
             SHIFT gw_cust_doc_data_t-customer_doc_no  LEFT DELETING LEADING '0'. " eswara

             gw_cust_doc_data_t-customer_doc_category =  '05'.

             READ TABLE gt_lips INTO gw_lips WITH KEY vbeln = gw_vttp-vbeln BINARY SEARCH.
             IF sy-subrc = 0.
               gw_cust_doc_data_t-cust_src_doc = gw_lips-vgbel.
               gw_cust_doc_data_t-customer_doc_item_no = gw_lips-posnr.

-            gw_cust_doc_data_t-business_id           =  'RIL'.
                READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_business_id.     "Binary search not required
                IF sy-subrc = 0.
                  gw_cust_doc_data_t-business_id    = gw_zlog_exec_var-remarks.
                ENDIF.

                READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_business  spart = gw_lips-spart zzpmatkl1 = gw_lips-matkl.
                IF sy-subrc = 0.
                  gw_cust_doc_data_t-subusiness_id     = gw_zlog_exec_var-remarks.
                ELSE.
                  READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_business  spart = gw_lips-spart .   "Binary Search not Required       "--'SCME_PF_BUSINESS'
                  IF sy-subrc IS INITIAL.
                    gw_cust_doc_data_t-subusiness_id     = gw_zlog_exec_var-remarks.
                  ENDIF.
                ENDIF.

                CLEAR gw_zlog_exec_var.
                READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_product_cat shtyp = gw_vttk-shtyp.
                IF sy-subrc = 0.
                  gw_cust_doc_data_t-subusiness_id = gw_zlog_exec_var-rfcdest.
                ENDIF.
              ENDIF.

-          READ TABLE gt_vbrp INTO gw_vbrp WITH KEY vbeln = gw_vbfa-vbeln BINARY SEARCH.

-          IF sy-subrc EQ 0.

-            CLEAR : lw_index_i, lw_fkimg.

-            lw_index_i = sy-tabix.

-   

-            gw_cust_doc_data-shipment_no                   = lw_tknum.

-            gw_cust_doc_data-customer_doc_item_no          = gw_vbrp-posnr.

-            gw_cust_doc_data-invoice_material_item         = gw_vbrp-matnr.

-            gw_cust_doc_data-invoice_material_descr        = gw_vbrp-arktx.

-   

-            LOOP AT gt_vbrp INTO gw_vbrp_t FROM lw_index_i.

-              IF gw_vbrp_t-vbeln <> gw_vbrp-vbeln AND gw_vbrp_t-matnr <> gw_vbrp-matnr.

-                EXIT.

-              ENDIF.

-              lw_fkimg = lw_fkimg + gw_vbrp_t-fkimg.

-              CLEAR : gw_vbrp_t.

-            ENDLOOP.

-   

-            gw_cust_doc_data-invoice_qty_item              = lw_fkimg. "gw_vbrp-fkimg.

-            gw_cust_doc_data-invoice_qty_uom_item          = gw_vbrp-vrkme.

    \*\* gw_cust_doc_data-invoice_amount_item = gw_vbrp-netwr.

-            CLEAR gw_vbrk.

-            READ TABLE gt_vbrk INTO gw_vbrk WITH KEY vbeln = gw_vbrp-vbeln BINARY SEARCH.

-            IF sy-subrc EQ 0.

-              "DCPI Details

-              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'

-                EXPORTING

-                  input  = gw_vbrk-vbeln

-                IMPORTING

-                  output = gw_vbrk-vbeln.

-              gw_cust_doc_data-customer_doc_category =  '01'.

-              gw_cust_doc_data-customer_doc_no       =  gw_vbrk-vbeln.

-   

-              lw_invoice = gw_vbrk-vbeln.

-              APPEND lw_invoice TO lt_invoice.

-              "FM to calculate a GST/SGST/CGST/IGST for invoice amt

-              CALL FUNCTION 'Z_SCE_EWB_PRODUCT'

-                EXPORTING

-                  i_invoice = lt_invoice

-                  i_ind     = 'C'

-                IMPORTING

-                  et_total  = lt_total.

-   

-              READ TABLE lt_total INTO lw_total INDEX 1.

-              IF sy-subrc = 0.

-                lw_nettax =  lw_total-sgst_value_t +

-                             lw_total-cgst_value_t +

-                             lw_total-igst_value_t +

-                             lw_total-cess_value_t +

-                             lw_total-utgst_value_t.

-              ENDIF.

-   

-              gw_cust_doc_data-invoice_amount_hdr    =  gw_vbrk-netwr + lw_nettax.

-   

-              gw_cust_doc_data-invoice_date          =  gw_vbrk-fkdat.

-              gw_cust_doc_data-invoice_currency      =  gw_vbrk-waerk.

-              gw_cust_doc_data-exchange_rate         =  gw_vbrk-kurrf.

-              gw_cust_doc_data-incoterm              =  gw_vbrk-inco1.

-              gw_cust_doc_data-division              =  gw_vbrk-spart.

-   

-              gw_cust_doc_data-invoice_amount_item   = gw_vbrk-netwr + lw_nettax.

-   

-            ENDIF.

              CLEAR : gw_lips.
              READ TABLE gt_lips INTO gw_lips WITH KEY vbeln = gw_vttp-vbeln BINARY SEARCH. " gw_yttstx0002_t-deliveryBINARY SEARCH.
              IF sy-subrc = 0.
                gw_cust_doc_data-cust_src_doc   = gw_lips-vgbel.
                gw_cust_doc_data_t-cust_src_doc = gw_lips-vgbel.
                READ TABLE gt_vbak INTO gw_vbak WITH KEY vbeln = gw_lips-vgbel BINARY SEARCH.
                IF sy-subrc = 0.
                  gw_cust_doc_data-cust_compcode   = gw_vbak-bukrs_vf.
                  gw_cust_doc_data_t-cust_compcode = gw_vbak-bukrs_vf.
                ELSEIF gw_cust_doc_data-cust_compcode IS INITIAL.
                  READ TABLE gt_ekko INTO gw_ekko WITH KEY ebeln = gw_lips-vgbel BINARY SEARCH.
                  IF sy-subrc = 0.
                    gw_cust_doc_data-cust_compcode   = gw_ekko-bukrs.
                    gw_cust_doc_data_t-cust_compcode = gw_ekko-bukrs.
                  ENDIF.
                ENDIF.

-            gw_cust_doc_data-business_id = 'RIL'.
                READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_business_id.     "Binary search not required
                IF sy-subrc = 0.
                  gw_cust_doc_data-business_id    = gw_zlog_exec_var-remarks.
                ENDIF.

                READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_business  spart = gw_lips-spart zzpmatkl1 = gw_lips-matkl.
                IF sy-subrc = 0.
                  gw_cust_doc_data-subusiness_id     = gw_zlog_exec_var-remarks.
                ELSE.
                  READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_business  spart = gw_lips-spart . "Binary Search not Required         "--'SCME_PF_BUSINESS'
                  IF sy-subrc IS INITIAL.
                    gw_cust_doc_data-subusiness_id     = gw_zlog_exec_var-remarks.
                  ENDIF.
                ENDIF.
              ENDIF.

              CLEAR gw_zlog_exec_var.
              READ TABLE gt_zlog_exec_var INTO gw_zlog_exec_var WITH KEY name = gc_product_cat shtyp = gw_vttk-shtyp.
              IF sy-subrc = 0.
                gw_cust_doc_data-subusiness_id = gw_zlog_exec_var-rfcdest.
              ENDIF.

              gw_cust_doc_data-cn_no   = gw_yttstx0002-lr_no.
              gw_cust_doc_data-cn_date = gw_yttstx0002-lr_dt.
              "For OBD
              gw_cust_doc_data_t-cn_no   = gw_yttstx0002-lr_no.
              gw_cust_doc_data_t-cn_date = gw_yttstx0002-lr_dt.


              CLEAR gw_vbrk.
              READ TABLE gt_vbrk INTO gw_vbrk WITH KEY vbeln = gw_vbfa-vbeln BINARY SEARCH.
              IF sy-subrc EQ 0.
                "DCPI Details
                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                  EXPORTING
                    input  = gw_vbrk-vbeln
                  IMPORTING
                    output = lw_vbrk_vbeln.
                gw_cust_doc_data-customer_doc_category =  '01'.
                gw_cust_doc_data-customer_doc_no       =  lw_vbrk_vbeln.  "gw_vbrk-vbeln.
                SHIFT gw_cust_doc_data-customer_doc_no  LEFT DELETING LEADING '0'. " eswara

                lw_invoice = gw_vbrk-vbeln.
                APPEND lw_invoice TO lt_invoice.
                "FM to calculate a GST/SGST/CGST/IGST for invoice amt

-            CALL FUNCTION 'Z_SCE_EWB_PRODUCT'

-              EXPORTING

-                i_invoice = lt_invoice

-                i_ind     = 'C'

-              IMPORTING

-                et_total  = lt_total.

                CALL FUNCTION 'Z_PTC_EWB_PRODUCT'
                  EXPORTING
                    i_invoice = lt_invoice
                    i_ind     = 'C'
                  IMPORTING
                    et_total  = lt_total
                    ex_zfst   = lv_zfst. ""Added By Kalpesh/Gaurav 28.08.2025 RD2K9A5BBT

                READ TABLE lt_total INTO lw_total INDEX 1.
                IF sy-subrc = 0.
                  lw_nettax =  lw_total-sgst_value_t +
                               lw_total-cgst_value_t +
                               lw_total-igst_value_t +
                               lw_total-cess_value_t +
                               lw_total-utgst_value_t.
                ENDIF.

-            gw_cust_doc_data-invoice_amount_hdr    =  gw_vbrk-netwr + lw_nettax.
                gw_cust_doc_data-invoice_amount_hdr    =  lw_total-taxable_val_t + lw_nettax + lv_zfst."lv_zsft Added By Kalpesh/Gaurav 28.08.2025 RD2K9A5BBT

-            gw_cust_doc_data-invoice_amount_item   =  gw_vbrk-netwr + lw_nettax.
                gw_cust_doc_data-invoice_amount_item   =  lw_total-taxable_val_t + lw_nettax + lv_zfst."lv_zsft "Added By Kalpesh/Gaurav 28.08.2025 RD2K9A5BBT
                READ TABLE gt_zlog_exec_var  INTO  lw_zlog_exec_var_tmp WITH KEY mfrgr = gw_lips-mfrgr
                                                                                 name = gc_zscm_freight_value_solids.   "ARPIT
                IF sy-subrc EQ 0.
                  READ TABLE lt_zfcplbill INTO lw_zfcplbill WITH KEY billno = gw_vbrk-vbeln BINARY SEARCH.
                  IF sy-subrc = 0.
                    READ TABLE lt_frtinv_val INTO lw_frtinv_val WITH KEY zfcplbill = lw_zfcplbill-zfcplbill BINARY SEARCH.
                    IF sy-subrc EQ 0.
                      gw_cust_doc_data-invoice_amount_hdr  = lw_frtinv_val-netwr + gw_cust_doc_data-invoice_amount_hdr.
                    ENDIF.
                  ENDIF.
                ENDIF.

                gw_cust_doc_data-invoice_date          =  gw_vbrk-fkdat.
                gw_cust_doc_data-invoice_currency      =  gw_vbrk-waerk.
                gw_cust_doc_data-exchange_rate         =  gw_vbrk-kurrf.
                gw_cust_doc_data-incoterm              =  gw_vbrk-inco1.
                gw_cust_doc_data-division              =  gw_vbrk-spart.

-            READ TABLE gt_vbrp_t INTO gw_vbrp_t WITH KEY vbeln = gw_vbrk-vbeln BINARY SEARCH.
                READ TABLE gt_vbrp_t INTO gw_vbrp_t WITH KEY vgbel = gw_lips-vbeln BINARY SEARCH.
                IF sy-subrc EQ 0.
                  CLEAR : lw_index_i, lw_fkimg.
                  lw_index_i = sy-tabix.

                  LOOP AT gt_vbrp_t INTO gw_vbrp FROM lw_index_i.

-                IF gw_vbrp_t-vbeln <> gw_vbrp-vbeln. "AND gw_vbrp_t-matnr <> gw_vbrp-matnr.
                    IF gw_vbrp-vgbel <> gw_lips-vbeln. "AND gw_vbrp_t-matnr <> gw_vbrp-matnr. " eswara and susheel
                      EXIT.
                    ENDIF.

                    gw_cust_doc_data-shipment_no                = lw_tknum.
                    gw_cust_doc_data-customer_doc_item_no       = gw_vbrp-posnr.
                    gw_cust_doc_data-invoice_material_item      = gw_vbrp-matnr.
                    gw_cust_doc_data-invoice_material_descr     = gw_vbrp-arktx.

-                LOOP AT gt_vbrp INTO gw_vbrp_tmp WHERE vbeln = gw_vbrp-vbeln AND matnr = gw_vbrp-matnr.
                    LOOP AT gt_vbrp INTO gw_vbrp_tmp WHERE vgbel = gw_vbrp-vgbel.
                      lw_fkimg = lw_fkimg + gw_vbrp_tmp-fkimg.
                      CLEAR : gw_vbrp_tmp.
                    ENDLOOP.

                    gw_cust_doc_data-invoice_qty_item              = lw_fkimg. "gw_vbrp-fkimg.
                    gw_cust_doc_data-invoice_qty_uom_item          = gw_vbrp-vrkme.

                    "Append DCPI details
                    IF gw_cust_doc_data-customer_doc_no IS NOT INITIAL.

                      " Soc Husna Basri TR : RD2K9A4Z4J Dated : 13/11/2024
                      IF lv_bussid_flg = 'X'.
                        CLEAR : lw_tknum2,lt_tknum.
                        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                          EXPORTING
                            input  = gw_cust_doc_data-shipment_no
                          IMPORTING
                            output = lw_tknum2-tknum.
                        APPEND lw_tknum2 TO lt_tknum.

                        CLEAR : lw_tknum2,lt_bus_details.

                        CALL FUNCTION 'Z_SCM_GET_BUSINESS'
                          EXPORTING
                            it_tknum       = lt_tknum
                          IMPORTING
                            et_bus_details = lt_bus_details.

                        IF lt_bus_details IS NOT INITIAL.
                          CLEAR : lw_bus_details .
                          READ TABLE lt_bus_details INTO lw_bus_details INDEX 1.
                          IF sy-subrc = 0.
                            gw_cust_doc_data-business_id = lw_bus_details-business_id.

-                        IF lw_subusiness_id IS NOT INITIAL.gw_cust_doc_data-subusiness_id = lw_subusiness_id.ENDIF."Added by SN Das CD:8079928

-   Added by SN Das CD:8081001(Start) READ TABLE lt_sub_business INTO
    lw_sub_business WITH KEY name = 'ZSCM_GET_RPL_BUS'." BINARY SEARCH
    not required IF sy-subrc = 0 AND ( lw_sub_business-remarks =
    lw_bus_details-business_id ). CLEAR : gw_vttp. READ TABLE gt_vttp_t
    INTO gw_vttp WITH KEY tknum = gw_vttk-tknum BINARY SEARCH. IF
    sy-subrc = 0. READ TABLE gt_lips INTO gw_lips WITH KEY vbeln =
    gw_vttp-vbeln. IF sy-subrc = 0. CLEAR : lw_sub_business. READ TABLE
    lt_sub_business INTO lw_sub_business WITH KEY name =
    'ZSCM_GET_RPL_SUB' spart = gw_lips-spart. IF sy-subrc = 0.
    lw_subusiness_id = gw_cust_doc_data-subusiness_id =
    lw_sub_business-remarks. ENDIF. ENDIF. ENDIF. ENDIF.

-   Added by SN Das CD:8081001(End) ENDIF. ENDIF. ENDIF. " Eoc Husna
    Basri TR : RD2K9A4Z4J Dated : 13/11/2024

                      ""BOC By Kalpesh/Shubham 18.11.2025 RD2K9A5E49
                      CLEAR : lw_ttds.
                      READ TABLE lt_ttds INTO lw_ttds WITH KEY tplst = gw_vttk-tplst BINARY SEARCH.
                      IF sy-subrc = 0.
                        CLEAR : lw_zlogs.
                        READ TABLE lt_zlogs INTO lw_zlogs WITH KEY name  = lc_business_name
                                                                 bukrs = lw_ttds-bukrs. "Binary search not needed less records
                        IF sy-subrc = 0.
                          CLEAR : lw_zlogs1.
                          READ TABLE lt_zlogs INTO lw_zlogs1 WITH KEY name = lc_subusiness_name
                                                                 remarks = lw_zlogs-remarks."Binary search not needed less records
                          IF sy-subrc = 0.
                            gw_cust_doc_data-business_id = lw_zlogs-remarks.
                            gw_cust_doc_data-subusiness_id = lw_zlogs1-errormsg.
                          ENDIF.
                        ENDIF.
                      ENDIF.
                      ""EOC By Kalpesh/Shubham 18.11.2025 RD2K9A5E49

                      APPEND  gw_cust_doc_data TO et_sob_cust_doc_data.  "Customer Document Data
                    ENDIF.

                    CLEAR : gw_vbrp, lw_fkimg, gw_vbrp_tmp,lw_subusiness_id.
                  ENDLOOP.

                ENDIF.
              ELSE.
                "Append OBD detail
                IF gw_cust_doc_data_t-customer_doc_no IS NOT INITIAL.
                  " Soc Husna Basri TR : RD2K9A4Z4J Dated : 13/11/2024
                  IF lv_bussid_flg = 'X'.
                    CLEAR : lw_tknum2,lt_tknum.
                    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                      EXPORTING
                        input  = gw_cust_doc_data_t-shipment_no
                      IMPORTING
                        output = lw_tknum2-tknum.
                    APPEND lw_tknum2 TO lt_tknum.

                    CLEAR : lw_tknum2,lt_bus_details.

                    CALL FUNCTION 'Z_SCM_GET_BUSINESS'
                      EXPORTING
                        it_tknum       = lt_tknum
                      IMPORTING
                        et_bus_details = lt_bus_details.

                    IF lt_bus_details IS NOT INITIAL.
                      CLEAR : lw_bus_details .
                      READ TABLE lt_bus_details INTO lw_bus_details INDEX 1.
                      IF sy-subrc = 0.
                        gw_cust_doc_data_t-business_id = lw_bus_details-business_id.

-                    IF lw_subusiness_id IS NOT INITIAL.gw_cust_doc_data_t-subusiness_id = lw_subusiness_id.ENDIF."Added by SN Das CD:8079928

-   Added by SN Das CD:8081001(Start) READ TABLE lt_sub_business INTO
    lw_sub_business WITH KEY name = 'ZSCM_GET_RPL_BUS'." BINARY SEARCH
    not required IF sy-subrc = 0 AND ( lw_sub_business-remarks =
    lw_bus_details-business_id ). CLEAR : gw_vttp. READ TABLE gt_vttp_t
    INTO gw_vttp WITH KEY tknum = gw_vttk-tknum BINARY SEARCH. IF
    sy-subrc = 0. READ TABLE gt_lips INTO gw_lips WITH KEY vbeln =
    gw_vttp-vbeln. IF sy-subrc = 0. CLEAR : lw_sub_business. READ TABLE
    lt_sub_business INTO lw_sub_business WITH KEY name =
    'ZSCM_GET_RPL_SUB' spart = gw_lips-spart. IF sy-subrc = 0.
    lw_subusiness_id = gw_cust_doc_data_t-subusiness_id =
    lw_sub_business-remarks. ENDIF. ENDIF. ENDIF. ENDIF.

-   Added by SN Das CD:8081001(End) ENDIF. ENDIF. ENDIF. " Eoc Husna
    Basri TR : RD2K9A4Z4J Dated : 13/11/2024

                  ""BOC By Kalpesh/Shubham 18.11.2025 RD2K9A5E49
                  CLEAR : lw_ttds.
                  READ TABLE lt_ttds INTO lw_ttds WITH KEY tplst = gw_vttk-tplst BINARY SEARCH.
                  IF sy-subrc = 0.
                    CLEAR : lw_zlogs.
                    READ TABLE lt_zlogs INTO lw_zlogs WITH KEY name  = lc_business_name
                                                             bukrs = lw_ttds-bukrs. "Binary search not needed less records
                    IF sy-subrc = 0.
                      CLEAR : lw_zlogs1.
                      READ TABLE lt_zlogs INTO lw_zlogs1 WITH KEY name = lc_subusiness_name
                                                             remarks = lw_zlogs-remarks."Binary search not needed less records
                      IF sy-subrc = 0.
                        gw_cust_doc_data_t-business_id = lw_zlogs-remarks.
                        gw_cust_doc_data_t-subusiness_id = lw_zlogs1-errormsg.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                  ""EOC By Kalpesh/Shubham 18.11.2025 RD2K9A5E49

                  APPEND gw_cust_doc_data_t TO et_sob_cust_doc_data.
                  CLEAR : lw_subusiness_id.
                ENDIF.
              ENDIF.
              "Append OBD detail
              IF gw_cust_doc_data_t-customer_doc_no IS NOT INITIAL.

                " Soc Husna Basri TR : RD2K9A4Z4J Dated : 13/11/2024
                IF lv_bussid_flg = 'X'.
                  CLEAR : lw_tknum2,lt_tknum.
                  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                    EXPORTING
                      input  = gw_cust_doc_data_t-shipment_no
                    IMPORTING
                      output = lw_tknum2-tknum.
                  APPEND lw_tknum2 TO lt_tknum.

                  CLEAR : lw_tknum2,lt_bus_details.

                  CALL FUNCTION 'Z_SCM_GET_BUSINESS'
                    EXPORTING
                      it_tknum       = lt_tknum
                    IMPORTING
                      et_bus_details = lt_bus_details.

                  IF lt_bus_details IS NOT INITIAL.
                    CLEAR : lw_bus_details .
                    READ TABLE lt_bus_details INTO lw_bus_details INDEX 1.
                    IF sy-subrc = 0.
                      gw_cust_doc_data_t-business_id = lw_bus_details-business_id.

-                  IF lw_subusiness_id IS NOT INITIAL.gw_cust_doc_data_t-subusiness_id = lw_subusiness_id.ENDIF."Added by SN Das CD:8079928

-   Added by SN Das CD:8081001(Start) READ TABLE lt_sub_business INTO
    lw_sub_business WITH KEY name = 'ZSCM_GET_RPL_BUS'." BINARY SEARCH
    not required IF sy-subrc = 0 AND ( lw_sub_business-remarks =
    lw_bus_details-business_id ). READ TABLE gt_vttp_t INTO gw_vttp WITH
    KEY tknum = gw_vttk-tknum BINARY SEARCH. IF sy-subrc = 0. READ TABLE
    gt_lips INTO gw_lips WITH KEY vbeln = gw_vttp-vbeln. IF sy-subrc
    = 0. CLEAR : lw_sub_business. READ TABLE lt_sub_business INTO
    lw_sub_business WITH KEY name = 'ZSCM_GET_RPL_SUB' spart =
    gw_lips-spart. IF sy-subrc = 0. lw_subusiness_id =
    gw_cust_doc_data_t-subusiness_id = lw_sub_business-remarks. ENDIF.
    ENDIF. ENDIF. ENDIF.

-   Added by SN Das CD:8081001(End) ENDIF. ENDIF. ENDIF. " Eoc Husna
    Basri TR : RD2K9A4Z4J Dated : 13/11/2024 ""BOC By Kalpesh/Shubham
    18.11.2025 RD2K9A5E49 CLEAR : lw_ttds. READ TABLE lt_ttds INTO
    lw_ttds WITH KEY tplst = gw_vttk-tplst BINARY SEARCH. IF sy-subrc
    = 0. CLEAR : lw_zlogs. READ TABLE lt_zlogs INTO lw_zlogs WITH KEY
    name = lc_business_name bukrs = lw_ttds-bukrs."Binary search not
    needed less records IF sy-subrc = 0. CLEAR : lw_zlogs1. READ TABLE
    lt_zlogs INTO lw_zlogs1 WITH KEY name = lc_subusiness_name remarks =
    lw_zlogs-remarks."Binary search not needed less records IF sy-subrc
    = 0. gw_cust_doc_data_t-business_id = lw_zlogs-remarks.
    gw_cust_doc_data_t-subusiness_id = lw_zlogs1-errormsg. ENDIF. ENDIF.
    ENDIF. ""EOC By Kalpesh/Shubham 18.11.2025 RD2K9A5E49 APPEND
    gw_cust_doc_data_t TO et_sob_cust_doc_data. CLEAR :
    lw_subusiness_id. ENDIF.

            ENDIF.
          ENDIF.
          CLEAR : gw_yttstx0002, gw_cust_doc_data_t, gw_cust_doc_data, lw_nettax, lt_total, lt_invoice, lw_invoice, lw_nettax,lw_vbrk_vbeln.
        ENDLOOP.

    ENDIF. CLEAR gw_vttk. ENDLOOP. CLEAR : lw_remark,lw_subusiness_id.
    ENDFUNCTION.
