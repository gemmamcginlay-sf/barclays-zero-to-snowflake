
    
    

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


