# NabillaPutriCahayani_technical_test

## User Behavior Analysis
### Project Description

This project is part of a technical test for a Data Analyst position. The objective is to perform an in-depth analysis of three provided datasets (users, cards, and transactions) to uncover insights regarding user behavior. The analysis covers user demographic profiles, transaction patterns, geographic trends, and behavioral comparisons between different segments. 
The final results are presented in a presentation and an interactive dashboard.

### Tools Used
* Database: PostgreSQL 16
* GUI & Querying: pgAdmin 4 & psqlBusiness 
* Intelligence Tool: Looker Studio
* Spreadsheet: Google Sheets 

### How to Run and Reproduce the Analysis
To reproduce this project from scratch, follow the steps below. Ensure you have PostgreSQL installed on your system.
1. Database SetupCreate a new database in PostgreSQL. It is recommended to name it ```technical_test```. You can create it via pgAdmin or by using the following command in your terminal:

   ```createdb -U postgres technical_test```
   
3. Creating Table Structure
   Connect to the newly created technical_test database. Run the entire SQL script located in the ```sql_scripts/01_create_tables.sql``` file to create the table structures for ```users```, ```cards```, and ```transactions```.
   
4. Importing Data from CSV
   This step must be performed using the psql terminal as it utilizes the \copy command, which is designed to import data from the client-side (your computer).

   Open your terminal and connect to the database:

   ```psql -U postgres -d technical_test```

   Once connected, run the following \copy commands one by one. Make sure to adjust the path (/path/to/your/csv/) to the location where you have saved the dataset files.
   -- Replace the path with the actual file location on your computer
   
    ```
    \copy users FROM '/path/to/your/csv/users_data.csv' WITH (FORMAT CSV, HEADER);
   
    \copy cards FROM '/path/to/your/csv/cards_data.csv' WITH (FORMAT CSV, HEADER);
   
    \copy transactions FROM '/path/to/your/csv/transactions_data.csv' WITH (FORMAT CSV, HEADER);
    ```
   
4. Data Cleaning and Transformation
   After the data has been successfully imported, run the SQL script located in ```sql_scripts/02_clean_data.sql```. This script will:
   * Remove the $ currency symbol from financial columns.
   * Change the data type of financial columns to NUMERIC.
   * Change the data type of the date column to TIMESTAMP to enable time-based analysis.
   
6. Running Analysis Queries
   All queries used for the in-depth analysis can be found in the ```sql_scripts/03_analysis_queries.sql``` file.
   These queries were used to generate the findings presented in the presentation and the dashboard.
   Project Folder Structure
   The following is the recommended folder structure for the final submission.
   ```
    ├── sql_scripts/
    │   ├── 01_create_tables.sql
    │   ├── 02_clean_data.sql
    │   └── 03_analysis_queries.sql
    ├── README.md
    └── presentation.pdf
   ```
### Final Deliverables
* SQL Scripts: All SQL scripts used are located in the ```sql_scripts/``` folder.

* README File: This file (README.md).

* Presentation: The analysis results and business recommendations are presented in the presentation.pdf file.

* Looker Studio Dashboard: The interactive dashboard can be accessed via the following link:https://lookerstudio.google.com/reporting/6dffa909-22a6-4ec3-ab30-14a7ab972326
