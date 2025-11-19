USE GLODAP_Analysis;
GO

CREATE OR ALTER PROCEDURE sp_GLODAP_TestPlot_PNG
AS
BEGIN
    SET NOCOUNT ON;

    EXEC sp_execute_external_script
        @language = N'R',
        @script = N'
            library(ggplot2)

            # Crear un gráfico simple
            p <- ggplot(InputDataSet, aes(x = depth, y = temperature_minmax)) +
                geom_point(size = 1) +
                theme_minimal() +
                labs(
                    title = "Depth vs Temperature (Min-Max Normalized)",
                    x = "Depth (m)",
                    y = "Temperature Min-Max"
                )

            # Crear archivo temporal PNG
            file <- tempfile(fileext = ".png")

            # Guardar la imagen
            ggsave(
                filename = file,
                plot = p,
                width = 7,
                height = 5,
                dpi = 300
            )

            # Leer el archivo como bytes
            img_bytes <- readBin(file, "raw", file.info(file)$size)

            # Regresar como tabla (VARBINARY)
            OutputDataSet <- data.frame(Image = I(list(img_bytes)))
        ',
        @input_data_1 = N'
            SELECT TOP 2000 depth, temperature_minmax
            FROM dbo.NormalizedData
            WHERE depth IS NOT NULL AND temperature_minmax IS NOT NULL
        ';
END;
GO

EXEC sp_GLODAP_TestPlot_PNG;