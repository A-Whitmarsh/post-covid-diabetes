# CREATE TABLE 1A FOR POST-COVID-DIABETES MANUSCRIPT

# PARAMETERS

output_dir <- paste0("/Users/kt17109/OneDrive - University of Bristol/Documents - grp-EHR/Projects/post-covid-diabetes/preliminary-results-circulation-jul22/combined-results-report/results-folder-for-report/")

# CLEAN TABLE 1 FUNCTION

clean_table_1 <- function(df) {
  df <- df %>% 
    mutate_at(c("Whole_population","COVID_exposed","COVID_hospitalised", "COVID_non_hospitalised"), as.numeric) %>%
    mutate(COVID_risk_per_100k = (COVID_exposed/Whole_population)*100000) %>%
    mutate_if(is.numeric, round, 0) %>%
    mutate("Number diagnosed with COVID-19 (risk per 100,000)" = paste0(COVID_exposed, " (", COVID_risk_per_100k, ")"),
           "Covariate Level" = Covariate_level,
           "Whole Population" = Whole_population) %>%
    dplyr::select("Covariate", "Covariate Level", "Whole Population", "Number diagnosed with COVID-19 (risk per 100,000)")
}

# READ IN AND FORMAT THE THREE TABLE 1'S

table1_prevax <- read.csv(paste0(output_dir, "Table1_prevax_diabetes.csv"))
table1_vax <- read.csv(paste0(output_dir, "Table1_vax_diabetes.csv"))
table1_unvax <- read.csv(paste0(output_dir, "Table1_unvax_diabetes.csv"))

table1_prevax_format <- clean_table_1(table1_prevax)
table1_vax_format <- clean_table_1(table1_vax)
table1_unvax_format <- clean_table_1(table1_unvax)
# temporary until table 1 code fixed for cholesterol ratio
table1_vax_format <- table1_vax_format[-c(46:52),]
table1_unvax_format <- table1_unvax_format[-c(46:52),]

# CONSTRUCT MAIN TABLE 1

colnames(table1_prevax_format)[3:4] <- paste(colnames(table1_prevax_format)[3:4], "prevax", sep = "_")
colnames(table1_vax_format)[3:4] <- paste(colnames(table1_vax_format)[3:4], "vax", sep = "_")
colnames(table1_unvax_format)[3:4] <- paste(colnames(table1_unvax_format)[3:4], "unvax", sep = "_")

table1_unvax_format$`Covariate Level` <- NULL
table1_unvax_format$Covariate <- NULL
table1_merged <- cbind(table1_vax_format, table1_unvax_format)
table1_prevax_format$`Covariate Level` <- NULL
table1_prevax_format$Covariate <- NULL
table1_merged <- cbind(table1_merged, table1_prevax_format)

# SAVE TABLE 1

write.csv(table1_merged, paste0(output_dir, "Table1_Diabetes_Formatted.csv"), row.names = FALSE)
