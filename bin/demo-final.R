library(tidyverse)
library(magrittr)
library(lubridate)

setwd("/mnt/praxic/udallpilot/dat")

# Import the two data frames
# Main data:
dat1.everyone <- read.csv("RC4_2013-09-16_cleaned_session1and2Merged.csv",
                          stringsAsFactors = FALSE)

# Additional data
dat2.cols <- c("IDNUM", "subject_id", "ageatonset", "cognitive_status")
dat2.everyone <- read.csv("RC4_2014-03-04_cleaned_session1and2Merged.csv",
                          stringsAsFactors = FALSE)[dat2.cols]

# Remove subjects that don't have MR data
subjects <- list.files("../subjects", pattern = "^RC4")
dat1 <- subset(dat1.everyone, IDNUM %in% subjects)
dat2 <- subset(dat2.everyone, IDNUM %in% subjects)

# Remove old dfs
rm(dat1.everyone, dat2.everyone)

# Subset just the columns we need
data.cols <- c("IDNUM",
               "Group", "agevisit", "gender", "sub_hoehn_and_yahr",
               "updrs_new_1_total", "updrs_new_2_total", "updrs_new_3_total",
               "updrs_new_4_total", "moca_score",
               "education_years", "handedness", "collection_date_updrs_new1")

cog.cols <- c("IDNUM", "Group",
              "moca_score",
              "draw_clock_contour","draw_clock_numbers", "draw_clock_hands",
                "draw_clock_1", "draw_clock_2","draw_clock_4", "draw_clock_5",
                "draw_clock_7", "draw_clock_8", "draw_clock_11",
                "draw_clock_12", "draw_clock_short_hand",
                "draw_clock_long_hand",
              "bvrt_total_correct_delayed",
              "logical_memory_immediate", "logical_memory_delayed",
                "logical_memory_recognition",
              "jolo_total_correct",
              "copy_cube",
              "shipley_2",
              "mattis_total_score",
              "mmse_score",
              "trails_a_seconds", "trails_b_seconds",
              "wais_digit_symbol_score",
              "gstroop_total_correct",
              "tol_total_correct",
              "tol_total_time",
              "letter_number_sequencing_total",
              "digits_total_score", "digits_forward", "digits_backward")
# What to do with letter_number_sequencing? See grep("letter, colnames(dat1))

# Select columns from data frames; one_of() switches non existent column error
# to warning.
dat1.ss <- select(dat1, one_of(data.cols))
dat1.ss.match <- match(dat1.ss$IDNUM, dat2$IDNUM)

# Merge on all matching columns, and keep everything
all.dat <- dat1.ss %>%
  add_column(dat2$subject_id[dat1.ss.match], .after = "IDNUM") %>%
  add_column(dat2$ageatonset[dat1.ss.match], .after = "agevisit") %>%
  add_column(dat2$cognitive_status[dat1.ss.match])
colnames(all.dat)[c(2, 5, 16)] <- c("subject_id",
                                    "ageatonset", "cognitive_status")

# Base it on the date of the MoCA test
# has.moca <- subset(all.dat, !is.na(collection_date_moca))
dat <- all.dat

dat.Z <- dat %>% mutate_if(is.numeric, scale)

# Cognitive data only
cog.dat <- select(dat1, cog.cols)

# Clean up
rm(dat1, dat1.ss, dat2, all.dat)

###############################################################################

# dates <- all.dat[, grep("date", colnames(all.dat))]
# write.csv(dates, file = "dates-test.csv", quote = FALSE, row.names = FALSE)

# Turn group into factor
dat$Group <- as.factor(ifelse(dat$Group == 1, "PD", "HC"))

# Fix gender to be all 'M'/'F'
dat$gender[dat$gender == "Male"] <- "M"
dat$gender[dat$gender == "Female"] <- "F"
dat$gender %<>% as.factor()

# Abbreviate cog status
dat$cognitive_status <- as.factor(dat$cognitive_status)
levels(dat$cognitive_status) <- c("CIND", "NCI")

# Remove RC4132 because they don't have any MRI data at all
dat <- dat[dat$IDNUM != "RC4132", ]

dat$timesinceonset <- dat$agevisit - dat$ageatonset

demo.data <- dat %>%
              group_by(Group) %>%
              summarize(n = n(),
                        age = paste0(round(mean(agevisit), 1),
                                     " (", round(sd(agevisit), 1), ")"),
                        n.male = sum(gender == "M"),
                        HY = paste0(round(mean(sub_hoehn_and_yahr, na.rm = TRUE), 1),
                                    " (", round(sd(sub_hoehn_and_yahr, na.rm = TRUE), 1), ")"),
                        U1 = paste0(round(mean(updrs_new_1_total, na.rm = TRUE), 1),
                                    " (", round(sd(updrs_new_1_total, na.rm = TRUE), 1), ")"),
                        U2 = paste0(round(mean(updrs_new_2_total, na.rm = TRUE), 1),
                                    " (", round(sd(updrs_new_2_total, na.rm = TRUE), 1), ")"),
                        U3 = paste0(round(mean(updrs_new_3_total, na.rm = TRUE), 1),
                                    " (", round(sd(updrs_new_3_total, na.rm = TRUE), 1), ")"),
                        U4 = paste0(round(mean(updrs_new_4_total, na.rm = TRUE), 1),
                                    " (", round(sd(updrs_new_4_total, na.rm = TRUE), 1), ")"),
                        onset = paste0(round(mean(timesinceonset, na.rm = TRUE), 1),
                                       " (", round(sd(timesinceonset, na.rm = TRUE), 1), ")"),
                        educ = paste0(round(mean(education_years, na.rm = TRUE), 1),
                                      " (", round(sd(education_years, na.rm = TRUE), 1), ")"),
                        hand.R = sum(handedness == 1) ) %>%
                t()

# Sum clock measurements
cog.dat$draw_clock <- apply(cog.dat[, grep("draw_clock_", colnames(cog.dat))],
                            1, sum)
cog.dat <- select(cog.dat, -grep("draw_clock_", colnames(cog.dat)))

# Trails A minus Trails B (??)
cog.dat$trails_AmB <- cog.dat$trails_a_seconds - cog.dat$trails_b_seconds

cd.results <- cog.dat %>%
                group_by(Group) %>%
                select(-IDNUM) %>%
                summarize_all(funs(mean, sd), na.rm = TRUE)

new.order <- c("Group", sort(colnames(cd.results)[-1]))
cd.results.out <- t(cd.results[, new.order])

cd.results.out <- cd.results.out[-1, ]

cd.formatted <- matrix(NA, nrow = nrow(cd.results.out) / 2, ncol = 2)

for (i in 1:nrow(cd.formatted)) {

  j <- seq(1, nrow(cd.results.out), by = 2)[i]

  pd.mean <- round(cd.results.out[j, 1], 2)
  pd.sd <- round(cd.results.out[j + 1, 1], 2)

  hc.mean <- round(cd.results.out[j, 2], 2)
  hc.sd <- round(cd.results.out[j + 1, 2], 2)

  cd.formatted[i, 1] <- paste0(pd.mean, " (", pd.sd, ")")
  cd.formatted[i, 2] <- paste0(hc.mean, " (", hc.sd, ")")

}


colnames(cd.formatted) <- c("PD", "HC")
rownames(cd.formatted) <- rownames(cd.results.out) %>%
                            gsub("_mean", "", .) %>% gsub("_sd", "", .) %>%
                            unique()

write.csv(cd.formatted, "cognitive-data.csv", quote = FALSE)
write.csv(demo.data, "demographics.csv", quote = FALSE)

################################################################################

dat.PD <- dat$Group == "PD"
dat.HC <- dat$Group == "HC"

values <- c("agevisit", "updrs_new_3_total", "education_years")
t.tests <- list(rep(NA, length(values)))
for (i in 1:length(values)) {

  x <- values[i] ; message(x)
  t.tests[[i]] <- t.test(dat[, x][dat.PD], dat[, x][dat.HC])

}

cog.values <- c("moca_score", "copy_cube", "draw_clock")
cog.tests <- list(rep(NA, length(cog.values)))
for (i in 1:length(cog.values)) {

  x <- cog.values[i] ; message(x)
  cog.tests[[i]] <- t.test(cog.dat[, x][dat.PD], cog.dat[, x][dat.HC])

}

################################################################################
# Check against Peter

# # Read in one-column table and convert to vector
# psubjects <- read.table("/NAS_II/Projects/Udall/pboord/bin/files-in-feat.txt",
#                         stringsAsFactors = FALSE)[, 1]
# 
# missing.from.pb <- !dat$IDNUM %in% psubjects
# dat$IDNUM[missing.from.pb]
