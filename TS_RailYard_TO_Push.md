## Technical Specification Document

### Enhancement to FM `Z_SCM_SOLIDS_OB_GETDET`  
### Rail Yard Source & Destination Determination during TO Push (Rate Check)

---

## 1. Document Control

| **Item**           | **Details**                                      |
|--------------------|--------------------------------------------------|
| **System**         | SAP ECC / S/4 (SCM / SD / TM interface)         |
| **Object Type**    | Function Module Enhancement                     |
| **Function Module**| `Z_SCM_SOLIDS_OB_GETDET`                        |
| **Process**        | TO Push – Rate Check                            |
| **Version**        | 1.0                                             |
| **Date**           | [To be filled]                                  |
| **Prepared By**    | [To be filled]                                  |

---

## 2. Technical Overview

### 2.1 Purpose

Enhance function module `Z_SCM_SOLIDS_OB_GETDET` so that during TO Push, the CN data output (`ET_SOB_CN_DATA`) contains:

- `RAILYARDSOURCELOCATION`
- `RAILYARDDESTINATIONLOCATION`

These fields must be derived for **rail shipments** using configuration and chain-shipment data so that TO Push rate check can determine correct freight rates.

### 2.2 Scope

- **In Scope**
  - Enhancement in FM `Z_SCM_SOLIDS_OB_GETDET`
  - Logic to derive and populate:
    - `ET_SOB_CN_DATA-RAILYARDSOURCELOCATION`
    - `ET_SOB_CN_DATA-RAILYARDDESTINATIONLOCATION`
  - Logic executed only:
    - During TO Push scenario (existing usage of this FM)
    - When configuration and company code conditions are satisfied
- **Out of Scope**
  - Changes to rate determination algorithms
  - Changes to pricing condition records
  - UI/reporting changes
  - Structural change of CN data table type

### 2.3 Impacted Areas

- **Function Module**: `Z_SCM_SOLIDS_OB_GETDET` (file `OB_Solid.md`)
- **Data Structures**:
  - CN data structure type `ZSCE_CN_DATA` / table type `ZSCE_CN_DATA_T`
- **Tables / Objects** (read-only):
  - `ZLOG_EXEC_VAR`
  - `TTDS`
  - `ZSCM_CHAINSHIP`
  - `VTTK`
  - `TVRAB`

---

## 3. Existing Logic (As-Is) – High Level

- FM reads shipment (`VTTK`), delivery (`LIPS` / `LIKP`), billing (`VBRK` / `VBRP`), and configuration (`ZLOG_EXEC_VAR`, etc.) to build:
  - `ET_SOB_HEADER_DATA`
  - `ET_SOB_CN_DATA`
  - `ET_SOB_CUST_DOC_DATA`
- For CN data (`ET_SOB_CN_DATA`), it already derives:
  - Shipment number, CN number, LR details
  - Source/destination location and state (primarily via `TVRAB`, `LIKP`, `KNA1`, `ADRC`)
- **Currently**, fields:
  - `RAILYARDSOURCELOCATION`
  - `RAILYARDDESTINATIONLOCATION`
  are **not** populated; they remain initial.

---

## 4. To-Be Logic Overview

The enhancement will:

- Use configuration (`ZLOG_EXEC_VAR`, name `ZSCM_GET_RAIL_LOCATION`) to decide **for which company codes / transport modes** the logic is active.
- Use `TTDS` to derive **company code from transportation planning point** (`TPLST`).
- Use `ZSCM_CHAINSHIP` and `VTTK` to identify the **relevant rail segment and route**.
- Use `TVRAB` to derive **rail yard source/destination** from route and mode.
- Populate:
  - `gw_cn_data-railyardsourcelocation`
  - `gw_cn_data-railyarddestinationlocation`
  before appending the record to `ET_SOB_CN_DATA`.

Error tolerance: if any step fails, CN row is still created but railyard fields remain blank.

---

## 5. Data Structures & Variables

### 5.1 New Local Types

To align with ABAP naming conventions (local types `lty_`):

```abap
" BEGIN: Cursor Generated Code
TYPES: BEGIN OF lty_zlog_rail_loc,
         mandt TYPE mandt,
         name  TYPE rvari_vnam,
         active TYPE zactive_flag,
         bukrs TYPE bukrs,
         vsart TYPE vsart,      " Transport mode / mode of transport
       END OF lty_zlog_rail_loc,

       BEGIN OF lty_chain_shp,
         shnumber TYPE tknum,
         chainid  TYPE zchain_id,
         odpairid TYPE zodpair_id,
         trmode   TYPE vsart,
       END OF lty_chain_shp,

       BEGIN OF lty_tvrab_rail,
         route TYPE route,
         vsart TYPE vsart,
         knanf TYPE knota,
         knend TYPE knotz,
       END OF lty_tvrab_rail.
" END: Cursor Generated Code
```

### 5.2 New Local Variables

```abap
" BEGIN: Cursor Generated Code
DATA: lt_zlog_rail_loc TYPE TABLE OF lty_zlog_rail_loc,
      lw_zlog_rail_loc TYPE lty_zlog_rail_loc,
      lw_chain_shp     TYPE lty_chain_shp,
      lw_tvrab_rail    TYPE lty_tvrab_rail,
      lv_rail_bukrs    TYPE bukrs,
      lv_rail_vsart    TYPE vsart,
      lv_rail_route    TYPE route,
      lv_rail_active   TYPE abap_bool.
" END: Cursor Generated Code
```

### 5.3 New Constant

```abap
" BEGIN: Cursor Generated Code
CONSTANTS: lc_rail_loc_config TYPE rvari_vnam VALUE 'ZSCM_GET_RAIL_LOCATION'.
" END: Cursor Generated Code
```

---

## 6. Code Placement

### 6.1 Declarations

- **Location**: Top declaration section of FM `Z_SCM_SOLIDS_OB_GETDET` in `OB_Solid.md`
- **Placement**:
  - New `TYPES` (`lty_zlog_rail_loc`, `lty_chain_shp`, `lty_tvrab_rail`) added after existing type declarations (around existing local `TYPES` for z-log or Naroda logic).
  - New `DATA` and `CONSTANTS` added in existing data declaration block (after similar ZLOG / TTDS-related data and constants).

### 6.2 Initial Configuration Fetch

- **Location**: After shipments and TTDS-related data are loaded and sorted, before CN loop starts (just before `"---->CN data processing"` or at the beginning of CN processing section).
- **Purpose**: Read configuration for all relevant company codes and modes once.

### 6.3 Main Rail Yard Logic

- **Location**: Inside the CN data processing loop, where `gw_cn_data` is being filled (within `LOOP AT gt_vttk INTO gw_vttk. ... LOOP AT gt_yttstx0002 INTO gw_yttstx0002_t FROM lw_index.`).
- **Placement**: After generic source/destination fields for CN are filled (using `TVRAB` / `LIKP`), but **before** `APPEND gw_cn_data TO et_sob_cn_data`.

---

## 7. Detailed Technical Logic

### 7.1 Step 1 – Read Configuration (`ZLOG_EXEC_VAR`)

**One-time read before CN loop:**

```abap
" BEGIN: Cursor Generated Code
CLEAR lt_zlog_rail_loc[].
SELECT mandt
       name
       active
       bukrs
       vsart
  FROM zlog_exec_var
  CLIENT SPECIFIED
  INTO TABLE lt_zlog_rail_loc
  WHERE mandt = sy-mandt
    AND name  = lc_rail_loc_config
    AND active = abap_true.
IF sy-subrc = 0.
  SORT lt_zlog_rail_loc BY bukrs vsart.
ENDIF.
" END: Cursor Generated Code
```

### 7.2 Step 2 – Determine Company Code from `TTDS` (Per Shipment)

Inside CN loop (per `gw_vttk`):

```abap
" BEGIN: Cursor Generated Code
CLEAR: lv_rail_bukrs, lv_rail_vsart, lv_rail_route, lv_rail_active.
lv_rail_active = abap_false.

" Derive BUKRS from TPLST via TTDS (lt_ttds already filled in existing logic)
READ TABLE lt_ttds INTO lw_ttds
  WITH KEY tplst = gw_vttk-tplst
  BINARY SEARCH.
IF sy-subrc = 0.
  lv_rail_bukrs = lw_ttds-bukrs.
ENDIF.
" END: Cursor Generated Code
```

### 7.3 Step 3 – Company Code & Mode Validation (Config Match)

```abap
" BEGIN: Cursor Generated Code
IF lv_rail_bukrs IS NOT INITIAL
   AND lt_zlog_rail_loc IS NOT INITIAL.

  " Check if any config entry matches BUKRS + VSART (rail mode)
  READ TABLE lt_zlog_rail_loc INTO lw_zlog_rail_loc
    WITH KEY bukrs = lv_rail_bukrs
             vsart = gw_vttk-vsart
    BINARY SEARCH.
  IF sy-subrc = 0.
    lv_rail_vsart  = lw_zlog_rail_loc-vsart.
    lv_rail_active = abap_true.
  ENDIF.
ENDIF.
" END: Cursor Generated Code
```

### 7.4 Step 4 – Retrieve Chain Shipment Details (`ZSCM_CHAINSHIP`)

```abap
" BEGIN: Cursor Generated Code
IF lv_rail_active = abap_true.
  CLEAR lw_chain_shp.
  SELECT SINGLE shnumber
                 chainid
                 odpairid
                 trmode
    FROM zscm_chainship
    CLIENT SPECIFIED
    INTO lw_chain_shp
    WHERE mandt   = sy-mandt
      AND shnumber = gw_vttk-tknum.
  IF sy-subrc = 0
     AND lw_chain_shp-chainid IS NOT INITIAL
     AND lw_chain_shp-odpairid IS NOT INITIAL
     AND lw_chain_shp-trmode = lv_rail_vsart.
    " chain data is valid, continue
  ELSE.
    " no valid chain data for rail; skip railyard logic
    lv_rail_active = abap_false.
  ENDIF.
ENDIF.
" END: Cursor Generated Code
```

### 7.5 Step 5 – Identify Rail Shipment & Route (`VTTK`)

```abap
" BEGIN: Cursor Generated Code
IF lv_rail_active = abap_true.
  IF gw_vttk-route IS NOT INITIAL.
    lv_rail_route = gw_vttk-route.
  ELSE.
    " No route -> cannot derive railyard locations
    lv_rail_active = abap_false.
  ENDIF.
ENDIF.
" END: Cursor Generated Code
```

### 7.6 Step 6 – Retrieve Rail Yard from `TVRAB`

```abap
" BEGIN: Cursor Generated Code
IF lv_rail_active = abap_true
   AND lv_rail_route IS NOT INITIAL.

  CLEAR lw_tvrab_rail.
  SELECT SINGLE route
                 vsart
                 knanf
                 knend
    FROM tvrab
    CLIENT SPECIFIED
    INTO lw_tvrab_rail
    WHERE mandt = sy-mandt
      AND route = lv_rail_route
      AND vsart = gw_vttk-vsart.
  IF sy-subrc = 0
     AND lw_tvrab_rail-knanf IS NOT INITIAL
     AND lw_tvrab_rail-knend IS NOT INITIAL.
    gw_cn_data-railyardsourcelocation      = lw_tvrab_rail-knanf.
    gw_cn_data-railyarddestinationlocation = lw_tvrab_rail-knend.
  ENDIF.
ENDIF.
" END: Cursor Generated Code
```

### 7.7 Step 7 – Populate Output

- This logic must execute **before**:

```abap
APPEND gw_cn_data TO et_sob_cn_data.
```

---

## 8. Error Handling & Assumptions

### 8.1 Error Handling Strategy

- No `MESSAGE`, no exceptions, no `RETURN` specific to this logic.
- Failures in any step:
  - Config not found
  - TTDS not found
  - Chain shipment not found or not rail
  - Route missing
  - No matching `TVRAB` entries  
  → Result: `gw_cn_data-railyardsourcelocation` and `gw_cn_data-railyarddestinationlocation` remain initial.

### 8.2 Assumptions

- **Configuration** table `ZLOG_EXEC_VAR` is maintained with:
  - `NAME = 'ZSCM_GET_RAIL_LOCATION'`
  - `ACTIVE = 'X'`
  - `BUKRS` and `VSART` maintained according to business rules.
- Table `TTDS` already read into `lt_ttds` as in existing logic; we reuse it.
- Table `ZSCM_CHAINSHIP` is the authoritative source for chain and transport mode.
- `VTTK-ROUTE` for shipment `TKNUM` is the route relevant for rail yard derivation.
- No changes to data dictionary objects.

---

## 9. Performance Considerations

- **Configuration read**:
  - `ZLOG_EXEC_VAR` (rail config) is read **once** into `lt_zlog_rail_loc`.
- **Per-shipment processing**:
  - `READ TABLE lt_ttds` – table is already in memory and sorted.
  - `SELECT SINGLE` from `ZSCM_CHAINSHIP` – 1 row per shipment.
  - `SELECT SINGLE` from `TVRAB` – 1 row per shipment.
- No `SELECT` inside tight nested loops beyond existing CN loop; all new DB calls are **per-shipment**, not per CN-line.

Expected indexes:

- `ZLOG_EXEC_VAR`: `(MANDT, NAME, ACTIVE, BUKRS, VSART)`
- `TTDS`: `(MANDT, TPLST)`
- `ZSCM_CHAINSHIP`: `(MANDT, SHNUMBER, TRMODE)`
- `TVRAB`: `(MANDT, ROUTE, VSART)`

---

## 10. ABAP Guideline Compliance

- **Naming**:
  - Local variables use `lv_`, `lt_`, `lw_`; types use `lty_` (per `02-naming.mdc`).
- **Database access**:
  - No `SELECT *`.
  - Structures match selected columns and order.
  - `sy-subrc` checked immediately after `SELECT` and `READ TABLE`.
- **Enhancement style**:
  - No `COMMIT WORK` or exits; no disruption of main flow.
- **Documentation**:
  - New code blocks marked with `" BEGIN: Cursor Generated Code` / `" END: Cursor Generated Code`.

---

## 11. Testing Strategy

### 11.1 Unit Test Scenarios

| **Test Case** | **Input / Setup** | **Expected Result** |
|---------------|-------------------|---------------------|
| TC1 | Config exists for BUKRS & VSART; chain & TVRAB records present | Rail yard source & destination populated |
| TC2 | Config missing for BUKRS | Rail yard fields blank; CN row still created |
| TC3 | Chain shipment missing | Rail yard fields blank |
| TC4 | Route missing in VTTK | Rail yard fields blank |
| TC5 | TVRAB entry missing | Rail yard fields blank |
| TC6 | Non-rail mode (VSART not in config) | Railyard logic skipped; fields blank |

### 11.2 Integration Testing

- Execute TO Push end-to-end in QA with rail shipments:
  - Validate that rate check receives populated rail yard fields.
  - Confirm no dumps or performance degradation.
- Negative testing with missing / partial configuration to ensure graceful behavior.

---

## 12. Change History

| **Version** | **Date**   | **Author**   | **Description**                                     |
|-------------|------------|--------------|-----------------------------------------------------|
| 1.0         | [To fill]  | [To fill]    | Initial Technical Specification for railyard logic |

---

**End of Document**


