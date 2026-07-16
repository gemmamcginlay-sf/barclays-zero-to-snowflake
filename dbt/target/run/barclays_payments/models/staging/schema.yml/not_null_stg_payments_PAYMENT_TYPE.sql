select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select PAYMENT_TYPE
from BARCLAYS_DEMO.ANALYTICS.stg_payments
where PAYMENT_TYPE is null



      
    ) dbt_internal_test