# pharmacological-interaction-database
​Relational database and Python desktop application mapping the pharmacokinetic and pharmacodynamic interactions of drug molecules.
Maps how drugs interact with biological targets, their metabolic profiles via liver enzymes, side effect frequencies, and drug-drug interactions.

### Features
* Database Architecture: 10 interconnected tables in 3NF with ON DELETE CASCADE constraints.
* User Interface: Desktop application built with Python's customtkinter.
* Stored Procedure: A procedure with 10 parameters that inserts data into 4 relational tables simultaneously.
* View: A summary report utilizing JOIN operations, CASE WHEN calculations, and DATE functions.
* Search and Filter: Query capabilities using GROUP BY and JOIN operations.

---

## Setup & Installation

### 1. Prerequisites
* XAMPP
* Python 3.8+

### 2. Database Setup
1. Start Apache and MySQL from the XAMPP Control Panel.
2. Open http://localhost/phpmyadmin in your browser.
3. Import the veritabani.sql file. This creates the farmakoloji_db database, tables, stored procedure, view, and 200 rows of data.

### 3. Python Environment
Install the required libraries:

pip install customtkinter mysql-connector-python

### 4. Running the Application
Run the main Python script:

python main.py

---
Author: Selin Duru Aksu
Course: MBP 203 - Database and Management
