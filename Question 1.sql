----------------1. Top 5 Customers------------------
select Customer_ID, "Total Transactions", "Total Quantity", "Total Spent", "Customer Rank"
from (select Customer_ID, 
               count(Distinct Invoice) "Total Transactions",
               sum(Quantity) "Total Quantity",
               sum(Quantity * Price) "Total Spent",
               row_number() over (order by sum(Quantity * Price) desc) "Customer Rank"
        from tableRetail
        group by Customer_ID
        order by "Total Spent" desc)
where "Customer Rank" <= 5;
---------------2. Top 5 Selling Product ----------------------
select distinct StockCode, "Product Revenues", "Product Rank" 
from (select distinct StockCode,
                  sum(quantity * price) "Product Revenues",
                  rank() over(order by sum(quantity * price) desc  ) "Product Rank"
          from tableRetail
          group by StockCode)
where "Product Rank" <= 5;
-----------------------3. Items Frequently Bought Together----------------------------
with TransactionItem as (
    select Distinct Invoice, StockCode
    from tableRetail
    group by Invoice, StockCode),
ItemsPairs as (
    select Distinct t1.StockCode "Item 1", t2.StockCode "Item 2", count(*) "Count"
    from TransactionItem t1 join TransactionItem t2 on t1.Invoice = t2.Invoice
    where t1.StockCode < t2.StockCode
    group by t1.StockCode, t2.StockCode)
select "Item 1", "Item 2", "Count"
from ItemsPairs
where rownum <= 5
order by "Count" desc;
-------------------4. Churn Rate by Customer Count--------------------
with Churned_Customers as (
select count(Customer_ID) "Churned Count"
from (select Customer_ID, trunc(("Churned" / 30)) "Rate"
        from (select Customer_ID, ("Reference Date" - "Last Value") "Churned"
                  from (select Distinct Customer_ID, 
                                     last_value(to_date(invoicedate,'mm/dd/yyyy hh24:mi')) over(order by to_date(invoicedate,'mm/dd/yyyy hh24:mi') range between unbounded preceding and unbounded following) "Reference Date",
                                     last_value(to_date(invoicedate,'mm/dd/yyyy hh24:mi')) over(partition by customer_id order by to_date(invoicedate,'mm/dd/yyyy hh24:mi') range between unbounded preceding and unbounded following) "Last Value"
                           from tableRetail))
where "Churned" / 30 >= 3)
),
Total_Customers as (
    select count(distinct Customer_ID) "Total Count"
    from tableRetail
)
select "Total Count", "Churned Count" , trunc(("Churned Count" / "Total Count")*100) ||''|| '%' "Churn Rate"
from Churned_Customers, Total_Customers;
-----------------------5. Growth Rate By Customer Count Every Month-------------------------
with Monthly_Customer_Count as (
select
        to_char(to_date(invoicedate ,'mm/dd/yyyy HH24:MI'), 'yyyy') "Year" , 
        to_char(to_date(invoicedate ,'mm/dd/yyyy HH24:MI'), 'mm') "Month",
        count(Distinct customer_id) "Customers Monthly Count"
        from tableRetail 
 group by  to_char(to_date(invoicedate ,'mm/dd/yyyy HH24:MI'), 'yyyy') , to_char(to_date(invoicedate ,'mm/dd/yyyy HH24:MI'), 'mm')
                    ) ,
Previous_Month_Customer_Count as (
select "Year", "Month", "Customers Monthly Count",
        lag("Customers Monthly Count") over (order by "Year", "Month") "Previous Month Customer Count"
from Monthly_Customer_Count
)
select "Year", "Month", "Customers Monthly Count", round(("Customers Monthly Count" - "Previous Month Customer Count") / "Previous Month Customer Count" * 100 , 2) as "Growth_rate %"
from Previous_Month_Customer_Count; 
--------------------------6. Time Series Analysis By Month-----------------
select 
    trunc(to_date(InvoiceDate, 'mm/dd/yyyy hh24:mi'), 'month') "Month",
    sum(Price * Quantity) "Total Sales Amount",
    rank() over (order by sum(Price * Quantity) desc) "Sales Rank"
from tableRetail
group by trunc(to_date(InvoiceDate, 'mm/dd/yyyy hh24:mi'), 'month')
order by "Sales Rank";
