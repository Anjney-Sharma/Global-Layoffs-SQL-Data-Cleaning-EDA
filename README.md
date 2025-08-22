# Global-Layoffs-SQL-Data-Cleaning-EDA

## 📌 Project Overview

This project focuses on analyzing global layoffs data using SQL. The workflow involves data cleaning, transformation, and exploratory data analysis (EDA) to uncover key insights such as industries and countries most impacted, timeline trends, and company-level layoff patterns.

## 🎯 Objectives

Remove duplicates

Standardize company, industry, and country names

Handle null/blank values

Convert date formats to SQL DATE type

Remove unwanted columns

Perform exploratory data analysis to extract insights

## 🛠️ Tech Stack

SQL (MySQL) – Data Cleaning & EDA

## 📂 Key Steps

Data Cleaning

Created staging tables for safe modifications

Removed duplicates using ROW_NUMBER()

Standardized textual data (company, industry, country)

Converted date field from TEXT to DATE

Filled missing values using joins

Dropped irrelevant columns

Exploratory Data Analysis (EDA)

Identified companies with maximum layoffs

Analyzed layoffs by industry, country, and funding stage

Explored layoff patterns by year and month

Calculated rolling totals for trend analysis

Ranked top companies with layoffs each year

## 📊 Insights Extracted

Companies with 100% workforce laid off were identified.

Tech and Finance industries showed the largest layoffs.

United States had the highest layoffs count.

Peak layoffs occurred in specific years, with rolling totals highlighting downturn phases.

Top 5 companies with the highest layoffs were ranked per year.
