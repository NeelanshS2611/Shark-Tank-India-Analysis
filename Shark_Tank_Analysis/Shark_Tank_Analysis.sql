USE shark_tank_india;
select * from shark_tank;

-- 1. You Team must promote shark Tank India season 4, The senior come up with the idea to show highest funding 
-- domain wise so that new startups can be attracted, and you were assigned the task to show the same.


-- By Using Max function
Select industry,max(`Total_Deal_Amount(in_lakhs)`) as highest_fundings from shark_tank
group by industry
order by highest_fundings desc;

-- By Using Windows Function
-- Method 1 -  By using row_number()
With Cte as 
(Select industry, `Total_Deal_Amount(in_lakhs)`, 
row_number() over(Partition by industry Order by `Total_Deal_Amount(in_lakhs)` desc) rnk
from shark_tank)
Select industry, `Total_Deal_Amount(in_lakhs)` as Highest_funding from cte
where rnk = 1
order by Highest_funding desc;

-- Method 2. - by using DISTINCT, MAX, OVER
Select Distinct industry , max(`Total_Deal_Amount(in_lakhs)`) over(partition by industry) as Highest_funding from shark_tank
order by Highest_funding desc;

-- 2. Number of startups coming from diffrent cities
Select pitchers_city 
-- ,started_in
, count(*) as total_startups from shark_tank
Group by pitchers_city
Order by total_startups desc, pitchers_city;

-- 3. You have been assigned the role of finding the domain where female as pitchers have female to male pitcher ratio >70%
Select industry, Round((total_female_pitchers/total_male_pitchers)*100,2) as female_contribution from
(Select industry, sum(Male_Presenters) as total_male_pitchers, sum(Female_Presenters) as total_female_pitchers
from shark_tank group by industry having sum(Male_Presenters)>0 and sum(Female_Presenters)>0) as t
Where (total_female_pitchers/total_male_pitchers)*100>70;

-- 4.	You are working at marketing firm of Shark Tank India, 
--      you have got the task to determine volume of per season sale pitch made, 
--      pitches who received offer and pitches that were converted. 
-- 		Also show the percentage of pitches converted and percentage of pitches entertained.

SELECT * from shark_tank;
Select a.season_number, total_startups, total_startups_recived_offer, total_startups_accepted_offer, 
(total_startups_recived_offer/total_startups)*100 as recived_offer_percentage,
(total_startups_accepted_offer/total_startups_recived_offer)*100 as recived_offer_percentage  from
(Select season_number , count(Startup_name) as total_startups from shark_tank group by season_number) as a
Inner Join
(Select season_number , count(Startup_name) as total_startups_recived_offer from shark_tank
WHERE Received_Offer = 'Yes' group by season_number) as b
ON a.season_number = b.season_number
Inner join
(Select season_number , count(Startup_name) as total_startups_accepted_offer from shark_tank
WHERE Accepted_Offer = 'Yes'group by season_number) as c
On c.season_number = a.season_number;


-- 5. As a venture capital firm specializing in investing in startups featured on a renowned 
-- entrepreneurship TV show, you are determining the season with the highest average monthly sales 
-- and identify the top 5 industries with the highest average monthly sales during that season 
-- to optimize investment decisions?

Set @ssn= (
Select Season_Number from (
Select Season_Number , Avg(`Monthly_Sales(in_lakhs)`) as av from shark_tank
group by Season_Number
order by av desc
limit 1)t);

Select Industry, Round(avg(`Monthly_Sales(in_lakhs)`),2) as 'average_monthly_sale(in lakh)' from shark_tank
where Season_Number = @ssn
group by Industry
order by `average_monthly_sale(in lakh)` desc
limit 5;

-- 6. As a data scientist at our firm, your role involves solving real-world challenges like identifying industries 
-- with consistent increases in funds raised over multiple seasons. This requires focusing on industries where
-- data is available across all three seasons. Once these industries are pinpointed,
-- your task is to delve into the specifics, analyzing the number of pitches made, offers received, 
-- and offers converted per season within each industry.
With c as
(
Select Industry , sum(Case When season_number = 1 then `Total_Deal_Amount(in_lakhs)` End) as season_1,
sum(Case When season_number = 2 then `Total_Deal_Amount(in_lakhs)` End) as season_2,
sum(Case When season_number = 3 then `Total_Deal_Amount(in_lakhs)` End) as season_3 
From shark_tank
group by Industry
Having season_3>season_2 and season_2>season_1 and season_1 != 0
)
Select c.industry , o.season_number,
Count(o.Startup_Name) as total_pitches,
Count(case when o.Received_Offer= 'Yes' then Received_Offer end) as total_recived_offers,
count(case when o.Accepted_Offer= 'Yes' then Accepted_Offer end) as total_accepted_Offer
from c
inner join shark_tank as o ON c.industry = o.industry
group by c.industry , o.season_number
order by c.industry , o.season_number;

-- 7. Every shark wants to know in how much year their investment will be returned, 
-- so you must create a system for them, where shark will enter the name of the startup’s 
-- and the based on the total deal and equity given in how many years their principal 
-- amount will be returned and make their investment decisions

-- Stored Procedure

delimiter &&
Create procedure years_to_recover(in startup varchar(100))
begin case 
		when (Select Accepted_Offer = 'No' from shark_tank where Startup_Name = startup)
		then Select "TOT cann't be calculated as startup didnot accepted offer";
        when (Select Accepted_Offer = 'Yes' and `Yearly_Revenue(in_lakhs)` = 'Not mentioned' from shark_tank where Startup_Name = startup)
		then select "TOT cann't be calculated as Yearly Revenue is not available";
        Else
			(Select Startup_Name, `Yearly_Revenue(in_lakhs)`,`Total_Deal_Amount(in_lakhs)`,`Total_Deal_Equity(%)`,
            ROUND((`Total_Deal_Amount(in_lakhs)`/(`Total_Deal_Equity(%)`*100)*`Yearly_Revenue(in_lakhs)`),2) AS Years_To_Recover
            FROM shark_tank Where startup_name = startup);
End CASE;
end
  && delimiter
drop procedure years_to_recover

call years_to_recover("BluePineFoods");

-- 8. In the world of startup investing, we're curious to know which big-name investor, 
-- often referred to as "sharks," tends to put the most money into each deal on average. This comparison 
-- helps us see who's the most generous with their investments and how they measure up against their fellow investors.

Select * from shark_tank

Select "Namita" as Shark , `Namita_Investment_Amount(in lakhs)` as Investment from shark_tank 
Where `Namita_Investment_Amount(in lakhs)`>0
        
	