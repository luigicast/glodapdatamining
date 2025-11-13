USE GLODAP_Analysis;
GO

TRUNCATE TABLE OceanData.GLODAP_Pacific;
GO

INSERT INTO OceanData.GLODAP_Pacific
EXEC sp_execute_external_script
    @language = N'R',
    @script = N'
    library(readr)
    library(dplyr)
    library(stringr)

    ruta <- "C:\\Program Files\\DataMining\\GLODAPv2.2023_Pacific_Ocean.csv"

    columnas_necesarias <- c(
      "G2expocode","G2cruise","G2station","G2region","G2cast","G2year","G2month","G2day","G2hour","G2minute",
      "G2latitude","G2longitude","G2bottomdepth","G2maxsampdepth","G2bottle","G2pressure","G2depth",
      "G2temperature","G2theta","G2salinity","G2sigma0","G2sigma1","G2sigma2","G2sigma3","G2sigma4","G2gamma",
      "G2oxygen","G2aou","G2nitrate","G2nitrite","G2silicate","G2phosphate"
    )

    datos <- read_csv(ruta,
                      na = c("-9999", "-999", "NA", ""),
                      col_select = all_of(columnas_necesarias),
                      n_max = 500000)

    names(datos) <- str_remove(names(datos), "^G2")
    datos <- datos %>% filter(rowSums(is.na(.)) < ncol(.))

    OutputDataSet <- datos
    ';
GO
