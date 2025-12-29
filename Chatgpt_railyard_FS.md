**Functional Specification**

**Enhancement to FM Z_SCM_SOLIDS_OB_GETDET**

**Railyard Source & Destination Determination during TO Push**

**1. Document Control**

  -----------------------------------------------------------------------
  **Item**                 **Details**
  ------------------------ ----------------------------------------------
  Module                   SCM / SD / MM

  Object Type              Function Module Enhancement

  Function Module          Z_SCM_SOLIDS_OB_GETDET

  Process                  TO Push -- Rate Check

  Author                   

  Date                     

  Version                  1.0
  -----------------------------------------------------------------------

**2. Business Background**

During **TO Push**, a rate check is triggered for outbound shipments.
Currently, the fields:

-   **RAILYARDSOURCELOCATION**

-   **RAILYARDDESTINATION**

are passed as **blank**, resulting in incorrect or incomplete rate
determination.

These fields must be populated based on shipment, delivery, purchasing,
and route determination logic so that rail-specific rate calculation
works correctly.

**3. Problem Statement**

-   FM **Z_SCM_SOLIDS_OB_GETDET** populates structure **ET_SOB_CN_DATA**

-   During TO Push, the following fields are not populated:

    -   ET_SOB_CN_DATA-RAILYARDSOURCELOCATION

    -   ET_SOB_CN_DATA-RAILYARDDESTINATION

-   This causes rate check failures or incorrect rating for rail
    shipments.

**4. Proposed Solution Overview**

Enhance FM **Z_SCM_SOLIDS_OB_GETDET** to populate
**RAILYARDSOURCELOCATION** and **RAILYARDDESTINATION** conditionally
during TO Push by:

-   Validating company code eligibility via configuration table
    **ZLOG_EXEC_VAR**

-   Deriving route information from delivery or purchase documents

-   Determining multimodal route using custom FM
    **Z_SCM_MULTIMODE_ROUTE**

-   Fetching railyard source and destination from standard table
    **TVRAB**

**5. Scope of Change**

**In Scope**

-   Enhancement logic inside FM **Z_SCM_SOLIDS_OB_GETDET**

-   Population of railyard fields in **ET_SOB_CN_DATA**

-   Applicable only during **TO Push**

**Out of Scope**

-   Any change to rate calculation logic

-   Any UI or report changes

-   Any change to existing table structures

**6. Functional Requirements**

**6.1 Eligibility Check (Configuration Driven)**

1.  Read table **ZLOG_EXEC_VAR**

    -   Input:

        -   NAME = \'ZSCM_GET_RAIL_LOCATION\'

        -   ACTIVE = \'X\'

    -   Output:

        -   One or more BUKRS

2.  Read table **TTDS**

    -   Input:

        -   TPLST = VTTK-TPLST

    -   Output:

        -   BUKRS

3.  Compare:

    -   TTDS-BUKRS vs ZLOG_EXEC_VAR-BUKRS

    -   **If match found → proceed**

    -   **If no match → skip entire railyard logic**

**6.2 Document & Route Determination Logic**

4.  Read table **VTTP**

    -   Input:

        -   TKNUM = VTTK-TKNUM

    -   Output:

        -   VBELN

5.  Read table **LIPS**

    -   Input:

        -   VBELN = VTTP-VBELN

    -   Output:

        -   VGBEL

6.  Determine Route:

    -   First attempt:

        -   Table: **EKPV**

        -   Input: EBELN = LIPS-VGBEL

        -   Output: ROUTE

    -   If no entry found in **EKPV**:

        -   Table: **VBAP**

        -   Input: VBELN = LIPS-VGBEL

        -   Output: VBAP-ROUTE

**6.3 Chain Shipment & Multimodal Route Logic**

7.  Read table **ZSCM_CHAINSHIP**

    -   Input:

        -   SHNUMBER = VTTK-TKNUM

    -   Output:

        -   CHAINID

        -   ODPAIRID

8.  Call FM **Z_SCM_MULTIMODE_ROUTE**

    -   Importing:

        -   I_CHAINID = ZSCM_CHAINSHIP-CHAINID

        -   I_ODPAIRID = ZSCM_CHAINSHIP-ODPAIRID

        -   I_ROUTE = EKPV-ROUTE / VBAP-ROUTE

    -   Exporting:

        -   E_TVRAB (Route Code)

**6.4 Railyard Source & Destination Determination**

9.  Read table **TVRAB**

    -   Input:

        -   VSART = VTTK-VSART

        -   ROUTE = E_TVRAB

    -   Output:

        -   KNANF (Railyard Source)

        -   KNEND (Railyard Destination)

10. Populate output structure **ET_SOB_CN_DATA** before appending:

gw_cn_data-railyardsourcelocation = tvrab-knanf.

gw_cn_data-railyarddestinationlocation = tvrab-knend.

**7. Error Handling & Fallback Logic**

-   If any intermediate step fails (e.g., missing route, missing TVRAB
    entry):

    -   Do not raise an error

    -   Leave railyard fields blank

    -   Continue standard processing

-   No update or commit required

**8. Assumptions**

-   Configuration in **ZLOG_EXEC_VAR** is maintained correctly

-   FM **Z_SCM_MULTIMODE_ROUTE** returns a valid route code when inputs
    are correct

-   TO Push context is identifiable within FM **Z_SCM_SOLIDS_OB_GETDET**
