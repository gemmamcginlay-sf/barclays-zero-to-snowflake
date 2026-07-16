select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select PAYMENT_ID
from BARCLAYS_DEMO.ANALYTICS.stg_payments
where PAYMENT_ID is null



      
    ) dbt_internal_test