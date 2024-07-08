# 1. What is the count of distinct cities in the dataset?
select count(distinct city) as distinct_cities from amazon;

# 2. For each branch, what is the corresponding city?
select branch, city from amazon group by branch, city;
# using group by with branch & city all rows with the same branch and city combination will be grouped together.

# 3. What is the count of distinct product lines in the dataset?
select count(distinct Product_line) as distinct_Product_line from amazon;

# 4. Which payment method occurs most frequently?
select payment, count(*) as frequency from amazon 
group by payment #Group by is used to aggregate the count for each unique payment menthod
order by frequency desc     #order by arranges the frequency column in descending order
limit 1;    #results only one row, hence returning the payment method with highest frequency

# 5. Which product line has the highest sales?
Select product_line, Round(sum(total),2) as total_sales 
from amazon 
group by product_line 
order by total_sales desc 
limit 1;

#6 How much revenue is generated each month?
Select Year(Date_purchase) AS Order_Year, #this selects the year, month using the Year and monthname statements
    monthname(Date_purchase) AS Order_Month,
    Round(SUM(Total),2) AS Monthly_Revenue     #total revenue is calculated using sum statement
From amazon
Group By
    Year(Date_purchase),       #this will group the result by Year and month. Total sales will be divided for each month and year combination
    Monthname(Date_purchase);

#7 In which month did the cost of goods sold reach its peak?
Select Monthname(Date_purchase) AS Order_Month, Round(Sum(Cogs),2) AS COGS
From amazon 
Group By monthname(Date_purchase)
Order By COGS DESC Limit 1;

#8 Which product line generated the highest revenue?
Select Product_line, Round(Sum(total),2) as Revenue from amazon
Group by Product_line 
Order by Revenue desc Limit 1;

#9 In which city was the highest revenue recorded?
Select City, Round(Sum(total),2) as Revenue from amazon
Group by City 
Order by Revenue desc Limit 1;

#10 Which product line incurred the highest Value Added Tax?
Select Product_line, Sum(Total_VAT) as Total_VAT from amazon
Group By Product_line
Order by Total_VAT desc Limit 1;

#11 For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
Select Product_line, Total, Case
When Total> avg_sales Then 'Good' Else 'Bad' End as Sales_category 
From amazon 
Join 
(select avg(Total) as avg_sales from amazon) as avg_table 
on 1=1;   
#Case statement is used to categorize the sales as "Good" if the Total sales for a product line 
#are above the average sales (avg_sales), and "Bad" otherwise.
#Join is used for joining the main amazon table with the result of the subquery. 
#This subquery calculates the average total sales across all product lines as we alias it as avg_table.
# 1=1 condition is a placeholder condition that's always true, effectively performing a cross join.
#This ensures that each row in the amazon table is compared against the average sales.           

#12 Identify the branch that exceeded the average number of products sold.
Select Branch, Sum(quantity) as products_sold from Amazon
Group by Branch
Having sum(quantity) > (Select avg(products_sold)
From (select sum(quantity) as products_sold from amazon group by branch) as Avg_table);

# we are calculating the total quantity of the product sold
# We calculate the average number of products sold across all branches. The inner subquery sums up the quantity sold for each branch, 
# and then the outer query calculates the average of these totals using the AVG function.
# the Having clause filters out branches where the sum of quantities sold is > than the avg.

#13 Which product line is most frequently associated with each gender?
With gender_product_frequency AS (
    Select gender,
           product_line,
           COUNT(*) AS frequency,
           Row_number() Over (Partition By gender Order By COUNT(*) Desc) as rn
    From amazon
    Group By gender, product_line
)
Select gender, product_line, frequency
From gender_product_frequency
Where rn = 1;

#CTE is used to for each product line for each gender.
# Row-number assigs a unique integer to each row with a partition of gender. The rows are order by frequency in desc order
# where filters only those results where the row number is 1

#14 Calculate the average rating for each product line.
SELECT product_line, round(AVG(rating),2) AS average_rating
FROM amazon
GROUP BY product_line order by average_rating desc;

#15 Count the sales occurrences for each time of day on every weekday.
Alter table amazon 
Add column dayweek varchar(14),
Add column time_of_day varchar(20);

Update amazon set dayweek = dayname(Date_purchase);
Update amazon set time_of_day = CASE
        WHEN TIME(Time_purchase) >= '06:00:00' AND Time(Time_purchase) < '12:00:00' THEN 'Morning'
        WHEN TIME(Time_purchase) >= '12:00:00' AND Time(Time_purchase) < '18:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END;

Select dayweek, time_of_day, count(*) as sales_occurrences 
From amazon Group by dayweek, time_of_day Order by dayweek, time_of_day;

#16 Identify the customer type contributing the highest revenue.
Select customer_type, Round(Sum(total),2) as revenue from amazon
group by customer_type order by revenue desc limit 1;

#17 Determine the city with the highest VAT percentage.
Select city, round(Sum(total_VAT),2) as total_VAT from amazon
Group by city order by total_VAT desc limit 1;

#18 Identify the customer type with the highest VAT payments.
Select Customer_type, round(Sum(total_VAT),2) as total_VAT from amazon
Group by Customer_type order by total_VAT desc limit 1;

#19 What is the count of distinct customer types in the dataset?
Select count(distinct customer_type) as distinct_customer_type from amazon;

#20 What is the count of distinct payment methods in the dataset?
Select count(distinct payment) as distinct_payment_method from amazon;

#21 Which customer type occurs most frequently?
Select customer_Type, Count(*) as frequency from amazon
group by customer_type order by frequency desc limit 1;

#22 Identify the customer type with the highest purchase frequency.
Select customer_Type, count(distinct Invoice_id) as purchase_frequency from amazon
group by Customer_type order by purchase_frequency desc limit 1;

#23 Determine the predominant gender among customers.
Select gender, count(*) as gender_count From amazon Group by Gender order by gender_count desc limit 1;

#24 Examine the distribution of genders within each branch.
Select Branch, Gender, count(*) as count From amazon
Group by Branch, Gender Order by Branch, Gender;	

#25 Identify the time of day when customers provide the most ratings.
Select time_of_day, count(*) as rating_frequency from amazon
group by time_of_day order by rating_frequency desc Limit 1;

#26 Determine the time of day with the highest customer ratings for each branch.
Select time_of_day, Branch, rating_frequency from (
Select 	branch, time_of_day, count(*) as rating_frequency,
Row_number() over (partition by branch order by count(*) desc) as rn
from amazon
Group by branch, time_of_day) as rating_time where rn = 1
order by branch; 

#27 Identify the day of the week with the highest average ratings.
Select dayweek, round(avg(rating),2) as avg_rating from amazon
Group by dayweek order by avg(rating) desc limit 1;

#28 Determine the day of the week with the highest average ratings for each branch.
Select dayweek, Branch, avg_rating from (
Select 	branch, dayweek, round(avg(rating),2) as avg_rating,
Row_number() over (partition by branch order by avg(rating) desc) as rn
from amazon
Group by branch, dayweek) as avg_rating_time where rn = 1
order by branch; 





