/*List of products with a base price greater than 500 and that are featured in promo type BOGOF, buy one get one free.*/
select p.product_name, f.base_price as Price
from fact_events f
left join dim_products p on f.product_code=p.product_code
where promo_type="BOGOF" AND base_price>500
order by price asc;


/*Generate a report that provides an overview of the number of stores in each city and results will be sorted in descending order of store counts. 
It includes essential fields, city, and store count.*/
select city, count(store_id) as Stores_Count
from dim_stores
group by city
order by Stores_Count desc;


/*Generate a report that displays each campaign along with the total revenue generated before and after the campaign.*/
SELECT c.Campaign_name,
       SUM(f.`quantity_sold(before_promo)`) AS Total_Before,
       SUM(f.`quantity_sold(after_promo)`)  AS Total_After
FROM dim_campaigns c
LEFT JOIN fact_events f
       ON c.campaign_id = f.campaign_id
GROUP BY c.campaign_name;


/*Produce a report that calculates the incremental sold quantity(ISU%), for each category during the Diwali campaign. 
Additionally, provide rankings for the categories based on their ISU%. 
The report will include three key fields, category, ISU%, and rank order. 
Note, ISU% (incremental sold quantity percentage) is calculated as the percentage increase/decrease in quantity sold 
after promo compared to quantity sold before promo.*/

select p.category , 
		ROUND(
        (SUM(f.`quantity_sold(after_promo)`) - SUM(f.`quantity_sold(before_promo)`))
        / NULLIF(SUM(f.`quantity_sold(before_promo)`), 0) * 100, 2) AS ISU_percentage,
		RANK() OVER (
        ORDER BY 
            (SUM(f.`quantity_sold(after_promo)`) - SUM(f.`quantity_sold(before_promo)`))
            / NULLIF(SUM(f.`quantity_sold(before_promo)`), 0) * 1.0 DESC
    ) AS rank_order
from fact_events as f
left join dim_campaigns as c on f.campaign_id = c.campaign_id
left join dim_products as p on f.product_code = p.product_code
where c.campaign_name = "Diwali"
group by p.category;


/*Create a report featuring the top 5 products ranked by Incremental Revenue Percentage (IR Percentage%) across all campaigns.*/
select p.product_name, p.category,
ROUND(
        (SUM(f.`quantity_sold(after_promo)`) - SUM(f.`quantity_sold(before_promo)`))
        / NULLIF(SUM(f.`quantity_sold(before_promo)`), 0) * 100, 2) AS ISU_percentage
from fact_events f
left join dim_products p on f.product_code=p.product_code
group by p.product_name, p.category
order by ISU_percentage DESC
Limit 5;






