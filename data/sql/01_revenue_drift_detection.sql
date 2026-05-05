Problem Statement: Management wants to understand how much revenue they are loosing or recovering from each appointment
  based on actual procedures vs billing vs payments.

  Query summary: Simply analyzing revenue leakage and recovery at appointment level. Basically, comparing procedures, 
  claims, and payments. 


with base as ( 
    select 
        c.claim_id, 
        t.appointment_id, 
        c.submitted_amount as initial_claim_amount, 
        c.claim_status, 
        t.total_procedure_cost
    from (
        select 
            appointment_id,                       
            sum(procedure_cost) as total_procedure_cost       
        from procedures_rcm
        group by appointment_id
    ) t
    left join claims_rcm c
        on c.appointment_id = t.appointment_id
),

final_bill as ( 
    select *
    from (
        select 
            claim_id,
            event_amount,
            event_date,
            row_number() over (
                partition by claim_id 
                order by event_date desc
            ) as rn
        from claim_events_rcm
    ) t
    where rn = 1
),

payments as (
    select 
        claim_id,
        sum(payment_amount) as total_payment_received
    from payments_rcm 
    group by claim_id
)

select 
    p.patient_name, 
    b.appointment_id, 
    b.total_procedure_cost, 
    b.initial_claim_amount, 
    fb.event_amount as final_billed_amount, 
    pay.total_payment_received, 

    isnull(b.total_procedure_cost, 0) 
        - isnull(b.initial_claim_amount, 0) as revenue_drift,

    isnull(fb.event_amount, 0) 
        - isnull(b.initial_claim_amount, 0) as revenue_recovered, 

    isnull(fb.event_amount, 0) 
        - isnull(pay.total_payment_received, 0) as payment_gap 

from base b

left join final_bill fb 
    on b.claim_id = fb.claim_id

left join payments pay 
    on b.claim_id = pay.claim_id

left join appointments_rcm ap 
    on b.appointment_id = ap.appointment_id

left join patients_rcm p
    on ap.patient_id = p.patient_id;
