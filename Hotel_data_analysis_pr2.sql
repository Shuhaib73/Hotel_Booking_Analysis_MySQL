-- Creates a new database named "hotel_project" if it doesn't already exist.
CREATE DATABASE IF NOT EXISTS hotel_project;

-- Sets the currently active database to "hotel_project." 
USE hotel_project;

-- Retrieves a list of all tables in the currently active database.
SHOW TABLES;

-- Counts and returns the total number of rows in the "hotel_booking" table.
SELECT COUNT(*) FROM hotel_booking;

-- Provides structural information about the "hotel_booking" table, including column names and data types
DESCRIBE hotel_booking;

-- Modifies the data type of the "reservation_status_date" column in the "hotel_booking" table to DATE.
ALTER TABLE hotel_booking
MODIFY COLUMN reservation_status_date DATE ;

--  Retrieves a list of unique values in the "company" column from the "hotel_booking" table. This query will return a list of distinct company names from the dataset.
SELECT DISTINCT company 
FROM hotel_booking;

-- This query counts the occurrences of empty / Null values in the "company" column. 
SELECT SUM(CASE WHEN company = "" THEN 1 ELSE NULL END) AS TOTAL_NULL
FROM hotel_booking;

-- This operation eliminates these two columns from the table schema. 
ALTER TABLE hotel_booking
DROP company,
DROP agenT;

-- This query groups the data by "adr"[Average Daily Rate] calculates the count, and orders the result in descending order based on "adr." 
SELECT 
	adr, 
	COUNT(*) AS count
FROM hotel_booking
GROUP BY adr
ORDER BY adr DESC;

-- Deletes rows from the "hotel_booking" table where the "adr" column is equal to 5400. 
-- Handling Outliers 
DELETE FROM hotel_booking
WHERE adr = 5400;

# Data Analysis

-- 1. This Query calculates the Percentage of Canceled and Non-Canceled Reservation  
SELECT 
	is_canceled, 
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM hotel_booking) * 100, 2) AS canceled_per
FROM hotel_booking
GROUP BY is_canceled;

-- This query will return a distinct list of hotel types from the dataset.
SELECT DISTINCT hotel 
FROM hotel_booking;

-- 2. This query provides insights into the cancellation rates specifically for "Resort Hotel" bookings.
SELECT 
	hotel, 
    is_canceled, 
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM hotel_booking WHERE hotel = 'Resort Hotel') * 100, 2) AS canceled_per
FROM hotel_booking
WHERE hotel = 'Resort Hotel'
GROUP BY is_canceled, hotel;

-- 3. This query provides insights into the cancellation rates specifically for "City Hotel" bookings.
SELECT 
	hotel, 
    is_canceled, 
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM hotel_booking WHERE hotel = 'City Hotel') * 100, 2) AS canceled_per
FROM hotel_booking
WHERE hotel = 'City Hotel'
GROUP BY is_canceled, hotel;

-- 4. This Query highlights the months with the highest cancellation rates for 'Resort Hotel' bookings, offering insights into seasonal patterns
SELECT 
	hotel, 
	is_canceled, 
    MONTH(reservation_status_date) as Months, ROUND(COUNT(*) / (SELECT COUNT(*) FROM hotel_booking WHERE hotel = 'Resort Hotel') * 100, 2) AS Canceled_per
FROM hotel_booking
WHERE hotel = 'Resort Hotel'
GROUP BY hotel, is_canceled, MONTH(reservation_status_date)
ORDER BY Canceled_per DESC;

-- 5. This Query highlights the months with the highest cancellation rates for 'City Hotel' bookings, offering insights into seasonal patterns
SELECT 
	hotel, 
    is_canceled, 
    MONTH(reservation_status_date) as Months, ROUND(COUNT(*) / (SELECT COUNT(*) FROM hotel_booking WHERE hotel = 'City Hotel') * 100, 2) AS Canceled_per
FROM hotel_booking
WHERE hotel = 'City Hotel'
GROUP BY hotel, is_canceled, MONTH(reservation_status_date)
ORDER BY Canceled_per DESC;

-- 6. This query calculates the total Average Daily Rate (ADR) for canceled reservations, grouped by the month in which the reservation status was recorded
SELECT 
	Month(reservation_status_date) AS Months, 
	ROUND(sum(adr)) total_adr
FROM hotel_booking 
WHERE is_canceled = 1
GROUP BY MONTH(reservation_status_date)
ORDER BY total_adr DESC;

-- 7. This SQL query analyzes the cancellation rates of reservations by country, highlighting the top 10 countries with the highest cancellation percentages.
SELECT 
	country, 
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM hotel_booking WHERE is_canceled = 1) * 100, 2) AS canceled_per
FROM hotel_booking
WHERE is_canceled = 1
GROUP BY country 
ORDER BY canceled_per DESC Limit 10;

-- 8. "What is the breakdown of booking and cancellation percentages by market segment? 
-- Provide insights into booking behavior for each segment and identify the segments with the highest booking and cancellation rates."

WITH T1 AS
(
SELECT 
	market_segment, 
	COUNT(*) AS Total_Bookings,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM hotel_booking) * 100, 2) AS Booking_per
FROM hotel_booking
GROUP BY market_segment
-- ORDER BY Total_Bookings DESC
),
T2 AS 
(
SELECT 
	market_segment,
	COUNT(*) AS Total_cancelations,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM hotel_booking WHERE is_canceled = 1) * 100, 2) AS canceled_per
FROM hotel_booking
WHERE is_canceled = 1
GROUP BY market_segment, is_canceled
) 
SELECT 
	T1.market_segment, 
    Total_Bookings, 
    Booking_per, 
    Total_cancelations, 
    canceled_per
FROM T1 JOIN T2 
ON T1.market_segment = T2.market_segment
ORDER BY Booking_per DESC, canceled_per DESC;



