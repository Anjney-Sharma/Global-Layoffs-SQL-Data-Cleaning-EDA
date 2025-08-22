# Data Cleaning project
select * from layoffs_dataset;
# Objectives
-- Remove Duplicates
-- Standardize the Data
-- Filling/Removing Null values and Blank values
-- Remove any unwanted column

create table layoff_staging
like layoffs_dataset;

select * from layoff_staging;

insert layoff_staging
select * from layoffs_dataset;

-- Finding and removing duplicates

WITH duplicate_cte as
(
Select *,
ROW_NUMBER() over(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country,
funds_raised_millions) as row_num
from layoff_staging
)
Select * from duplicate_cte
where row_num > 1;

-- We cant just apply delete function on CTE (like in statement above, instead of select) to delete actual rows from tables. 
-- we can create another table with row_num column and delete duplicates from that.

# go on the table -> right click on it ->copy to clipboard -> create statement 
CREATE TABLE `layoff_staging2` (	# Creating a new table with new name
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT 	# Adding this column to keep the record of row numbers from table layoff_stagging	
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


Select * from layoff_staging2;

insert layoff_staging2
Select *,
ROW_NUMBER() over(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country,
funds_raised_millions) as row_num
from layoff_staging;

DELETE from layoff_staging2		# Check what you're deleting by using select , and then change select to delete.
where row_num > 1;

select * from layoff_staging2;

-- Standardizing Data
select DISTINCT company, TRIM(company)	# To Even the spaces at start and end of name.
from layoff_staging2; 

update layoff_staging2
set company = TRIM(company);

select DISTINCT company, TRIM(company) 	# To recheck 
from layoff_staging2; 

select DISTINCT industry	# To check if there are more then 1 name to same industry (in here it is crypto currency)
from layoff_staging2
order by 1;		# 1 stands for column number 1 which is the only column 

select * 	# Again first check what you want to update , then actually update it
from layoff_staging2
where industry LIKE 'Crypto%'
;

update layoff_staging2
set industry = 'Crypto'
where industry LIKE 'Crypto%'
;

select DISTINCT location	# similarly Checking over all the other columns just to be precautious
from layoff_staging2		# No issues here
order by 1
;

Select DISTINCT country		# Problem in United States
from layoff_staging2
order by 1
;

select DISTINCT country, TRIM(TRAILING '.' FROM country) 	# Advance concept to change what you want to trim in TRIM fn
from layoff_staging2
order by 1
;

Update layoff_staging2
SET country = Trim(TRAILING '.' from country)
where country LIKE 'United States%'
;

select distinct country from layoff_staging2
order by 1;

-- Changing date from text to date type
select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoff_staging2;

update layoff_staging2		# This doesn't change text to date type , it only changes format
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoff_staging2	# Never do this on Raw dataset. Only on staging/ modifyable dataset.
MODIFY COLUMN `date` DATE;  # This changes the type from text to DATE

# Removing / Filling Null and Blank Values
select * from layoff_staging2;

select *
from layoff_staging2
where industry is NULL 
or industry = ''
;

select * from layoff_staging2
where company = 'Airbnb'
;

Update layoff_staging2		# TO make the Update on line 145 statement work, because there were no changes made when we did it for blank('') values 
set industry = NULL
where industry = '';

select t1.company, t1.industry,t2.company, t2.industry 
from layoff_staging2 t1
join layoff_staging2 t2
	on t1.company = t2.company
    and t1.location = t2.location
where (t1.industry is Null)    # Now we only need to look for NULL values since no blanks left
and t2.industry is not null;

UPDATE layoff_staging2 t1		# All the rows are Populated with missing entry but some information present 
join layoff_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry 
where (t1.industry is Null )    
and t2.industry is not null;	

select * from layoff_staging2
where total_laid_off is NULL 
and percentage_laid_off is NULL
;

DELETE from layoff_staging2
where total_laid_off is NULL 
and percentage_laid_off is NULL
;

-- Removing unwanted column
Alter Table layoff_staging2
Drop column row_num;

select * from layoff_staging2;
# ////////////////////////////////////////////////////////////////////////////////////////////////////////
# Exploratory data analysis 

select * from layoff_staging2;

select Max(total_laid_off), Max(percentage_laid_off)
from layoff_staging2;

select * from layoff_staging2
where percentage_laid_off = 1	# 100% employees laid off
order by funds_raised_millions Desc;

select company, sum(total_laid_off)
from layoff_staging2
group by company
order by 2 Desc;

select MIN(`date`), Max(`date`)
from layoff_staging2;

select industry, Sum(total_laid_off)
from layoff_staging2
group by industry
order by 2 desc
;

select country, SUM(total_laid_off)
from layoff_staging2
group by country
order by 2 Desc;

select YEAR(`date`), Sum(total_laid_off)
from layoff_staging2
group by YEAR(`date`)
order by 1 desc
;

select SUBSTRING(`date`,1,7) as `MONTH`, SUM(total_laid_off)
from layoff_staging2
where SUBSTRING(`date`,1,7) is NOT NULL
group by SUBSTRING(`date`,1,7)
order by 1;

With Rolling_total as
(
Select SUBSTRING(`date`,1,7) as `MONTH`, SUM(total_laid_off) as ttl_ld_of
from layoff_staging2
where SUBSTRING(`date`,1,7) is NOT NULL
group by SUBSTRING(`date`,1,7)
order by 1
)
select `MONTH`, ttl_ld_of, Sum(ttl_ld_of) over(order by `MONTH`) as rolling_total
from Rolling_total;

WITH Company_Year(company, years, total_laid_off) as
(
select company, YEAR(`date`), SUM(total_laid_off)
from layoff_staging2 
group by company, YEAR(`date`) 
order by 3 desc
), Company_Year_Rank as
(
select *, dense_rank() over(partition by years order by total_laid_off Desc) as ranking
from Company_Year
Where years is not null
)
select * from Company_Year_Rank
where ranking <= 5;