select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    PAYMENT_ID as unique_field,
    count(*) as n_records

from BARCLAYS_DEMO.ANALYTICS.stg_payments
where PAYMENT_ID is not null
group by PAYMENT_ID
having count(*) > 1



      
    ) dbt_internal_test