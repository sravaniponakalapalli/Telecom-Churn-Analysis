create database Telecom
use Telecom

drop table if exists customer
create table customer(
    customer_id INT NOT NULL PRIMARY KEY,
    age TINYINT NULL,
    gender NVARCHAR(20) NULL,
    region NVARCHAR(50) NULL,
    acquisition_channel NVARCHAR(50) NULL,
    segment NVARCHAR(50) NULL,
    credit_score_band NVARCHAR(20) NULL,
    join_date DATE NULL)

bulk insert customer
from 'C:\Users\srava\Desktop\excel csv files\Data files\Customer.csv'
with (firstrow = 2,fieldterminator = ',',rowterminator = '\n',format = 'csv')

select *
from customer
-------------------------------------------------
drop table if exists Payment
create table Payment(
payment_id int not null Primary key,
customer_id int not null,
billing_month int not null,
amount_paid decimal(10,2) not null,
payment_status varchar(20) null,
foreign key(customer_id) references customer(customer_id)
)

bulk insert payment
from 'C:\Users\srava\Desktop\excel csv files\Data files\Payment.csv'
with (firstrow=2,fieldterminator=',',rowterminator='\n',format='csv')

select *
from payment
------------------------------------------------------------
drop table if exists subscription
create table subscription(
subscription_id int not null primary key,
customer_id int not null,
plan_type varchar(20) not null,
contract_type varchar(20) not null check(contract_type in ('Monthly','1-year','2-year')),
internet_type varchar(20) not null,
tenure_months int not null,
monthly_fee decimal(10,2) not null,
churn_flag bit not null,
foreign key(customer_id) references customer(customer_id)
)
create index Ix_subscription_customer
on subscription(subscription_id)

bulk insert subscription
from 'C:\Users\srava\Desktop\excel csv files\Data files\Subscription.csv'
with(firstrow=2,fieldterminator=',',rowterminator='\n',format='csv')

select *
from subscription
---------------------------------------------
drop table if exists support_ticket
create table support_ticket(
ticket_id int not null Primary key,
customer_id int not null,
issue_type varchar(20) not null check(issue_type in('Billing','Cancellation','Technical','Network')),
resolution_time_hours int not null,
satisfaction_score int null,
escalation_flag bit not null,
foreign key(customer_id) references customer(customer_id)
)
create index Ix_support_ticket_cust_id
on support_ticket(customer_id)

bulk insert support_ticket
from 'C:\Users\srava\Desktop\excel csv files\Data files\Support Ticket.csv'
with(firstrow=2,fieldterminator=',',rowterminator='\n',format='csv')

select *
from support_ticket
-------------------------------------------------------------
drop table if exists usage_metrics
create table usage_metrics(
customer_id int not null primary key,
avg_data_gb decimal(10,2) not null,
avg_call_minutes decimal(10,2) not null,
roaming_usage bit not null,
late_payment_count int not null,
downtime_hours varchar(50) null,
foreign key(customer_id) references customer(customer_id)
)

bulk insert usage_metrics
from 'C:\Users\srava\Desktop\excel csv files\Data files\Usage Metrics.csv'
with(firstrow=2,fieldterminator=',',rowterminator='\n',format='csv')

select *
from usage_metrics
------------------------------------------------------------
--Validate row Count
select COUNT(*)
from customer
select COUNT(*)
from subscription
select COUNT(*)
from usage_metrics
select COUNT(*)
from support_ticket
select COUNT(*)
from Payment

-- check Primary keys and duplicates
select customer_id,COUNT(*)
from customer
group by customer_id
having COUNT(*) >1

-- Validate joins
select COUNT(*)
from subscription s
left join customer c
on s.customer_id=c.customer_id
where c.customer_id is null

-- Check missing values
select COUNT(*) as total_cust,sum(case when credit_score_band is null then 1 else 0 end) as missing_credit_score
from customer

select COUNT(*) as total_cust,sum(case when downtime_hours is null then 1 else 0 end) as missing_downtime_hrs
from usage_metrics

-- check Negative downtime errors
select COUNT(*) as negative_downtime_hrs
from usage_metrics
where downtime_hours <0

alter table usage_metrics
alter column downtime_hours float

-- check overall churn rate
select COUNT(*) as total_customers,SUM(cast(churn_flag as int)) as churned_customers,cast(SUM(cast(churn_flag as int))*100.0/COUNT(*) as decimal(5,2)) as churn_rate_percentage
from subscription
/* 
Approximately 18.43% of customers churned, which equals about 3,686 customers. With an average monthly fee of $80, this represents roughly $294,880 in monthly revenue at risk,
or about $3.5 million in annual revenue impact.
*/


-- where churn happening?
select contract_type,COUNT(*) as total_customers,SUM(cast(churn_flag as int)) as churned_customers,cast(SUM(cast(churn_flag as int))*100.0/COUNT(*) as decimal(5,2)) as churn_rate_percentage
from subscription
group by contract_type
/*
Customers on Monthly contracts are churning at: 25.97%. That’s 7.5 percentage points higher than company average.
This means:
- Month-to-month customers are significantly less loyal
- Long-term contracts likely reduce churn risk
- Retention strategy should focus here first
*/


-- Revenue lost by each contract type due to churn?
select contract_type,SUM(case when churn_flag=1 then monthly_fee else 0 end) as revenue_lost
from subscription
group by contract_type
order by revenue_lost desc
/*
From churned customers on Monthly contracts alone: $200K+ per month lost
Annualized: $200,455.85 × 12 = $2.4M per year
Even though 2-Year contracts may have lower churn,
Monthly contracts are:
- High volume
- High instability
- Major revenue leakage source
This is where retention strategy must focus first.
*/


-- Which tenure group has the highest churn rate?
select case when tenure_months < 12 then '0-12 Months'
when tenure_months between 12 and 24 then '12-24 Months'
else '24+ Months' end as Tenure_Months,COUNT(*) as total_customers,SUM(cast(churn_flag as int)) as total_churn,
cast(SUM(cast(churn_flag as int))*100.0/COUNT(*) as decimal(5,2)) as churn_rate_percent
from subscription
group by case when tenure_months < 12 then '0-12 Months'
when tenure_months between 12 and 24 then '12-24 Months'
else '24+ Months' end
order by churn_rate_percent desc
/*
Customers in their first 12 months churn at: 26.36%
That is ~8 percentage points above company average.
This tells us:
The highest churn risk is in the first year.
*/


-- Are early-stage customers AND monthly contracts the dangerous combination?
select case when tenure_months < 12 then '0-12 Months'
when tenure_months between 12 and 24 then '12-24 Months'
else '24+ Months' end as Tenure_Months,COUNT(*) as total_customers,SUM(cast(churn_flag as int)) as total_churn,
cast(SUM(cast(churn_flag as int))*100.0/COUNT(*) as decimal(5,2)) as churn_rate_percent
from subscription
where contract_type = 'Monthly'
group by case when tenure_months < 12 then '0-12 Months'
when tenure_months between 12 and 24 then '12-24 Months'
else '24+ Months' end
order by churn_rate_percent desc
/*
Customers in their first 12 months are churning at: 34.01%
Compare that to overall churn (18.43%). That’s almost 2x the company average.
This suggests:
- The problem is not long-term loyalty.
- The problem is early customer experience.
*/


-- Revenue Risk of First-Year Customers
select SUM(monthly_fee) as revenue_loss_by_first_yr
from subscription
where tenure_months <12 and churn_flag=1
/*
Youre losing: $76,229.68 per month from customers who churn within their first 12 months.
Annualized: $914,756 per year
Thats nearly $1 million annually just from early churn.
This suggests:
The company does NOT have a long-term loyalty problem. It has a first-year customer stabilization problem.
*/


-- Are churned customers experiencing late payments?
select churn_flag,SUM(u.late_payment_count) as late_payments,AVG(cast(late_payment_count as float)) as avg_late_payment
from subscription s
join usage_metrics u
on s.customer_id=u.customer_id
group by churn_flag
/*
Late payments alone are not a strong primary driver. They may contribute to churn, but they are not the root cause.
*/


-- Are churned customers experiencing Higher downtime?
select churn_flag,AVG(downtime_hours) as avg_downtime_hrs
from subscription s
join usage_metrics u
on s.customer_id=u.customer_id
where downtime_hours >0
group by churn_flag
/*
Churned customers experience: ~16% more service downtime
This suggests:
- Downtime is not random noise.
- It is operationally linked to churn risk.
*/


-- Are churned customers experiencing More support escalations?
select churn_flag,avg(cast(satisfaction_score as float)) as avg_satisfaction_score
from subscription s
join support_ticket st
on s.customer_id = st.customer_id
group by churn_flag
/* Satisfaction score in this dataset is not a strong churn driver. */


-- Are cancellation-related support tickets a churn signal?
select churn_flag,COUNT(case when issue_type='cancellation' then 1 end)*1.0/COUNT(*) as cancelation_rate
from subscription s
join support_ticket st
on s.customer_id = st.customer_id
group by churn_flag
/* Cancellation tickets are not significantly higher for churned customers. Which means a large portion of churn happens without formal cancellation support tickets.*/


-- Is churn higher in certain regions?
select region,COUNT(*) as total_customers,SUM(cast(churn_flag as float)) as churn_count,SUM(cast(churn_flag as float))*100.0/COUNT(*) as churn_rate_per
from subscription s
join customer c
on s.customer_id = c.customer_id
group by region
/*
Churn is evenly distributed geographically.
This tells us:
- It’s not a regional network failure
- It’s not a localized competitor issue
- It’s not region-specific pricing
*/


-- ARPU of churned vs non-churned customers
select churn_flag,AVG(monthly_fee) as ARPU
from subscription
group by churn_flag
/*
You are not disproportionately losing high-value customers. Churned customers generate about the same revenue as retained customers.
That means:
- The problem is volume-based churn, not premium-customer churn.
- Revenue risk is driven by how many leave — not by losing expensive plans.
*/


-- ARPU by Plan Type
select plan_type,COUNT(*) as total_customers,AVG(monthly_fee) as ARPU,SUM(cast(churn_flag as float)) as total_churn,SUM(cast(churn_flag as float))*100.0/COUNT(*) as churn_rate
from subscription
group by plan_type
/*
Churn is nearly identical across plans all plans are around 18–19% churn.
That means:
Pricing tier is NOT driving churn.
You are not losing customers because plans are too expensive.
*/


/*
The strongest signal in entire analysis is:
First 12 months + Monthly contracts = highest churn risk.
That suggests:
- The problem is not product-market fit.
- It is commitment & onboarding stabilization.
*/

-- Is “Monthly + 0-12 Months” the most dangerous segment?
select contract_type,case when tenure_months <12 then '0-12 months' else '12+ months' end as tenure_group,COUNT(*) as total_customers,
SUM(cast(churn_flag as float)) as total_churn,SUM(cast(churn_flag as float))*100.0/COUNT(*) as churn_rate
from subscription
group by contract_type,case when tenure_months <12 then '0-12 months' else '12+ months' end
order by churn_rate desc
/*
Monthly + 0–12 months is 34% churn. That is nearly double the company average (18.43%).
- Long-term contracts dramatically reduce churn (8–10% for 12+ months)
- Monthly contracts are inherently unstable
- The first year is the most critical window
This means: The company doesn’t have a pricing problem. It has a commitment + onboarding problem.
*/


-- Create a clean modeling dataset(churn_modeling_dataset)in SQL
select *
from subscription
select *
from usage_metrics
select *
from support_ticket

select s.customer_id,s.tenure_months,s.contract_type,s.plan_type,s.monthly_fee,s.churn_flag,um.late_payment_count,
case when um.downtime_hours <0 then null else um.downtime_hours end as downtime_hours,COUNT(st.ticket_id) as total_tickets,
AVG(cast(st.satisfaction_score as float)) as avg_satisfaction_scr,SUM(case when st.escalation_flag = 1 then 1 else 0 end) as escalation_count
into churn_modeling_dataset
from subscription s
left join usage_metrics um
on s.customer_id=um.customer_id
left join support_ticket st
on s.customer_id=st.customer_id
group by s.customer_id,s.tenure_months,s.contract_type,s.plan_type,s.monthly_fee,s.churn_flag,um.late_payment_count,
case when um.downtime_hours <0 then null else um.downtime_hours end 

select *
from churn_modeling_dataset
order by customer_id
drop table if exists churn_modeling_dataset

SELECT
    SUM(CASE WHEN downtime_hours IS NULL THEN 1 ELSE 0 END) AS null_downtime,
    SUM(CASE WHEN avg_satisfaction_scr IS NULL THEN 1 ELSE 0 END) AS null_satisfaction
FROM churn_modeling_dataset
