select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        SLA_STATUS as value_field,
        count(*) as n_records

    from BARCLAYS_DEMO.ANALYTICS.mart_sla_compliance
    group by SLA_STATUS

)

select *
from all_values
where value_field not in (
    'COMPLIANT','AT RISK','BREACH'
)



      
    ) dbt_internal_test