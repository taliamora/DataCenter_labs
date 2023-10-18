--- CREATE DIMENSION TABLES
CREATE TABLE IF NOT EXISTS animal_dim (
    "Animal ID" VARCHAR(7) PRIMARY KEY,
    "Date of Birth" DATE,
    "Animal Type" VARCHAR,
    "sex" VARCHAR,
    "Breed" VARCHAR,
    "Color" VARCHAR
);

CREATE TABLE IF NOT EXISTS outcome_types_dim (
    outcome_type_id SERIAL PRIMARY KEY,
    outcome_type VARCHAR
);

CREATE TABLE IF NOT EXISTS reproductive_status_dim (
    repo_status_id SERIAL PRIMARY KEY,
    repo_status VARCHAR
);

CREATE TABLE IF NOT EXISTS dates_dim (
    date_id INT PRIMARY KEY,
    year INT,
    month INT,
    day INT
);

--- INSERT DATA INTO DIM TABLES
INSERT INTO animal_dim ("Animal ID", "Date of Birth", "Animal Type", "sex", "Breed", "Color")
SELECT DISTINCT "Animal ID", "Date of Birth", "Animal Type", "sex", "Breed", "Color" FROM outcomes;

INSERT INTO outcome_types_dim (outcome_type_id, outcome_type)
SELECT DISTINCT row_number() OVER (ORDER BY "Outcome Type"), "Outcome Type" FROM outcomes;

INSERT INTO reproductive_status_dim (repo_status_id, repo_status)
SELECT DISTINCT row_number() OVER (ORDER BY "repo_status"), "repo_status" FROM outcomes;

INSERT INTO dates_dim (date_id, year, month, day)
SELECT DISTINCT 
    CAST(TO_CHAR("DateTime", 'YYYYMMDD') AS INT) AS date_id,
    EXTRACT(YEAR FROM "DateTime") AS year,
    EXTRACT(MONTH FROM "DateTime") AS month,
    EXTRACT(DAY FROM "DateTime") AS day
FROM outcomes;


--- CREATE FACT TABLES
CREATE TABLE IF NOT EXISTS outcomes_fct (
    outcome_id SERIAL PRIMARY KEY,
    "Animal ID" VARCHAR(7),
    outcome_type_id INT,
    repo_status_id INT,
    date_id INT,
    FOREIGN KEY ("Animal ID") REFERENCES animal_dim("Animal ID"),
    FOREIGN KEY (outcome_type_id) REFERENCES outcome_types_dim(outcome_type_id),
    FOREIGN KEY (repo_status_id) REFERENCES reproductive_status_dim(repo_status_id),
    FOREIGN KEY (date_id) REFERENCES dates_dim(date_id)
);


--- INSERT DATA INTO FACT TABLE
INSERT INTO outcomes_fct ("Animal ID", outcome_type_id, repo_status_id, date_id)
SELECT 
    outcomes."Animal ID",
    outcome_types_dim.outcome_type_id,
    reproductive_status_dim.repo_status_id,
    dates_dim.date_id
FROM outcomes
JOIN outcome_types_dim ON outcomes."Outcome Type" = outcome_types_dim.outcome_type
JOIN reproductive_status_dim ON outcomes.reproductive_status = reproductive_status_dim.repo_status
JOIN dates_dim ON CAST(TO_CHAR(outcomes."DateTime", 'YYYYMMDD') AS INT) = dates_dim.date_id;