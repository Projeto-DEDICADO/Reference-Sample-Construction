# 📦 DEDICADO - Reference Sample System

**Module for Multi-Source Alert Harmonization and Reference Dataset Construction.**

---

## 📖 Overview

The **Reference Sample System** is the core data engineering module of the DEDICADO project. It is designed to ingest, standardize, and intersect forest disturbance alerts from multiple monitoring programs. By spatializing and overlapping these diverse sources, the system generates a high-confidence "ground truth" table used to train and validate future detection algorithms.



## 🛠️ Data Harmonization

Each monitoring system uses different geometries, attributes, and temporal scales. This module standardizes them into a unified format before any spatial analysis:

* **Projection:** All data is reprojected to match the **DETER Grid** CRS.
* **Temporal Normalization:** Systems like **GLAD** and **MapBiomas** have their internal codes (e.g., `20`, `2019`) mapped to standard year strings (`"2020"`, `"Before 2020"`).
* **Geometry Cleaning:** Uses `st_cast("POLYGON")` to ensure consistency during spatial unions and intersections.

## 🔄 The Processing Pipeline

The system follows a rigorous spatial logic implemented in **R**:

1.  **Grid Partitioning:** Uses the `deter_regions.shp` to divide the study area into manageable processing units (tiles).
2.  **Spatial Intersection:** For every tile, the system extracts the exact portion of alerts from:
    * **Official Systems:** PRODES and DETER (Current and Historical).
    * **Independent Systems:** GLAD, RADD, MapBiomas, TropiSCO, and SAD.
3.  **Cross-Platform Metrics:** It calculates the area of agreement between different sensor types (e.g., Optical vs. SAR) and identifies areas where systems diverge.
4.  **Automated Logging:** The system iteratively updates `tabela.csv`, allowing the process to be resumed if interrupted.

## 💻 Tech Stack

* **R Language**: Core processing.
* **sf**: Vector operations and geometric predicates (`st_intersection`, `st_union`, `st_difference`).
* **tidyterra & tidyverse**: Data orchestration and attribute manipulation.

## 🚀 How to Run

1.  Place your raw shapefiles in `/01_Pre_processing`.
2.  Ensure the DETER grid is in `/02_Data/tiling/`.
3.  Run the main script. The loop is indexed to allow resuming:
    ```r
    for (i in starting_index:length(deter_grid$id)) { ... }
    ```

---
**Part of the DEDICADO System** | [Main Repository](https://github.com/your-repo-link)
