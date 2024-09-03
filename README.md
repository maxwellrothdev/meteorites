# Meteorites: Impacts and Discoveries

## Table of Contents

- Project Summary
- Programming Languages and Tools
- Links

## Project Summary

This project is a self-continued study of a Harvard course problem set for Introduction to Databases with SQL. The original course assignment was an intermediate import, cleaning, and updating of a NASA data set of all known meteorite landings from The Meteoritical Society. The purpose of this self-continued study was to further analyze the data and develop more advanced skills in SQL and visualization tools.

A database (meteorites.db) was created and the data set imported as a CSV from NASA’s Open Data Portal via command-line. The database schema was created and the data was cleaned, updated, and queried for analysis and visualization ([import.sql](https://github.com/maxwellrothdev/meteorites/blob/main/import.sql)).

The data set included coordinates but no other location data. To enrich the data for this project and future projects, a Python command-line program ([reverse_geo.py](https://github.com/maxwellrothdev/meteorites/blob/main/reverse_geo.py)) was written to perform reverse geocoding on a CSV file to extract location data, country data in this case, based on given coordinates. The program imports a CSV file as a Pandas DataFrame, takes a column of coordinates in set batches to not overwhelm the API, and returns a new column with the country data.

After designing a UI with Adobe and Figma, the database was connected via Google Cloud to Tableau to create visualizations and an [interactive dashboard](https://public.tableau.com/app/profile/maxwellroth/viz/Meteorites_17207246953380/Main).

## Programming Languages and Tools 

- Languages: SQLite, Python
- Libraries and Modules: Pandas, GeoPy, Nominatim, RateLimiter, os, sys
- Illustration: Adobe Photoshop
- UI Design: Figma
- Cloud: Google Cloud
- Dashboard: Tableau

## Links

- Data Set: [NASA](https://data.nasa.gov/Space-Science/Meteorite-Landings/gh4g-9sfh/about_data)
- Dashboard: [Tableau](https://public.tableau.com/app/profile/maxwellroth/viz/Meteorites_17207246953380/Main)
