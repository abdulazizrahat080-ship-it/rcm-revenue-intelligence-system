-- BUSINESS PROBLEM:
-- Measure how effectively the system recovers revenue
-- from procedures added after initial claim submission

WITH initial_claims AS (

    -- Initial claim information per appointment
    SELECT
        appointment_id,
        MIN(submission_date) AS initial_submission_date,
        MAX(submitted_amount) AS initial_submitted_amount
    FROM claims_rcm
    GROUP BY appointment_id
),

late_procedures AS (

    -- Procedures added AFTER initial claim submission
    SELECT
        p.appointment_id,
        p.procedure_cost,
        p.added_date
    FROM procedures_rcm p
    INNER JOIN initial_claims ic
        ON p.appointment_id = ic.appointment_id
    WHERE p.added_date > ic.initial_submission_date
),

latest_claim_revisions AS (

    -- Get the MOST RECENT revision per claim
    SELECT
        c.appointment_id,
        ce.claim_id,
        ce.event_amount AS latest_revised_amount,
        ce.event_date AS latest_revision_date,

        ROW_NUMBER() OVER (
            PARTITION BY ce.claim_id
            ORDER BY ce.event_date DESC
        ) AS rn

    FROM claim_events_rcm ce

    INNER JOIN claims_rcm c
        ON ce.claim_id = c.claim_id

    WHERE ce.event_type = 'Revised'
),

claim_revisions AS (

    -- Keep only latest revision row
    SELECT
        appointment_id,
        claim_id,
        latest_revised_amount,
        latest_revision_date
    FROM latest_claim_revisions
    WHERE rn = 1
),

appointment_recovery AS (

    -- Appointment-level recovery calculations
    SELECT
        ic.appointment_id,

        SUM(lp.procedure_cost)
            AS total_late_procedure_cost,

        CASE
            WHEN MAX(cr.latest_revised_amount)
                 > ic.initial_submitted_amount
            THEN
                MAX(cr.latest_revised_amount)
                - ic.initial_submitted_amount
            ELSE 0
        END AS total_recovered_amount

    FROM initial_claims ic

    INNER JOIN late_procedures lp
        ON ic.appointment_id = lp.appointment_id

    LEFT JOIN claim_revisions cr
        ON ic.appointment_id = cr.appointment_id
       AND cr.latest_revision_date > lp.added_date

    GROUP BY
        ic.appointment_id,
        ic.initial_submitted_amount
)

SELECT
    ap.department,

    SUM(ar.total_late_procedure_cost)
        AS total_late_procedure_cost,

    SUM(ar.total_recovered_amount)
        AS total_recovered_amount,

    CASE
        WHEN SUM(ar.total_late_procedure_cost) = 0
        THEN 0

        ELSE
            SUM(ar.total_recovered_amount) * 100.0
            / SUM(ar.total_late_procedure_cost)

    END AS recovery_rate

FROM appointment_recovery ar

INNER JOIN appointments_rcm ap
    ON ar.appointment_id = ap.appointment_id

GROUP BY ap.department

ORDER BY recovery_rate DESC;
