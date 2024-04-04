------------------ Question 3 - No. 1 ------------------------------
with Difference_Date as(  
select Cust_Id,  Calendar_Dt, (Calendar_Dt  - "Rank") "Date Difference"
from (select Distinct Cust_Id , Calendar_Dt , 
                   row_number() over(partition by cust_id  order by calendar_dt) "Rank"
         from CustomerDailyTransactions) 
)

select Cust_Id , max("Consecutive Days") "Maximum Consecutive Days"
from( 
        select Cust_Id , count("Date Difference") "Consecutive Days"
        from Difference_Date
        group by Cust_Id , "Date Difference" 
        )
group by Cust_Id
order by Cust_Id; 
 
------------------ Question 3 - No. 2 ------------------------------
select Round(avg("Count Days"),2) "Average Days"
    from  ( 
    select Cust_Id, min(case when "Total Amount" >= 250 then "Rank" end ) "Count Days"
        from ( 
        select Cust_Id,"Total Amount" , row_number() over(partition by Cust_Id order by "Total Amount") "Rank"
            from (
            select Cust_Id, sum(Amt_LE) over(partition by Cust_Id order by Calendar_Dt) "Total Amount"
                from CustomerDailyTransactions
                ))
     group by Cust_Id ) ;