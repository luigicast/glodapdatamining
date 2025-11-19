USE GLODAP_Analysis;
GO

DROP TABLE IF EXISTS #TempNormalized;
GO

CREATE TABLE #TempNormalized (
    cruise NVARCHAR(50),
    station NVARCHAR(50),
    cast INT,
    year INT,
    month INT,
    day INT,
    hour INT,
    minute INT,
    latitude FLOAT,
    longitude FLOAT,
    depth FLOAT,
    temperature FLOAT,
    salinity FLOAT,
    oxygen FLOAT,
    nitrate FLOAT,
    phosphate FLOAT,
    silicate FLOAT,
    temperature_minmax FLOAT,
    salinity_minmax FLOAT,
    oxygen_minmax FLOAT,
    nitrate_minmax FLOAT,
    phosphate_minmax FLOAT,
    silicate_minmax FLOAT,
    temperature_z FLOAT,
    salinity_z FLOAT,
    oxygen_z FLOAT,
    nitrate_z FLOAT,
    phosphate_z FLOAT,
    silicate_z FLOAT,
    temperature_robust FLOAT,
    salinity_robust FLOAT,
    oxygen_robust FLOAT,
    nitrate_robust FLOAT,
    phosphate_robust FLOAT,
    silicate_robust FLOAT
);
GO

-- Ahora insertar los datos normalizados
INSERT INTO #TempNormalized
EXECUTE sp_execute_external_script
    @language = N'R',
    @script = N'
        library(dplyr)
        
        # Funciones de normalización
        min_max_norm <- function(x) {
            (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
        }
        
        z_score_norm <- function(x) {
            (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
        }
        
        robust_norm <- function(x) {
            (x - median(x, na.rm = TRUE)) / IQR(x, na.rm = TRUE)
        }
        
        # Variables a normalizar
        vars_core <- c("temperature", "salinity", "oxygen", "nitrate", 
                       "phosphate", "silicate")
        
        # Aplicar normalizaciones
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
GO

SELECT COUNT(*) AS TotalRows FROM #TempNormalized;
GO

SELECT TOP 10 *
FROM #TempNormalized
ORDER BY depth;
GO

EXECUTE sp_execute_external_script
    @language = N'R',
    @script = N'
        library(dplyr)
        library(ggplot2)
        library(reshape2)
        
        # Seleccionar scolumnas normalizadas
        corr_data <- InputDataSet %>%
            select(temperature_minmax, salinity_minmax, oxygen_minmax,
                   nitrate_minmax, phosphate_minmax, silicate_minmax)
        
        # Calcular matriz de correlación
        corr_matrix <- cor(corr_data, use = "pairwise.complete.obs")
        corr_matrix_rounded <- round(corr_matrix, 4)
        
        print(corr_matrix_rounded)
        
        melted_corr <- melt(corr_matrix)
        
        melted_corr$Var1 <- gsub("_minmax", "", melted_corr$Var1)
        melted_corr$Var2 <- gsub("_minmax", "", melted_corr$Var2)
        
        # Crear heatmap
        plot_obj <- ggplot(melted_corr, aes(Var1, Var2, fill = value)) +
            geom_tile(color = "white", size = 0.5) +
            geom_text(aes(label = round(value, 2)), 
                     color = "black", size = 4, fontface = "bold") +
            scale_fill_gradient2(
                low = "#2166AC", 
                mid = "white", 
                high = "#B2182B",
                midpoint = 0,
                limits = c(-1, 1),
                name = "Correlación"
            ) +
            theme_minimal() +
            labs(
                title = "HeatMap - Physical and Chemical Variable Correlation",
                subtitle = "Min-Max Normalization (GLODAP Pacific Ocean)",
                x = "",
                y = ""
            ) +
            theme(
                axis.text.x = element_text(angle = 45, hjust = 1, size = 12, face = "bold"),
                axis.text.y = element_text(size = 12, face = "bold"),
                plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
                plot.subtitle = element_text(hjust = 0.5, size = 12),
                legend.position = "right",
                panel.grid = element_blank()
            )
        
        mainDir <- "C:\\Program Files\\DataMining\\graphs\\"
        dir.create(mainDir, showWarnings = FALSE, recursive = TRUE)
        
        # Guardar gráfico
        filepath <- paste0(mainDir, "GLODAP_Correlation_Heatmap_", 
                          format(Sys.time(), "%Y%m%d_%H%M%S"), ".jpg")
        
        ggsave(
            filename = filepath,
            plot = plot_obj,
            width = 10,
            height = 8,
            dpi = 300,
            units = "in"
        )
        
        corr_output <- as.data.frame(corr_matrix_rounded)
        corr_output$Variable <- rownames(corr_matrix_rounded)
        corr_output <- corr_output[, c("Variable", colnames(corr_matrix_rounded))]
        
        OutputDataSet <- corr_output
    ',
    @input_data_1 = N'SELECT * FROM #TempNormalized'
WITH RESULT SETS ((
    Variable NVARCHAR(50),
    temperature_minmax FLOAT,
    salinity_minmax FLOAT,
    oxygen_minmax FLOAT,
    nitrate_minmax FLOAT,
    phosphate_minmax FLOAT,
    silicate_minmax FLOAT
));
GO