# Technical Specification Document

## Enhancement to FM Z_SCM_SOLIDS_OB_GETDET
### Railyard Source & Destination Determination during TO Push

---

## 1. Document Control

| **Item** | **Details** |
|----------|-------------|
| **Module** | SCM / SD / MM |
| **Object Type** | Function Module Enhancement |
| **Function Module** | Z_SCM_SOLIDS_OB_GETDET |
| **Process** | TO Push -- Rate Check |
| **Version** | 1.0 |
| **Date** | [Current Date] |

---

## 2. Technical Overview

### 2.1 Purpose
Enhance Function Module `Z_SCM_SOLIDS_OB_GETDET` to populate railyard source and destination location fields in the CN data output structure (`ET_SOB_CN_DATA`) during TO Push process.

### 2.2 Impact Area
- **Function Module**: `Z_SCM_SOLIDS_OB_GETDET`
- **Output Structure**: `ET_SOB_CN_DATA` (Type: `ZSCE_CN_DATA_T`)
- **Processing Section**: CN Data Processing Loop (approximately line 1902 onwards)

---

## 3. Data Structures & Variables

### 3.1 New Local Types

```abap
TYPES: BEGIN OF lty_zlog_rail_loc,
         mandt    TYPE mandt,
         name     TYPE rvari_vnam,
         active   TYPE zactive_flag,
         bukrs    TYPE bukrs,
         remarks  TYPE textr,
       END OF lty_zlog_rail_loc.

TYPES: BEGIN OF lty_ekpv,
         ebeln    TYPE ebeln,
         ebelp    TYPE ebelp,
         route    TYPE route,
       END OF lty_ekpv.

TYPES: BEGIN OF lty_vbap_route,
         vbeln    TYPE vbeln_va,
         posnr    TYPE posnr,
         route    TYPE route,
       END OF lty_vbap_route.

TYPES: BEGIN OF lty_zscm_chainship,
         shnumber TYPE tknum,
         chainid  TYPE zchain_id,
         odpairid TYPE zodpair_id,
       END OF lty_zscm_chainship.

TYPES: BEGIN OF lty_tvrab_rail,
         route    TYPE route,
         vsart    TYPE vsart,
         knanf    TYPE knota,
         knend    TYPE knotz,
       END OF lty_tvrab_rail.
```

### 3.2 New Local Variables

```abap
DATA: lt_zlog_rail_loc TYPE TABLE OF lty_zlog_rail_loc,
      lw_zlog_rail_loc TYPE lty_zlog_rail_loc,
      lt_ekpv TYPE TABLE OF lty_ekpv,
      lw_ekpv TYPE lty_ekpv,
      lt_vbap_route TYPE TABLE OF lty_vbap_route,
      lw_vbap_route TYPE lty_vbap_route,
      lt_zscm_chainship TYPE TABLE OF lty_zscm_chainship,
      lw_zscm_chainship TYPE lty_zscm_chainship,
      lt_tvrab_rail TYPE TABLE OF lty_tvrab_rail,
      lw_tvrab_rail TYPE lty_tvrab_rail,
      lv_route TYPE route,
      lv_multimode_route TYPE route,
      lv_bukrs TYPE bukrs,
      lv_rail_loc_flag TYPE char1.
```

### 3.3 Constants

```abap
CONSTANTS: lc_rail_loc_config TYPE rvari_vnam VALUE 'ZSCM_GET_RAIL_LOCATION'.
```

---

## 4. Technical Design

### 4.1 Code Placement
The enhancement logic will be inserted in the **CN Data Processing Loop** section, specifically:
- **Location**: After line ~2123 (after reading `gt_lips` and before populating other CN data fields)
- **Context**: Inside the loop `LOOP AT gt_yttstx0002 INTO gw_yttstx0002_t FROM lw_index`

### 4.2 Processing Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Eligibility Check (Configuration Driven)                │
│    - Read ZLOG_EXEC_VAR (NAME = 'ZSCM_GET_RAIL_LOCATION')   │
│    - Read TTDS (TPLST = VTTK-TPLST)                        │
│    - Compare BUKRS                                          │
│    - If match → proceed, else skip                          │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. Document & Route Determination                           │
│    - Read VTTP (TKNUM = VTTK-TKNUM) → VBELN                 │
│    - Read LIPS (VBELN = VTTP-VBELN) → VGBEL                 │
│    - Determine Route:                                       │
│      a. Try EKPV (EBELN = LIPS-VGBEL)                       │
│      b. If not found, try VBAP (VBELN = LIPS-VGBEL)         │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. Chain Shipment & Multimodal Route Logic                 │
│    - Read ZSCM_CHAINSHIP (SHNUMBER = VTTK-TKNUM)           │
│    - Call FM Z_SCM_MULTIMODE_ROUTE                          │
│      (I_CHAINID, I_ODPAIRID, I_ROUTE)                       │
│    - Get E_TVRAB (multimodal route)                         │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. Railyard Source & Destination Determination              │
│    - Read TVRAB (VSART = VTTK-VSART, ROUTE = E_TVRAB)      │
│    - Populate:                                               │
│      gw_cn_data-railyardsourcelocation = TVRAB-KNANF        │
│      gw_cn_data-railyarddestinationlocation = TVRAB-KNEND   │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Detailed Implementation

### 5.1 Step 1: Initial Data Fetching (Before Main Loop)

**Location**: After line ~1893 (after sorting statements, before main loop)

```abap
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
```

### 5.2 Step 2: Eligibility Check & Route Determination (Inside CN Loop)

**Location**: After line ~2123 (after `READ TABLE gt_lips INTO gw_lips`)

```abap
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
  
  "Read VTTP to get delivery
  CLEAR: gw_vttp.
  READ TABLE gt_vttp INTO gw_vttp WITH KEY tknum = gw_vttk-tknum BINARY SEARCH.
  IF sy-subrc = 0.
    "Read LIPS to get source document
    IF gw_lips-vbeln = gw_vttp-vbeln.
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
```

---

## 6. Error Handling

### 6.1 Error Handling Strategy
- **No exceptions raised**: All errors are handled silently
- **Graceful degradation**: If any step fails, railyard fields remain blank
- **Continue processing**: Standard processing continues regardless of railyard logic outcome

### 6.2 Specific Error Scenarios

| **Scenario** | **Handling** |
|--------------|--------------|
| Configuration not found | Skip entire logic, fields remain blank |
| TTDS entry not found | Skip eligibility check, fields remain blank |
| Route not found in EKPV/VBAP | Skip route determination, fields remain blank |
| ZSCM_CHAINSHIP entry not found | Use original route, continue to TVRAB read |
| FM Z_SCM_MULTIMODE_ROUTE fails | Use original route, continue to TVRAB read |
| TVRAB entry not found | Fields remain blank, continue processing |

---

## 7. Performance Considerations

### 7.1 Data Fetching Optimization
- **Initial fetch**: Configuration data (`ZLOG_EXEC_VAR`) fetched once before main loop
- **TTDS data**: Already fetched in existing code (line ~488), reuse `lt_ttds`
- **EKPV/VBAP**: Single record SELECT statements (acceptable for loop processing)
- **ZSCM_CHAINSHIP**: Single record SELECT per shipment
- **TVRAB**: Single record SELECT per shipment

### 7.2 Index Usage
- Ensure proper indexes exist on:
  - `ZLOG_EXEC_VAR`: `MANDT`, `NAME`, `ACTIVE`, `BUKRS`
  - `EKPV`: `MANDT`, `EBELN`
  - `VBAP`: `MANDT`, `VBELN`
  - `ZSCM_CHAINSHIP`: `MANDT`, `SHNUMBER`
  - `TVRAB`: `MANDT`, `ROUTE`, `VSART`

---

## 8. Testing Strategy

### 8.1 Unit Testing Scenarios

| **Test Case** | **Input** | **Expected Output** |
|---------------|-----------|---------------------|
| TC1: Eligible BUKRS with valid route | BUKRS in config, valid route in EKPV | Railyard fields populated |
| TC2: Eligible BUKRS, route from VBAP | BUKRS in config, route in VBAP | Railyard fields populated |
| TC3: Eligible BUKRS with chain shipment | BUKRS in config, chain shipment exists | Multimodal route used, fields populated |
| TC4: Non-eligible BUKRS | BUKRS not in config | Fields remain blank |
| TC5: Route not found | No route in EKPV/VBAP | Fields remain blank |
| TC6: TVRAB entry not found | Route exists but no TVRAB entry | Fields remain blank |
| TC7: FM call failure | Z_SCM_MULTIMODE_ROUTE fails | Original route used, continue processing |

### 8.2 Integration Testing
- Test with actual TO Push scenarios
- Verify rate check receives populated railyard fields
- Validate no performance degradation

---

## 9. Code Review Checklist

- [ ] All variables declared with proper types
- [ ] Error handling implemented (no exceptions raised)
- [ ] Performance optimized (minimal database calls)
- [ ] Code follows existing FM coding standards
- [ ] Comments added for BOC/EOC markers
- [ ] No hardcoded values (constants used)
- [ ] Proper use of BINARY SEARCH where applicable
- [ ] Client-specific SELECT statements used

---

## 10. Deployment Notes

### 10.1 Prerequisites
- Configuration entry in `ZLOG_EXEC_VAR`:
  - `NAME = 'ZSCM_GET_RAIL_LOCATION'`
  - `ACTIVE = 'X'`
  - `BUKRS = [Company Code]`
- Function Module `Z_SCM_MULTIMODE_ROUTE` must be available and functional

### 10.2 Post-Deployment
- Verify configuration is maintained correctly
- Monitor performance impact
- Validate railyard fields are populated in test scenarios

---

## 11. Appendix

### 11.1 Related Objects
- **Function Module**: `Z_SCM_SOLIDS_OB_GETDET`
- **Function Module**: `Z_SCM_MULTIMODE_ROUTE`
- **Tables**: `ZLOG_EXEC_VAR`, `TTDS`, `VTTP`, `LIPS`, `EKPV`, `VBAP`, `ZSCM_CHAINSHIP`, `TVRAB`
- **Structure**: `ZSCE_CN_DATA` (contains `RAILYARDSOURCELOCATION`, `RAILYARDDESTINATION`)

### 11.2 Change History

| **Version** | **Date** | **Author** | **Description** |
|-------------|----------|------------|-----------------|
| 1.0 | [Date] | [Author] | Initial Technical Specification |

---

**End of Document**

