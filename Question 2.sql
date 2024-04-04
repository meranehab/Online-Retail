----------------------Question 2-----------------------------
select Customer_ID, "Recency", "Frequency", "Monetary", "R Score", "FM Score", 
         case 
        when "R Score" = 5 and "FM Score" in (5, 4) then 'Champions'
        when "R Score" = 4 and "FM Score" = 5 then 'Champions'
        when "R Score" = 5 and "FM Score" = 2 then 'Potential Loyalists'
        when "R Score" = 4 and "FM Score" in (2 , 3) then 'Potential Loyalists'
        when "R Score" = 3 and "FM Score" = 3 then 'Potential Loyalists'
        when "R Score" = 5 and "FM Score" = 3 then 'Loyal Customers'
        when "R Score" = 4 and "FM Score" = 4 then 'Loyal Customers'
        when "R Score" = 3 and "FM Score" in (4 , 5) then 'Loyal Customers'
        when "R Score" = 5 and "FM Score" = 1 then 'Recent Customers'
        when "R Score" = 4 and "FM Score" = 1 then 'Promising'
        when "R Score" = 3 and "FM Score" = 1 then 'Promising'
        when "R Score" = 3 and "FM Score" = 2 then 'Customers Needing Attention'
        when "R Score" = 2 and "FM Score" in (2, 3) then 'Customers Needing Attention'
        when "R Score" = 1 and "FM Score" = 3 then 'At Risk'
        when "R Score" = 2 and "FM Score" in (4, 5) then 'At Risk'
        when "R Score" = 1 and "FM Score" = 2 then 'Hibernating'
        when "R Score" = 1 and "FM Score" in (4, 5) then 'Cant Lose Them'
        when "R Score" = 1 and "FM Score" = 1 then 'Lost'
        else 'Undefined'
    end "Customer Segmentation"
from (select Customer_ID, "Recency", "Frequency", "Monetary", ntile(5) over(order by "Recency" desc) "R Score", round(( "Frequency Ntile" + "Monetary Ntile")/2) "FM Score"
            from (select Customer_ID, "Recency", "Frequency", "Monetary", ntile(5) over(order by "Frequency" desc) "Frequency Ntile", ntile(5) over(order by "Monetary" desc) "Monetary Ntile"
                     from (select Customer_ID, trunc("Reference Date" - "Last Value") "Recency", count(distinct invoice) "Frequency", 
                                   round(sum(quantity * price) / 1000, 2) "Monetary"
                              from (select Customer_ID, Price, Quantity, Invoice,
                                                 last_value(to_date(invoicedate,'mm/dd/yyyy hh24:mi')) over(order by to_date(invoicedate,'mm/dd/yyyy hh24:mi') range between unbounded preceding and unbounded following) "Reference Date",
                                                 last_value(to_date(invoicedate,'mm/dd/yyyy hh24:mi')) over(partition by customer_id order by to_date(invoicedate,'mm/dd/yyyy hh24:mi') range between unbounded preceding and unbounded following) "Last Value"
                                       from tableRetail)
                              group by customer_id, "Last Value", "Reference Date"))
            order by customer_id);
-----------
