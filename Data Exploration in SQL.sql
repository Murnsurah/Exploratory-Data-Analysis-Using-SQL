-- EXPLORATORY DATA ANALYSIS
SELECT *
FROM layoffs_staging2; 

-- CHECKING THE MAXIMUM PEOPLE AND % OF PEOPLE LAID OFF
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2; 

-- 1 for percentage laidoff means 100%. Checking companies that had laid off their entire staff
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- checking the companies that had the most laidoff
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

-- checking the date range
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- checking industries that had the most layoff
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

-- checking countries that were most affected
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

-- checking the no of people laid off in a year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 1 DESC;

-- checking the stage the company was in before laying people off
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

-- checking progression of layoffs by using rolling total 
-- extracting the month column
SELECT SUBSTRING(`date`,1,7) AS Mth, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY 1
ORDER BY 1 ASC;

-- doing a rolling sum by adding the sum of layoffs that happens in a month i.e a month by month progression of the layoffs
WITH Rolling_Total AS 
(SELECT SUBSTRING(`date`,1,7) AS Mth, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY 1
ORDER BY 1 ASC)
SELECT Mth, total_off,
Sum(total_off) OVER(ORDER BY Mth) AS rolling_total
FROM Rolling_total;

SELECT company,YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1,2
ORDER BY 3 DESC;

WITH Company_year(company, years, total_laid_off) AS
(SELECT company,YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company , YEAR(`date`)
), Company_Year_Rank AS 
(SELECT *,
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_year
WHERE years IS NOT NULL)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;