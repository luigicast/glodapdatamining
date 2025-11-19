USE GLODAP_Analysis;
GO

DROP TABLE IF EXISTS NormalizedData;
GO

CREATE TABLE NormalizedData (
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
