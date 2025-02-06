-- Data cleaning project from Alex the Analyst course
SELECT 
	*
FROM 
	world_layofffs.layoffs;

-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways

CREATE TABLE layoffs_staging
LIKE world_layofffs.layoffs;

SELECT * FROM layoffs_staging;
SELECT * FROM layoffs;
SELECT * FROM layoffs_staging;

-- 1. check for duplicates and remove any (Uniquely identify each row, if a row_num is equal or greater than 2 then it is a duplicate)
WITH duplicate_cte AS (
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs
)

SELECT * 
FROM duplicate_cte 
WHERE row_num > 1;

SELECT * FROM layoffs
WHERE company = 'Casper';

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs;
SET SQL_SAFE_UPDATES = 0;
DELETE FROM layoffs_staging2
WHERE row_num > 1;

SELECT * FROM layoffs_staging2;

-- 2. Standardizing Data
SELECT company, trim(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT * FROM layoffs_staging2;

SELECT distinct(industry)
FROM layoffs_staging2
order by 1;

SELECT industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT distinct(country)
FROM layoffs_staging2
order by 1;

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

SELECT `date`, str_to_date(`date`, '%m/%d/%Y') AS new_date
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');
ALTER TABLE layoffs_staging2
Modify COLUMN `date` DATE;
SELECT * FROM layoffs_staging2;

-- Remove null values
SELECT * FROM layoffs_staging2 WHERE (total_laid_off IS NULL) AND (percentage_laid_off IS NULL);

SELECT * FROM layoffs_staging2 WHERE (industry IS NULL) OR (industry = '');

SELECT * FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2 ON (t1.company = t2.company)
WHERE (t1.industry is NULL) AND t2.industry is NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 ON (t1.company = t2.company)
SET t1.industry = t2.industry
WHERE (t1.industry is NULL OR t1.industry='') AND t2.industry is NOT NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

DELETE FROM layoffs_staging2 WHERE (total_laid_off IS NULL) AND (percentage_laid_off IS NULL);

ALTER TABLE layoffs_staging2
DROP row_num;