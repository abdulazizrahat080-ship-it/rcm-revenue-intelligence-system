-- =========================
-- PATIENTS
-- =========================
CREATE TABLE patients_rcm (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100),
    gender VARCHAR(10),
    date_of_birth DATE
);

-- =========================
-- APPOINTMENTS
-- =========================
CREATE TABLE appointments_rcm (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_name VARCHAR(100),
    department VARCHAR(50),
    appointment_date DATE,
    FOREIGN KEY (patient_id) REFERENCES patients_rcm(patient_id)
);

-- =========================
-- PROCEDURES (CAN BE ADDED LATER → DRIFT)
-- =========================
CREATE TABLE procedures_rcm (
    procedure_id INT PRIMARY KEY,
    appointment_id INT,
    procedure_type VARCHAR(100),
    procedure_cost DECIMAL(10,2),
    added_date DATE,
    FOREIGN KEY (appointment_id) REFERENCES appointments_rcm(appointment_id)
);

-- =========================
-- CLAIMS (INITIAL SNAPSHOT)
-- =========================
CREATE TABLE claims_rcm (
    claim_id INT PRIMARY KEY,
    appointment_id INT,
    submitted_amount DECIMAL(10,2),
    submitted_date DATE,
    claim_status VARCHAR(50),
    FOREIGN KEY (appointment_id) REFERENCES appointments_rcm(appointment_id)
);

-- =========================
-- CLAIM EVENTS (FULL HISTORY)
-- =========================
CREATE TABLE claim_events_rcm (
    event_id INT PRIMARY KEY,
    claim_id INT,
    event_type VARCHAR(50),  -- Submitted, Revised, Approved, Denied
    event_amount DECIMAL(10,2),
    event_date DATE,
    FOREIGN KEY (claim_id) REFERENCES claims_rcm(claim_id)
);

-- =========================
-- PAYMENTS (REAL MONEY FLOW)
-- =========================
CREATE TABLE payments_rcm (
    payment_id INT PRIMARY KEY,
    claim_id INT,
    payment_amount DECIMAL(10,2),
    payment_date DATE,
    payer_type VARCHAR(50), -- Insurance / Patient
    FOREIGN KEY (claim_id) REFERENCES claims_rcm(claim_id)
);
