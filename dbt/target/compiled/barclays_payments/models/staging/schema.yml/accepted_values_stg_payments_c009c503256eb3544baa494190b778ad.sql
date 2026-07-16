
    
    

with all_values as (

    select
        STATUS as value_field,
        count(*) as n_records

    from BARCLAYS_DEMO.ANALYTICS_ANALYTICS.stg_payments
    group by STATUS

)

select *
from all_values
where value_field not in (
    'COMPLETED','PENDING','FAILED','RETURNED'
)


