-- EXECUTION 1
CREATE DATABASE GLODAP_Analysis;
GO

-- EXECUTION 2
USE GLODAP_Analysis;
GO

-- EXECUTION 3
CREATE SCHEMA OceanData;
GO

-- EXECUTION 4
CREATE TABLE OceanData.GLODAP_Pacific (
    expocode NVARCHAR(50),
    cruise NVARCHAR(100),
    station NVARCHAR(50),
    region NVARCHAR(50),
    cast INT,
    year INT,
    month INT,
    day INT,
    hour INT,
    minute INT,
    latitude FLOAT,
    longitude FLOAT,
    bottomdepth FLOAT,
    maxsampdepth FLOAT,
    bottle INT,
    pressure FLOAT,
    depth FLOAT,
    temperature FLOAT,
    theta FLOAT,
    salinity FLOAT,
    sigma0 FLOAT,
    sigma1 FLOAT,
    sigma2 FLOAT,
    sigma3 FLOAT,
    sigma4 FLOAT,
    gamma FLOAT,
    oxygen FLOAT,
    aou FLOAT,
    nitrate FLOAT,
    nitrite FLOAT,
    silicate FLOAT,
    phosphate FLOAT
);