USE GLODAP_Analysis;
GO

EXEC sp_execute_external_script
    @language = N'R',
    @script = N'
        library(ggplot2)
        library(corrplot)
        
        # Configuración
        mainDir <- "C:\\Program Files\\DataMining\\graphs\\"
        
        # Función guardar gráficos
        save_ggplot <- function(plot_obj, filename_suffix) {
            filepath <- paste0(mainDir, "GLODAP_", filename_suffix, "_", 
                             format(Sys.time(), "%Y%m%d_%H%M%S"), ".jpg")
            ggsave(filename = filepath, plot = plot_obj, 
                   width = 10, height = 6, dpi = 300, units = "in")
            cat("✓", filepath, "\n")
        }
        
        glodap_data <- InputDataSet
        
        cat("ESTADÍSTICAS DESCRIPTIVAS\n")
        
        vars <- c("temperature", "salinity", "oxygen", "depth", 
                  "nitrate", "phosphate", "silicate")
        
        # Función para calcular moda
        getmode <- function(v) {
            uniqv <- unique(v[!is.na(v)])
            uniqv[which.max(tabulate(match(v, uniqv)))]
        }
        
        stats_tabla <- data.frame()
        
        for (var in vars) {
            if (var %in% names(glodap_data)) {
                d <- glodap_data[[var]][!is.na(glodap_data[[var]])]
                
                if (length(d) > 0) {
                    stats_tabla <- rbind(stats_tabla, data.frame(
                        Variable = var,
                        N = length(d),
                        Media = round(mean(d), 3),
                        Mediana = round(median(d), 3),
                        Moda = round(getmode(d), 3),
                        Desv_Est = round(sd(d), 3),
                        Rango = round(max(d) - min(d), 3),
                        Min = round(min(d), 3),
                        Max = round(max(d), 3),
                        Q1 = round(quantile(d, 0.25), 3),
                        Q3 = round(quantile(d, 0.75), 3)
                    ))
                }
            }
        }
        
        print(stats_tabla)
        
        # Guardar CSV
        csv_stats <- paste0(mainDir, "GLODAP_Estadisticas_", 
                           format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
        write.csv(stats_tabla, csv_stats, row.names = FALSE)
        cat("\n✓ Estadísticas:", csv_stats, "\n")
        
        cat("MATRIZ DE CORRELACIONES\n")
        
        cor_data <- na.omit(glodap_data[, vars])
        cor_matrix <- cor(cor_data)
        print(round(cor_matrix, 3))
        
        # Guardar gráfico correlación
        filepath_cor <- paste0(mainDir, "GLODAP_Correlacion_", 
                              format(Sys.time(), "%Y%m%d_%H%M%S"), ".jpg")
        
        jpeg(filename = filepath_cor, type = "cairo", 
             width = 800, height = 800, quality = 95)
        corrplot(cor_matrix, method = "color", type = "upper",
                addCoef.col = "black", number.cex = 0.7,
                tl.col = "black", tl.srt = 45,
                title = "Matriz de Correlación - GLODAP Pacific",
                mar = c(0, 0, 2, 0))
        dev.off()
        
        cat("\nCorrelación:", filepath_cor, "\n")
        
        
        cat("GRÁFICOS DE DISTRIBUCIÓN\n")
        
        # Colores para cada variable
        colores <- c("steelblue", "coral", "darkgreen", "purple", 
                    "orange", "darkred", "navy")
        
        for (i in seq_along(vars)) {
            var <- vars[i]
            
            if (var %in% names(glodap_data)) {
                # Crear gráfico
                p <- ggplot(glodap_data, aes_string(x = var)) +
                    geom_histogram(bins = 50, fill = colores[i], 
                                  color = "black", alpha = 0.7) +
                    geom_density(aes(y = after_stat(count)), 
                                color = "red", size = 1.2) +
                    labs(title = paste("Distribución de", 
                                      tools::toTitleCase(var)),
                         x = var, y = "Frecuencia") +
                    theme_minimal() +
                    theme(plot.title = element_text(hjust = 0.5, 
                                                   face = "bold", size = 14))
                
                # Guardar
                save_ggplot(p, paste0("Dist_", var))
            }
        }
        
        cat("PROCESO COMPLETADO\n")
        cat("Total registros:", nrow(glodap_data), "\n")
        cat("Variables analizadas:", length(vars), "\n")
        cat("Archivos en:", mainDir, "\n\n")
        
        OutputDataSet <- stats_tabla
    ',
    @input_data_1 = N'
        SELECT 
            temperature, salinity, oxygen, depth,
            nitrate, phosphate, silicate
        FROM OceanData.GLODAP_Pacific
        WHERE temperature IS NOT NULL
          AND salinity IS NOT NULL
    '
WITH RESULT SETS ((
    Variable NVARCHAR(50),
    N INT,
    Media FLOAT,
    Mediana FLOAT,
    Moda FLOAT,
    Desv_Est FLOAT,
    Rango FLOAT,
    Min FLOAT,
    Max FLOAT,
    Q1 FLOAT,
    Q3 FLOAT
));
GO
