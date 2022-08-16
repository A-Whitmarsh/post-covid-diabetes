## =============================================================================
## Project: Post covid events
##
## Purpose: Construct figures to illustrate results from cox model analysis
## 
## Authors: Kurt Taylor
## 
## Content: 
## 0. Load relevant libraries and read data/arguments
## 
## =============================================================================

# 0. Libraries ------------------------------------------------------------

packages <- c("dplyr", "scales", "ggplot2", "readr", "data.table", "tidyverse",
              "vcd", "gridExtra", "cowplot", "grid", "png")
lapply(packages, require, character.only=T)
rm(list = ls())

# 1. Set directories ------------------------------------------------------

dir <- ("~/Library/CloudStorage/OneDrive-UniversityofBristol/ehr_postdoc/projects/post-covid-diabetes")
setwd(dir)

results_dir <- paste0("/Users/kt17109/OneDrive - University of Bristol/Documents - grp-EHR/Projects/post-covid-diabetes/delta/OS-outputs-01-08-2022/model/")
venn_res <- paste0("/Users/kt17109/OneDrive - University of Bristol/Documents - grp-EHR/Projects/post-covid-diabetes/delta/OS-outputs-01-08-2022/descriptives/")
output_dir <- paste0("/Users/kt17109/OneDrive - University of Bristol/Documents - grp-EHR/Projects/post-covid-diabetes/preliminary-results-circulation-jul22/combined-results-report/results-folder-for-report/")

# DEFINE COHORTS ----------------------------------------------------------

cohorts <- c("prevax", "vax", "unvax")

# ------------------------------------######## ------------------------------------#######
# GENERATE VENN DIAGRAMS --------------------------------------------------
# ------------------------------------######## ------------------------------------#######

# source("analysis/figures/external_venn_script.R")
# 
# for(i in cohorts){
#   generate_venns(i)
# }

# ------------------------------------######## ------------------------------------#######
# FIGURE 1: GENERATE MAIN COX FIGURE FOR ALL THREE COHORTS ---------------------------------------
# ------------------------------------######## ------------------------------------#######

# Firstly for vax / unvax
source("analysis/figures/cox-figure-scripts/fig1-all-cohorts-outcomes.R")

for(i in cohorts){
  main_figures_1(i)
}

# CONSTRUCT FIGURE 1

# prevax
prevax_t2dm <- readPNG(paste0(output_dir, "Figure1_prevax_t2dm_reduced.png"))
prevax_t2dm <- rasterGrob(prevax_t2dm)

# vax
vax_t2dm <- readPNG(paste0(output_dir, "Figure1_vax_t2dm_reduced.png"))
vax_t2dm <- rasterGrob(vax_t2dm)

# unvax
unvax_t2dm <- readPNG(paste0(output_dir, "Figure1_unvax_t2dm_reduced.png"))
unvax_t2dm <- rasterGrob(unvax_t2dm)

# TYPE 2 DIABETES ONLY REDUCED TIME POINTS 

png(paste0(output_dir,"Figure1_T2DM_Reduced.png"),
    units = "mm", width=180, height=110, res = 1000)
grid.arrange(arrangeGrob(prevax_t2dm,top=textGrob("Pre-vaccinated Cohort", gp = gpar(fontsize = 8)),   
                         ncol=1),
             arrangeGrob(vax_t2dm,top=textGrob("Vaccinated Cohort", gp = gpar(fontsize = 8)), 
                         ncol=1), 
             arrangeGrob(unvax_t2dm,top=textGrob("Unvaccinated Cohort", gp = gpar(fontsize = 8)),
                         ncol=1), ncol = 3)
dev.off()

# ------------------------------------######## ------------------------------------#######
# FIGURE 2: TYPE-2 DIABETES SUBGROUPS --------------------------------------------------------------
# ------------------------------------######## ------------------------------------#######
# col per cohort, row per subgroup (max time points available for all cats in subgroup), exclude overall (6x3 panel figure)

test_vax <- figure2_subgroup("vax")
test_unvax <- figure2_subgroup("unvax")



png(paste0(output_dir,"hello.png"),
    units = "mm", width=120, height=180, res = 1000)
ggpubr::ggarrange(test_vax, test_unvax, ncol=2, nrow=1, common.legend = TRUE, legend="bottom")
dev.off() 

# ------------------------------------######## ------------------------------------#######
# FIGURE 3: ABSOLUTE EXCESS RISK  --------------------------------------------------------------
# ------------------------------------######## ------------------------------------#######



# ------------------------------------######## ------------------------------------#######
# DIABETES FLOW CHARTS  --------------------------------------------------------------
# ------------------------------------######## ------------------------------------#######

prevax_flow <- readPNG(paste0(output_dir, "diabetes_flow_prevax.png"))
prevax_flow <- rasterGrob(prevax_flow)

vax_flow <- readPNG(paste0(output_dir, "diabetes_flow_vax.png"))
vax_flow <- rasterGrob(vax_flow)

unvax_flow <- readPNG(paste0(output_dir, "diabetes_flow_unvax.png"))
unvax_flow <- rasterGrob(unvax_flow)

png(paste0(output_dir,"diabetes_flow_charts_all_cohorts.png"),
    units = "mm", width=170, height=55, res = 1000)
grid.arrange(arrangeGrob(prevax_flow,top=textGrob("Pre-vaccinated Cohort", gp = gpar(fontsize = 5)),   
                         ncol=1),
             arrangeGrob(vax_flow,top=textGrob("Vaccinated Cohort", gp = gpar(fontsize = 5)), 
                         ncol=1), 
             arrangeGrob(unvax_flow,top=textGrob("Unvaccinated Cohort", gp = gpar(fontsize = 5)),
                         ncol=1), ncol = 3)
dev.off()