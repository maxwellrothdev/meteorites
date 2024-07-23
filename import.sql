-- Meteorites - Data Analysis
-- Using sqlite3


-- Create database
-- Terminal Command: sqlite3 meteorites.db


-- Create table to import meteorite csv and clean data

CREATE TABLE IF NOT EXISTS "meteorites_temp" (
    "name" TEXT,
    "id" INTEGER,
    "nametype" TEXT,
    "class" TEXT,
    "mass" REAL,
    "discovery" TEXT,
    "year" TEXT,
    "latitude" REAL,
    "longitude" REAL,
    "geolocation" TEXT,
    PRIMARY KEY("id")
);


-- Import meteorites.csv into temp table
-- Terminal Command: .import --csv --skip 1 meteorites.csv "meteorites_temp" NOTE: --skip 1 to remove csv row 1 (column names)


-- Check for empty values, if '' or 0, update to NULL
-- '' - mass, year, latitude, longitude, geolocation
-- 0 - mass, latitude, longitude

-- mass
UPDATE "meteorites_temp"
SET "mass" = NULL
WHERE "mass" = '';

UPDATE "meteorites_temp"
SET "mass" = NULL
WHERE "mass" = 0;

-- year
UPDATE "meteorites_temp"
SET "year" = NULL
WHERE "year" = '';

-- latitude
UPDATE "meteorites_temp"
SET "latitude" = NULL
WHERE "latitude" = '';

UPDATE "meteorites_temp"
SET "latitude" = NULL
WHERE "latitude" = 0 AND "geolocation" LIKE '%0.0, 0.0%';

-- longitude
UPDATE "meteorites_temp"
SET "longitude" = NULL
WHERE "longitude" = '';

UPDATE "meteorites_temp"
SET "longitude" = NULL
WHERE "longitude" = 0 AND "geolocation" LIKE '%0.0, 0.0%';

-- geolocation
UPDATE "meteorites_temp"
SET "geolocation" = NULL
WHERE "geolocation" = '';

UPDATE "meteorites_temp"
SET "geolocation" = NULL
WHERE "geolocation" LIKE '%0.0, 0.0%';


-- Check year range for errors, if error, update to NULL

SELECT *
FROM "meteorites_temp"
WHERE "year" > '2024';

UPDATE "meteorites_temp"
SET "year" = NULL
WHERE "year" = '2101';

-- Check lat, long range for errors

SELECT *
FROM "meteorites_temp"
WHERE "latitude" < -90 AND "latitude" > 90;

SELECT *
FROM "meteorites_temp"
WHERE "longitude" < -180 AND "longitude" > 180;


-- Round mass to 2 floating points

UPDATE "meteorites_temp"
SET "mass" = ROUND(("mass"), 2);


-- Create table to insert cleaned data from temp table

CREATE TABLE IF NOT EXISTS "meteorites" (
    "id" INTEGER,
    "name" TEXT,
    "class" TEXT,
    "mass" REAL,
    "discovery" TEXT,
    "year" TEXT,
    "latitude" REAL,
    "longitude" REAL,
    "geolocation" TEXT,
    "country" TEXT DEFAULT NULL,
    PRIMARY KEY("id")
);


-- Insert cleaned data, with new id from 1, ordered by year and then name

INSERT INTO "meteorites" ("name", "class", "mass", "discovery", "year", "latitude", "longitude", "geolocation")
SELECT "name", "class", "mass", "discovery", "year", "latitude", "longitude", "geolocation"
FROM "meteorites_temp"
ORDER BY "year", "name";


-- Recorded impacts 'fell' with geolocation to export csv for reverse_geo.py: 1096
-- UNION
-- CTE - 10 Largest recorded meteorites by mass (tons) to export for reverse_geo.py: 1105

WITH "top_meteorites" AS (
	SELECT "id", ROUND(("mass"/907185), 2) AS "mass (tons)", "geolocation"
	FROM "meteorites"
	ORDER BY "mass (tons)" DESC
	LIMIT 10
)
SELECT "id", "geolocation"
FROM "top_meteorites"
UNION
SELECT "id", "geolocation"
FROM "meteorites"
WHERE "discovery" = 'Fell' AND "geolocation" NOT NULL;

-- Create table to import countries csv and clean data

CREATE TABLE "countries_temp" (
	"meteorite_id" INTEGER,
	"geolocation" TEXT,
	"country" TEXT,
	PRIMARY KEY("meteorite_id")
);

-- Import countries_updated.csv into temp table
-- Terminal Command: .import --csv --skip 1 countries_updated.csv "countries_temp" NOTE: --skip 1 to remove csv row 1 (column names)

-- Update country data in meteorites table

UPDATE "meteorites"
SET "country" = (
	SELECT "country"
	FROM "countries_temp"
	WHERE "countries_temp"."meteorite_id" = "meteorites"."id"
);


-- Drop temp tables and reallocate memory

DROP TABLE "meteorites_temp";

DROP TABLE "countries_temp";

VACUUM;


-- Meteorites: Impacts | Discoveries

-- Source: NASA
-- NOTE: grams per ton = 907185

-- Total Impacts, Total Discoveries, Total Recorded

SELECT
  SUM("discovery" = 'Fell') AS "Total Impacts",
  SUM("discovery" = 'Found') AS "Total Discoveries",
  COUNT(*) AS "Total Recorded"
FROM "meteorites";

-- No. of Meteorites (Fell) by Year

SELECT "year", COUNT("id") AS "No. of Meteorites (Fell)"
FROM "meteorites"
WHERE "year" NOT NULL AND "discovery" = 'Fell'
GROUP BY "year"
ORDER BY "year";

-- No. of Meteorites (Found) by Year

SELECT "year", COUNT("id") AS "No. of Meteorites (Found)"
FROM "meteorites"
WHERE "year" NOT NULL AND "discovery" = 'Found'
GROUP BY "year"
ORDER BY "year";

-- Meteorites (Fell) by Geolocation

SELECT "name", "mass", "class", "year", "geolocation"
FROM "meteorites"
WHERE "discovery" = 'Fell';

-- Meteorites (Found) by Geolocation

SELECT "name", "mass", "class", "year", "geolocation"
FROM "meteorites"
WHERE "discovery" = 'Found';

-- Largest Recorded Meteorite by mass (tons) - name, mass, class, year, country

SELECT "name", "class", ROUND(("mass"/907185), 2) AS "mass (tons)", "year", "country"
FROM "meteorites"
ORDER BY "mass (tons)" DESC
LIMIT 1;

-- 10 Largest Recorded Meteorites by mass (tons) - name, mass, class, year, country

SELECT "name", "class", ROUND(("mass"/907185), 2) AS "mass (tons)", "year", "country"
FROM "meteorites"
ORDER BY "mass (tons)" DESC
LIMIT 10;

-- Top Countries of Impact - No. of Meteorites (Fell)

SELECT "country", COUNT("id") AS "No. of Meteorites (Fell)"
FROM "meteorites"
WHERE "discovery" = 'Fell'
GROUP BY "country"
ORDER BY "No. of Meteorites (Fell)" DESC
LIMIT 10;