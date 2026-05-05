-- ============================================
-- PATIENTS
-- ============================================
INSERT INTO patients_rcm VALUES
(1,'Ava','F','1995-02-10'),
(2,'Ben','M','1988-06-15'),
(3,'Cara','F','1992-09-20'),
(4,'Dan','M','1985-01-11'),
(5,'Eli','M','1990-12-01'),
(6,'Fiona','F','1993-03-14'),
(7,'George','M','1987-07-22'),
(8,'Hana','F','1996-11-30');

-- ============================================
-- APPOINTMENTS
-- ============================================
INSERT INTO appointments_rcm VALUES
(101,1,'Dr. Rahman','Urology','2024-01-01'),
(102,2,'Dr. Karim','Nephrology','2024-01-02'),
(103,3,'Dr. Rahman','Urology','2024-01-03'),
(104,4,'Dr. Ahmed','Nephrology','2024-01-04'),
(105,5,'Dr. Rahman','Urology','2024-01-05'),
(106,6,'Dr. Karim','Nephrology','2024-01-06'),
(107,7,'Dr. Ahmed','Nephrology','2024-01-07'),
(108,8,'Dr. Rahman','Urology','2024-01-08');

-- ============================================
-- PROCEDURES
-- ============================================
INSERT INTO procedures_rcm VALUES
-- Ava (DRIFT + RECOVERY)
(1,101,'Consultation',500,'2024-01-01'),
(2,101,'Stone Removal',2000,'2024-01-03'),

-- Ben (CLEAN)
(3,102,'Dialysis',1500,'2024-01-02'),

-- Cara (DENIED)
(4,103,'Consultation',400,'2024-01-03'),

-- Dan (DRIFT + PARTIAL RECOVERY)
(5,104,'Consultation',500,'2024-01-04'),
(6,104,'Dialysis',1200,'2024-01-06'),

-- Eli (CLEAN)
(7,105,'Consultation',500,'2024-01-05'),

-- Fiona (MISSED REVENUE)
(8,106,'Consultation',600,'2024-01-06'),
(9,106,'Lab Test',900,'2024-01-08'),

-- George (REVISION CONFLICT)
(10,107,'Dialysis',1500,'2024-01-07'),

-- Hana (UNDERPAYMENT)
(11,108,'Consultation',500,'2024-01-08');

-- ============================================
-- CLAIMS
-- ============================================
INSERT INTO claims_rcm VALUES
(1001,101,500,'2024-01-01','Submitted'),
(1002,102,1500,'2024-01-02','Approved'),
(1003,103,400,'2024-01-03','Denied'),
(1004,104,500,'2024-01-04','Approved'),
(1005,105,500,'2024-01-05','Approved'),
(1006,106,600,'2024-01-06','Submitted'),
(1007,107,1500,'2024-01-07','Approved'),
(1008,108,500,'2024-01-08','Approved');

-- ============================================
-- CLAIM EVENTS
-- ============================================
INSERT INTO claim_events_rcm VALUES

-- Ava (RECOVERY)
(1,1001,'Submitted',500,'2024-01-01'),
(2,1001,'Revised',2500,'2024-01-04'),
(3,1001,'Approved',2500,'2024-01-06'),

-- Ben (CLEAN)
(4,1002,'Submitted',1500,'2024-01-02'),
(5,1002,'Approved',1500,'2024-01-03'),

-- Cara (DENIED)
(6,1003,'Submitted',400,'2024-01-03'),
(7,1003,'Denied',0,'2024-01-05'),

-- Dan (PARTIAL RECOVERY)
(8,1004,'Submitted',500,'2024-01-04'),
(9,1004,'Revised',1500,'2024-01-07'),
(10,1004,'Approved',1500,'2024-01-09'),

-- Eli (CLEAN)
(11,1005,'Submitted',500,'2024-01-05'),
(12,1005,'Approved',500,'2024-01-06'),

-- Fiona (MISSED REVENUE → NO REVISION)
(13,1006,'Submitted',600,'2024-01-06'),

-- George (REVISION CONFLICT)
(14,1007,'Submitted',1500,'2024-01-07'),
(15,1007,'Revised',1800,'2024-01-08'),
(16,1007,'Revised',1400,'2024-01-09'), -- lower final (conflict)
(17,1007,'Approved',1400,'2024-01-10'),

-- Hana (UNDERPAYMENT)
(18,1008,'Submitted',500,'2024-01-08'),
(19,1008,'Approved',500,'2024-01-09');

-- ============================================
-- PAYMENTS
-- ============================================
INSERT INTO payments_rcm VALUES
(1,1001,2500,'2024-01-07','Insurance'),
(2,1002,1500,'2024-01-04','Insurance'),
(3,1003,0,'2024-01-06','Insurance'),
(4,1004,1500,'2024-01-10','Insurance'),
(5,1005,500,'2024-01-06','Patient'),
(6,1007,1400,'2024-01-11','Insurance'),
(7,1008,300,'2024-01-10','Insurance'); -- UNDERPAID
