
    
    

select
    PAYMENT_ID as unique_field,
    count(*) as n_records

from BARCLAYS_DEMO.ANALYTICS.stg_payments
where PAYMENT_ID is not null
group by PAYMENT_ID
having count(*) > 1


