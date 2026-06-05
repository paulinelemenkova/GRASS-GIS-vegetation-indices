#!/bin/bash
########################################################################
# GRASS GIS Script: Calculation of Ten Vegetation Indices
# Article: Suivi diachronique de la déforestation sur les plateaux
#          de Bié et Huambo (Angola) par les images Landsat sous
#          GRASS GIS : comparaison statistique et validation Sentinel-2A
# Author:  Polina Lemenkova
# Date:    June 2026
# GRASS GIS version: 8.x
# Data: Landsat 8-9 OLI/TIRS, Level-2 Surface Reflectance (L2SP)
#       Path/Row: 177/070 ; Dates: 2013-07-12 and 2023-07-08
#       Projection: WGS84 / UTM zone 33S (EPSG:32733)
########################################################################

# -----------------------------------------------------------------------
# STEP 1 — GRASS GIS environment setup
# -----------------------------------------------------------------------

# Set the computational region to the study area
# Bié and Huambo plateaus, central Angola
# Extent: 11.5°–15.0° E ; 10.0°–13.5° S ; resolution 30 m
g.region \
    n=-10.0 s=-13.5 \
    e=15.0  w=11.5  \
    res=0.0002778   \
    -p

# Verify imported raster maps
g.list type=rast mapset=PERMANENT

# -----------------------------------------------------------------------
# STEP 2 — RADIOMETRIC CALIBRATION (DN → Surface Reflectance)
# Applied to Landsat 8 (2013) and Landsat 9 (2023)
# Formula: ρλ = Mρ × Q_cal + Aρ
# Mρ and Aρ are read from the _MTL.txt metadata file
# -----------------------------------------------------------------------

# Calibrate Landsat 8 (2013) — all bands used for VI calculation
i.landsat.toar \
    input=LC08_B            \
    output=LC08_2013_toar   \
    metfile=LC08_L2SP_177070_20130712_MTL.txt \
    method=uncorrected      \
    -r

# Calibrate Landsat 9 (2023)
i.landsat.toar \
    input=LC09_B            \
    output=LC09_2023_toar   \
    metfile=LC09_L2SP_177070_20230708_MTL.txt \
    method=uncorrected      \
    -r

# -----------------------------------------------------------------------
# STEP 3 — CLOUD MASKING
# Landsat QA_PIXEL band: bits 3 (cloud shadow) and 4 (cloud)
# Pixels flagged as cloudy are set to NULL
# -----------------------------------------------------------------------

# Create cloud mask from QA_PIXEL band (2013)
r.mapcalc \
    expression="cloud_mask_2013 = \
    if( (LC08_2013_toar.QA_PIXEL >> 3 & 1) || \
        (LC08_2013_toar.QA_PIXEL >> 4 & 1), \
        null(), 1)"

# Apply mask (2013)
r.mask raster=cloud_mask_2013

# Create cloud mask from QA_PIXEL band (2023)
r.mapcalc \
    expression="cloud_mask_2023 = \
    if( (LC09_2023_toar.QA_PIXEL >> 3 & 1) || \
        (LC09_2023_toar.QA_PIXEL >> 4 & 1), \
        null(), 1)"

# Apply mask (2023)
r.mask raster=cloud_mask_2023

# -----------------------------------------------------------------------
# STEP 4 — CALCULATION OF TEN VEGETATION INDICES via i.vi module
# Band assignments for Landsat 8-9 OLI:
#   Blue  (B)   = Band 2  (0.452–0.512 µm)
#   Green (G)   = Band 3  (0.533–0.590 µm)
#   Red   (R)   = Band 4  (0.636–0.673 µm)
#   NIR         = Band 5  (0.851–0.879 µm)
#   SWIR        = Band 7  (2.107–2.294 µm)
# -----------------------------------------------------------------------

# --- 4.1 NDVI : Normalized Difference Vegetation Index ---
# Formula: (NIR - R) / (NIR + R)   [Rouse et al., 1973]
i.vi \
    red=LC08_2013_toar.4   \
    nir=LC08_2013_toar.5   \
    viname=ndvi            \
    output=NDVI_2013

i.vi \
    red=LC09_2023_toar.4   \
    nir=LC09_2023_toar.5   \
    viname=ndvi            \
    output=NDVI_2023

# --- 4.2 DVI : Difference Vegetation Index ---
# Formula: NIR - R   [Richardson & Wiegand, 1977]
i.vi \
    red=LC08_2013_toar.4   \
    nir=LC08_2013_toar.5   \
    viname=dvi             \
    output=DVI_2013

i.vi \
    red=LC09_2023_toar.4   \
    nir=LC09_2023_toar.5   \
    viname=dvi             \
    output=DVI_2023

# --- 4.3 ARVI : Atmospherically Resistant Vegetation Index ---
# Formula: (NIR - (2R - B)) / (NIR + (2R - B))
# [Kaufman & Tanré, 1992]
i.vi \
    red=LC08_2013_toar.4   \
    nir=LC08_2013_toar.5   \
    blue=LC08_2013_toar.2  \
    viname=arvi            \
    output=ARVI_2013

i.vi \
    red=LC09_2023_toar.4   \
    nir=LC09_2023_toar.5   \
    blue=LC09_2023_toar.2  \
    viname=arvi            \
    output=ARVI_2023

# --- 4.4 EVI : Enhanced Vegetation Index ---
# Formula: 2.5 × (NIR - R) / (NIR + 6R - 7.5B + 1)
# [Gurung et al., 2009]
i.vi \
    red=LC08_2013_toar.4   \
    nir=LC08_2013_toar.5   \
    blue=LC08_2013_toar.2  \
    viname=evi             \
    output=EVI_2013

i.vi \
    red=LC09_2023_toar.4   \
    nir=LC09_2023_toar.5   \
    blue=LC09_2023_toar.2  \
    viname=evi             \
    output=EVI_2023

# --- 4.5 GEMI : Global Environmental Monitoring Index ---
# Non-linear index minimising atmospheric influence
# η = (2(NIR²-R²) + 1.5NIR + 0.5R) / (NIR + R + 0.5)
# Formula: η(1 - 0.25η) - (R - 0.125)/(1 - R)
# [Pinty & Verstraete, 1992]
i.vi \
    red=LC08_2013_toar.4   \
    nir=LC08_2013_toar.5   \
    viname=gemi            \
    output=GEMI_2013

i.vi \
    red=LC09_2023_toar.4   \
    nir=LC09_2023_toar.5   \
    viname=gemi            \
    output=GEMI_2023

# --- 4.6 MSAVI2 : Modified Soil-Adjusted Vegetation Index ---
# Formula: (2NIR + 1 - sqrt((2NIR+1)² - 8(NIR-R))) / 2
# [Qi et al., 1994]
i.vi \
    red=LC08_2013_toar.4   \
    nir=LC08_2013_toar.5   \
    viname=msavi2          \
    output=MSAVI2_2013

i.vi \
    red=LC09_2023_toar.4   \
    nir=LC09_2023_toar.5   \
    viname=msavi2          \
    output=MSAVI2_2023

# --- 4.7 NDWI : Normalized Difference Water Index ---
# Formula: (G - NIR) / (G + NIR)   [Gao, 1996]
i.vi \
    green=LC08_2013_toar.3  \
    nir=LC08_2013_toar.5    \
    viname=ndwi             \
    output=NDWI_2013

i.vi \
    green=LC09_2023_toar.3  \
    nir=LC09_2023_toar.5    \
    viname=ndwi             \
    output=NDWI_2023

# --- 4.8 PVI : Perpendicular Vegetation Index ---
# Formula: (NIR - a×R - b) / sqrt(1 + a²)
# Soil line parameters: a = 0.90 ; b = 0.04
# [Wiegand et al., 1991]
i.vi \
    red=LC08_2013_toar.4   \
    nir=LC08_2013_toar.5   \
    viname=pvi             \
    soil_line_slope=0.90   \
    soil_line_intercept=0.04 \
    output=PVI_2013

i.vi \
    red=LC09_2023_toar.4   \
    nir=LC09_2023_toar.5   \
    viname=pvi             \
    soil_line_slope=0.90   \
    soil_line_intercept=0.04 \
    output=PVI_2023

# --- 4.9 GARI : Green Atmospherically Resistant Index ---
# Formula: (NIR - (G - γ(B - R))) / (NIR + (G - γ(B - R)))
# γ = 1.7   [Gitelson et al., 1996]
i.vi \
    red=LC08_2013_toar.4   \
    nir=LC08_2013_toar.5   \
    green=LC08_2013_toar.3 \
    blue=LC08_2013_toar.2  \
    viname=gari            \
    output=GARI_2013

i.vi \
    red=LC09_2023_toar.4   \
    nir=LC09_2023_toar.5   \
    green=LC09_2023_toar.3 \
    blue=LC09_2023_toar.2  \
    viname=gari            \
    output=GARI_2023

# --- 4.10 IPVI : Infrared Percentage Vegetation Index ---
# Formula: NIR / (NIR + R)   [Crippen, 1990]
i.vi \
    red=LC08_2013_toar.4   \
    nir=LC08_2013_toar.5   \
    viname=ipvi            \
    output=IPVI_2013

i.vi \
    red=LC09_2023_toar.4   \
    nir=LC09_2023_toar.5   \
    viname=ipvi            \
    output=IPVI_2023

# -----------------------------------------------------------------------
# STEP 5 — STATISTICAL ANALYSIS OF INDEX DISTRIBUTIONS
# Extract μ, σ, min, max for each index and each date
# -----------------------------------------------------------------------

for INDEX in NDVI DVI ARVI EVI GEMI MSAVI2 NDWI PVI GARI IPVI; do
    echo "=== ${INDEX} 2013 ==="
    r.univar map=${INDEX}_2013 -e
    echo "=== ${INDEX} 2023 ==="
    r.univar map=${INDEX}_2023 -e
done

# -----------------------------------------------------------------------
# STEP 6 — DEFORESTATION QUANTIFICATION
# NDVI threshold θ = 0.35 to classify forest cover
# ΔS = (N_forest_2013 - N_forest_2023) × r²
# r = 30 m (Landsat spatial resolution)
# -----------------------------------------------------------------------

# Binary forest mask 2013 (1 = forest, 0 = non-forest)
r.mapcalc \
    expression="forest_mask_2013 = if(NDVI_2013 >= 0.35, 1, 0)"

# Binary forest mask 2023
r.mapcalc \
    expression="forest_mask_2023 = if(NDVI_2023 >= 0.35, 1, 0)"

# Deforestation map: pixels that were forest in 2013 but not in 2023
r.mapcalc \
    expression="deforestation_2013_2023 = \
    if(forest_mask_2013 == 1 && forest_mask_2023 == 0, 1, 0)"

# Count pixels and compute area (r² = 900 m² = 0.0009 km² per pixel)
r.stats -c input=deforestation_2013_2023 separator="|"
r.report map=deforestation_2013_2023 units=kilometers

# -----------------------------------------------------------------------
# STEP 7 — VISUALISATION
# Display index maps with legend and histogram
# -----------------------------------------------------------------------

# Launch display monitor
d.mon wx0

# Display NDVI 2013 with colour ramp and legend
g.region raster=NDVI_2013
d.rast    map=NDVI_2013
d.legend  raster=NDVI_2013 \
          at=5,50,2,6      \
          range=-1,1        \
          title="NDVI 2013" \
          fontsize=10
d.barscale length=100 units=kilometers at=70,5
d.northarrow at=90,90

# Display NDVI 2023
d.erase
d.rast    map=NDVI_2023
d.legend  raster=NDVI_2023 \
          at=5,50,2,6      \
          range=-1,1        \
          title="NDVI 2023" \
          fontsize=10
d.barscale length=100 units=kilometers at=70,5
d.northarrow at=90,90

# Display deforestation map
d.erase
d.rast    map=deforestation_2013_2023
d.legend  raster=deforestation_2013_2023 \
          at=5,50,2,6 \
          title="Déforestation 2013–2023"
d.barscale length=100 units=kilometers at=70,5
d.northarrow at=90,90

# Export maps to PNG for publication (300 dpi)
d.out.file output=NDVI_2013_map      format=png resolution=300
d.out.file output=NDVI_2023_map      format=png resolution=300
d.out.file output=Deforestation_map  format=png resolution=300

# -----------------------------------------------------------------------
# STEP 8 — REMOVE MASK AND CLEAN UP TEMPORARY MAPS
# -----------------------------------------------------------------------

r.mask -r
g.remove type=rast name=cloud_mask_2013,cloud_mask_2023 -f

echo "Script completed successfully."
########################################################################
# End of script
########################################################################
