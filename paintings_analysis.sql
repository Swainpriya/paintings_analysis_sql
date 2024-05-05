# create database

CREATE DATABASE IF NOT EXISTS paintings;

# use database

USE paintings;

# turn off safe updates

SET sql_safe_updates = 0;

# Fetch all the paintings which are not displayed on any museums?

SELECT 
    *
FROM
    work
WHERE
    museum_id IS NULL;

# Are there museuems without any paintings?

SELECT 
    *
FROM
    museum
WHERE
    museum_id NOT IN (SELECT 
            museum_id
        FROM
            work);

# How many paintings have an asking price of more than their regular price? 

SELECT 
    COUNT(work_id) AS total_paintings
FROM
    product_size
WHERE
    sale_price > regular_price;

# Identify the paintings whose asking price is less than 50% of its regular price

SELECT 
    *
FROM
    product_size
WHERE
    sale_price < (regular_price * 0.5);

# Which canva size costs the most?

SELECT 
    cs.label, ps.sale_price
FROM
    canvas_size AS cs
        JOIN
    product_size AS ps ON cs.size_id = ps.size_id
GROUP BY cs.label , ps.sale_price
ORDER BY ps.sale_price DESC
LIMIT 1;

# Delete duplicate records from work, product_size, subject and image_link tables

create temporary table temp_work_table as select min(work_id) as min_primary_key from work group by work_id;
DELETE FROM work 
WHERE
    work_id NOT IN (SELECT 
        *
    FROM
        temp_work_table); 


create temporary table temp_size_table as select min(work_id) as min_primary_key from product_size group by work_id, size_id;
DELETE FROM product_size 
WHERE
    work_id NOT IN (SELECT 
        *
    FROM
        temp_size_table);

create temporary table temp_subject_table as select min(work_id) as min_primary_key from subject group by work_id,subject;
DELETE FROM subject 
WHERE
    work_id NOT IN (SELECT 
        *
    FROM
        temp_subject_table);

create temporary table temp_image_table as select min(work_id) as min_primary_key from image_link group by work_id;
DELETE FROM image_link 
WHERE
    work_id NOT IN (SELECT 
        *
    FROM
        temp_image_table);

# Identify the museums with invalid city information in the given dataset

SELECT 
    *
FROM
    museum
WHERE
    city REGEXP '^[0-9]';

# Fetch the top 10 most famous painting subject

SELECT 
    subject, COUNT(*) AS total_paintings
FROM
    subject
GROUP BY subject
ORDER BY total_paintings DESC
LIMIT 10;

# Identify the museums which are open on both Sunday and Monday. Display museum name, city.

SELECT 
    name AS museum_name, city
FROM
    museum
WHERE
    museum_id IN (SELECT 
            museum_id
        FROM
            museum_hours
        WHERE
            day = 'sunday')
        AND museum_id IN (SELECT 
            museum_id
        FROM
            museum_hours
        WHERE
            day = 'monday');
            
# How many museums are open every single day?

SELECT 
    day, COUNT(museum_id) AS total_museums
FROM
    museum_hours
GROUP BY day;

# Who are the top 5 most popular artist?

SELECT 
    full_name, COUNT(*) AS total_paintings
FROM
    artist
        INNER JOIN
    work ON artist.artist_id = work.artist_id
GROUP BY artist.full_name
ORDER BY total_paintings DESC
LIMIT 5;

# Which country has the 5th highest no of paintings?

SELECT 
    m.country, COUNT(work_id) AS total_paintings
FROM
    museum AS m
        JOIN
    work AS w ON m.museum_id = w.museum_id
GROUP BY m.country
ORDER BY total_paintings DESC
LIMIT 1 OFFSET 4;

# Which are the 3 most popular and 3 least popular painting styles?

(SELECT 
    style,
    COUNT(*) AS total_paintings,
    'most popular' AS remarks
FROM
    work
GROUP BY style
ORDER BY total_paintings DESC
LIMIT 3) UNION (SELECT 
    style,
    COUNT(*) AS total_paintings,
    'least popular' AS remarks
FROM
    work
GROUP BY style
ORDER BY total_paintings ASC
LIMIT 3);

