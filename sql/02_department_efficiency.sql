-- BUSINESS PROBLEM:
-- Evaluate financial efficiency of departments based on procedures, billing, and payments.


with base as ( 
    select 
        x.appointment_id, 
        c.claim_id, 
        x.total_procedureCost_per_appoinment
    from ( 
        select 
            appointment_id, 
            sum(procedure_cost) as total_procedureCost_per_appoinment 
        from procedures_rcm
        group by appointment_id
    ) x
    left join claims_rcm c
        on x.appointment_id = c.appointment_id
), 

final_bill as (
    select 
        claim_id, 
        event_amount as final_bill_per_claim
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

total_payment as (
    select 
        claim_id, 
        sum(payment_amount) as total_payment_per_claim_id 
    from payments_rcm
    group by claim_id
)

select 
    ap.department, 

    sum(t.total_procedureCost_per_appoinment) as total_procedure_cost,

    sum(t.final_bill_per_appointment) as total_final_billed, 

    sum(t.total_payment_per_appointment) as total_payment_received, 

    case 
        when sum(t.total_procedureCost_per_appoinment) = 0 then 0
        else sum(t.final_bill_per_appointment) * 100.0 
             / sum(t.total_procedureCost_per_appoinment)
    end as billing_efficiency, 

    case 
        when sum(t.final_bill_per_appointment) = 0 then 0
        else sum(t.total_payment_per_appointment) * 100.0 
             / sum(t.final_bill_per_appointment)
    end as collection_efficiency 

from ( 
    select
        b.appointment_id, 


        b.total_procedureCost_per_appoinment, 


        isnull(fb.final_bill_per_claim, 0) as final_bill_per_appointment,

        isnull(pay.total_payment_per_claim_id, 0) as total_payment_per_appointment

    from base b

    left join final_bill fb
        on b.claim_id = fb.claim_id

    left join total_payment pay
        on b.claim_id = pay.claim_id

) t

inner join appointments_rcm ap 
    on t.appointment_id = ap.appointment_id


where t.appointment_id is not null

group by ap.department;
