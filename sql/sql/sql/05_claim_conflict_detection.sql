-- BUSINESS PROBLEM:
-- Detect workflow, financial, and billing inconsistencies
-- that may indicate revenue leakage or system integrity issues


WITH total_payment AS (

    SELECT
        claim_id,
        SUM(payment_amount) AS total_payment_received
    FROM payments_rcm
    GROUP BY claim_id
),

initial_claim_event AS (

    -- Earliest submitted claim row per claim
    SELECT
        claim_id,
        submitted_amount,
        submitted_date
    FROM (

        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY claim_id
                   ORDER BY submitted_date ASC
               ) AS rn
        FROM claims_rcm

    ) t
    WHERE rn = 1
),

final_bill_event AS (

    -- Latest approved billing event per claim
    SELECT
        claim_id,
        event_amount AS final_billed_amount,
        event_date
    FROM (

        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY claim_id
                   ORDER BY event_date DESC
               ) AS rn
        FROM claim_events_rcm
        WHERE event_type = 'Approved'

    ) t
    WHERE rn = 1
),

total_paymentVsfinalbill AS (

    -- Requirement 1:
    -- total_payment_received > final_billed_amount

    SELECT
        tp.claim_id,

        'Over_Payment' AS conflict_type,

        CONCAT(
            'payment exceeded by $',
            CAST(
                tp.total_payment_received
                - fb.final_billed_amount
                AS VARCHAR
            )
        ) AS details

    FROM total_payment tp

    INNER JOIN final_bill_event fb
        ON tp.claim_id = fb.claim_id

    WHERE ISNULL(tp.total_payment_received, 0)
          > ISNULL(fb.final_billed_amount, 0)
),

final_billed_amountVsinitial_claim_amount AS (

    -- Requirement 2:
    -- final_billed_amount < initial_claim_amount
    -- WITHOUT a Denied event

    SELECT
        ic.claim_id,

        'Payment_Mismatch' AS conflict_type,

        CONCAT(
            'mismatch by $',
            CAST(
                ISNULL(ic.submitted_amount, 0)
                - ISNULL(fb.final_billed_amount, 0)
                AS VARCHAR
            )
        ) AS details

    FROM initial_claim_event ic

    INNER JOIN final_bill_event fb
        ON ic.claim_id = fb.claim_id

    WHERE ISNULL(fb.final_billed_amount, 0)
          < ISNULL(ic.submitted_amount, 0)

      AND NOT EXISTS (

            SELECT 1
            FROM claim_events_rcm ce
            WHERE ce.claim_id = ic.claim_id
              AND ce.event_type = 'Denied'
      )
),

claim_statusVslatest_event AS (

    -- Requirement 3:
    -- claim_status = 'Approved'
    -- but latest event = 'Denied'

    SELECT
        t.claim_id,

        'Status_Mismatch' AS conflict_type,

        'workflow inconsistent' AS details

    FROM (

        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY claim_id
                   ORDER BY event_date DESC
               ) AS rn
        FROM claim_events_rcm

    ) t

    INNER JOIN claims_rcm c
        ON t.claim_id = c.claim_id

    WHERE t.rn = 1
      AND t.event_type = 'Denied'
      AND c.claim_status = 'Approved'
),

decreased_revised_amount AS (

    -- Requirement 4:
    -- final revision lower than earlier revision

    SELECT
        claim_id,

        'Suspicious_Revision_Drop' AS conflict_type,

        CONCAT(
            'revision drop by $',
            CAST(
                highest_revision
                - latest_revision_amount
                AS VARCHAR
            )
        ) AS details

    FROM (

        SELECT
            claim_id,

            event_amount AS latest_revision_amount,

            MAX(event_amount) OVER (
                PARTITION BY claim_id
            ) AS highest_revision,

            ROW_NUMBER() OVER (
                PARTITION BY claim_id
                ORDER BY event_date DESC
            ) AS rn

        FROM claim_events_rcm
        WHERE event_type = 'Revised'

    ) t

    WHERE rn = 1
      AND latest_revision_amount < highest_revision
),

final_cte AS (

    SELECT * FROM total_paymentVsfinalbill

    UNION ALL

    SELECT * FROM final_billed_amountVsinitial_claim_amount

    UNION ALL

    SELECT * FROM claim_statusVslatest_event

    UNION ALL

    SELECT * FROM decreased_revised_amount
)

SELECT
    c.appointment_id,
    f.claim_id,
    f.conflict_type,
    f.details

FROM final_cte f

INNER JOIN claims_rcm c
    ON c.claim_id = f.claim_id

ORDER BY
    c.appointment_id,
    f.claim_id;
