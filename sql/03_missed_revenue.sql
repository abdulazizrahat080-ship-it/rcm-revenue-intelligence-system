-- BUSINESS PROBLEM:
-- Identify revenue loss due to procedures added after claim submission
-- that were never captured in any claim revision

with late_procedures as ( 
    select 
        pro.appointment_id, 
        t.latest_claim_submission_date, 
        pro.procedure_cost, 
        pro.added_date
    from ( 
        select 
            appointment_id, 
            max(submitted_date) as latest_claim_submission_date 
        from claims_rcm 
        group by appointment_id
    ) t 
    inner join procedures_rcm pro 
        on t.appointment_id = pro.appointment_id
        and pro.added_date > t.latest_claim_submission_date
),

claim_events_mapped as ( 
    select 
        c.appointment_id, 
        ce.event_type,
        ce.event_date
    from claim_events_rcm ce
    inner join claims_rcm c
        on ce.claim_id = c.claim_id
), 

missed_late_procedures as ( 
    select 
        lp.appointment_id, 
        sum(lp.procedure_cost) as total_late_procedure_cost
    from late_procedures lp
    where not exists (
        select 1 
        from claim_events_mapped cem
        where lp.appointment_id = cem.appointment_id
          and cem.event_type = 'Revised'
          and cem.event_date >= lp.added_date
    )  
    group by lp.appointment_id
) 

select 
    mlp.appointment_id, 
    pat.patient_name, 
    mlp.total_late_procedure_cost,
    mlp.total_late_procedure_cost as missed_revenue
from missed_late_procedures mlp
join appointments_rcm ap 
    on mlp.appointment_id = ap.appointment_id
join patients_rcm pat
    on ap.patient_id = pat.patient_id;
