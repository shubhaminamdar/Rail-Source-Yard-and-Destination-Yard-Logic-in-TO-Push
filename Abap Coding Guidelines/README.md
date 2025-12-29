# Cursor Rules Organization

This workspace contains rules for SAP ABAP development targeting **SAP ECC 6.0 / NetWeaver 7.31**.

## Rule Organization

All rules are located at the root level of `.cursor/rules/` and are organized by numbered prefixes (00-99) for logical grouping.

## BRD → FS Conversion Rules

**Purpose**: Convert Business Requirements Documents (BRD) to Function Specifications (FS)

- `brd-to-fs-conversion.mdc` - Main rule for BRD to FS conversion
  - Validates BRD completeness
  - Maps BRD sections to FS format
  - Generates well-formatted FS documents
  - Asks for missing sections if BRD is incomplete
  - Translates business terminology to technical requirements

**When to use**: When you have a BRD and need to create a Function Specification

## ABAP Development Rules (Numbered 00-99)

**Purpose**: Guide ABAP code generation and ensure compliance with SAP ECC 6.0 / NetWeaver 7.31 standards

These rules are automatically applied when working with ABAP files (`.abap`, `.prog.abap`, `.clas.abap`, `.fugr.abap`, `.intf.abap`).

### Core Rules (00-09)
- `00-main.mdc` - Core ABAP Development Principles (always applied)
  - Object-oriented by default (mandatory)
  - NetWeaver 7.31 compatibility requirements
  - Code quality standards
- `01-compatibility.mdc` - NetWeaver 7.31 Compatibility Rules
- `02-naming.mdc` - ABAP Naming Conventions and Standards
- `03-database.mdc` - Database Access and Performance Rules
- `04-oop.mdc` - Object-Oriented Programming and Class Design Rules
- `05-exceptions.mdc` - Exception Handling Rules for NetWeaver 7.31
- `06-security.mdc` - Security and Authorization Rules
- `07-ui.mdc` - User Interface Guidelines (Selection Screen and ALV)
- `08-testing.mdc` - Testing and Quality Assurance Rules
- `09-enhancements.mdc` - Enhancement and Modification Rules

### Integration & Interface Rules (10-11)
- `10-rfc-webservices.mdc` - RFC and Web Service Standards
- `11-interfaces-api.mdc` - Interface and API Design Standards

### Documentation & Standards (12-14)
- `12-documentation.mdc` - Documentation and Comments Standards
- `13-sy-subrc.mdc` - SY-SUBRC Check Requirements
- `14-transport.mdc` - Package and Transport Management Rules

### Processing & Data Rules (15-16)
- `15-batch-processing.mdc` - Background Job and Batch Processing Rules
- `16-transactions-data.mdc` - Transactions and Data Safety Rules

### Program Structure Rules (17-18)
- `17-reports-structure.mdc` - Reports and Program Structure Standards
- `18-module-pool.mdc` - Module Pool and Dynpro Program Standards

### Quality & Code Generation (19-20)
- `19-review.mdc` - Code Review Behavior and Standards
- `20-code-generation-checklist.mdc` - Code Generation Checklist (Performance and Best Practices)

### Reference (99)
- `99-reference.mdc` - Quick Reference Guide and Code Templates

## Workflow

1. **BRD → FS**: Use `brd-to-fs-conversion.mdc` to convert BRD to FS
2. **FS → ABAP Code**: Use numbered rules (00-99) to generate production-ready ABAP code from FS
   - Core rules (00-09) ensure fundamental compliance
   - Specialized rules (10-20) handle specific scenarios
   - Reference (99) provides templates and quick patterns

## Rule Application

- **Always Applied**: `00-main.mdc` and `brd-to-fs-conversion.mdc` are always active
- **Context-Based**: Other rules apply based on file types (ABAP files trigger ABAP rules)
- **Priority**: Rules are numbered for priority (lower numbers = higher priority)

