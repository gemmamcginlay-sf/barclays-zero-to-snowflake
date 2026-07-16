select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select TOTAL_PAYMENTS
from BARCLAYS_DEMO.ANALYTICS.mart_payment_kpis
where TOTAL_PAYMENTS is null



      
    ) dbt_internal_test