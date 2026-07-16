select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select PAYMENT_DATE
from BARCLAYS_DEMO.ANALYTICS.mart_payment_kpis
where PAYMENT_DATE is null



      
    ) dbt_internal_test