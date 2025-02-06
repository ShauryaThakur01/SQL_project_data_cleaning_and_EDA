-- Exploratory Data Analysis

SELECT * FROM layoffs_staging2;

SELECT MAX(total_laid_off) FROM layoffs_staging2;

SELECT MAX(percentage_laid_off) FROM layoffs_staging2;

SELECT * FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY
	funds_raised_millions DESC;
    
SELECT company, SUM(total_laid_off) AS tot_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY tot_laid_off DESC;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

SELECT industry, SUM(total_laid_off) AS tot_laid_off
FROM layoffs_staging2
GROUP BY industry
ORDER BY tot_laid_off DESC;

SELECT country, SUM(total_laid_off) AS tot_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY tot_laid_off DESC;

SELECT year(`date`), SUM(total_laid_off) AS tot_laid_off
FROM layoffs_staging2
GROUP BY year(`date`)
ORDER BY tot_laid_off DESC;

WITH rolling_total AS (
	SELECT substring(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
	FROM layoffs_staging2
	WHERE substring(`date`,1,7) IS NOT NULL
	GROUP BY `MONTH`
	ORDER BY 1 DESC
)

SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS tot_off
FROM rolling_total;


SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
group by company, YEAR(`date`)
ORDER BY 3 DESC;


WITH company_year (company, years, total_laid_offs) AS (
	SELECT company, YEAR(`date`), SUM(total_laid_off)
	FROM layoffs_staging2
	group by company, YEAR(`date`)
), company_year_rank AS (
SELECT *, dense_rank() OVER(partition by years ORDER BY total_laid_offs DESC) AS Ranking
FROM company_year
WHERE years IS NOT NULL
)

SELECT * FROM company_year_rank WHERE Ranking <= 5;