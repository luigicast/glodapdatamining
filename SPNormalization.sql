USE GLODAP_Analysis;
GO

CREATE OR ALTER PROCEDURE sp_Normalize_GLODAP
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dbo.NormalizedData;

    INSERT INTO dbo.NormalizedData
    EXECUTE sp_execute_external_script
        @language = N'R',
        @script = N'
            library(dplyr)

            min_max_norm <- function(x) {
                (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
            }

            z_score_norm <- function(x) {
                (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
            }

            robust_norm <- function(x) {
                (x - median(x, na.rm = TRUE)) / IQR(x, na.rm = TRUE)
            }

            vars_core <- c("temperature", "salinity", "oxygen", "nitrate",
                           "phosphate", "silicate")

            data_norm <- InputDataSet %>%
                mutate(across(all_of(vars_core), ~ min_max_norm(.), .names = "{.col}_minmax")) %>%
                mutate(across(all_of(vars_core), ~ z_score_norm(.), .names = "{.col}_z")) %>%
                mutate(across(all_of(vars_core), ~ robust_norm(.), .names = "{.col}_robust"))

            OutputDataSet <- data_norm
        ',
        @input_data_1 = N'
            SELECT 
                cruise, station, cast, year, month, day, hour, minute,
                latitude, longitude, depth,
                temperature, salinity, oxygen, nitrate, phosphate, silicate
            FROM OceanData.GLODAP_Pacific
            WHERE temperature IS NOT NULL
              AND salinity IS NOT NULL
              AND oxygen IS NOT NULL
              AND nitrate IS NOT NULL
              AND phosphate IS NOT NULL
              AND silicate IS NOT NULL
        ';
END;
GO

EXEC sp_Normalize_GLODAP;

SELECT COUNT(*) FROM dbo.NormalizedData;

SELECT TOP 10 * FROM dbo.NormalizedData;
