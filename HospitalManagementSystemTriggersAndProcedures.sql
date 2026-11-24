-- HOSPITAL MANAGEMENT SYSTEM
-- Michael, Noah, Juan, Wenbo
-- Combined Sections 4.1, 4.2, and 4.3

-- CLEANUP (drop tables in reverse dependency order)
BEGIN
  FOR t IN (
    SELECT table_name
    FROM user_tables
    WHERE table_name IN (
      'HOSPITAL_ASSIGNMENT_APPOINTMENT_AUDIT',
      'HOSPITAL_ASSIGNMENT_BILLING',
      'HOSPITAL_ASSIGNMENT_MEDICAL_RECORDS',
      'HOSPITAL_ASSIGNMENT_TREATMENTS',
      'HOSPITAL_ASSIGNMENT_DIAGNOSES',
      'HOSPITAL_ASSIGNMENT_APPOINTMENTS',
      'HOSPITAL_ASSIGNMENT_DOCTORS',
      'HOSPITAL_ASSIGNMENT_APPOINTMENT_STATUS',
      'HOSPITAL_ASSIGNMENT_PATIENTS',
      'HOSPITAL_ASSIGNMENT_DEPARTMENTS'
    )
  ) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
  END LOOP;
END;
/

-- SEQUENCE CLEANUP
BEGIN
  FOR s IN (
    SELECT sequence_name
    FROM user_sequences
    WHERE sequence_name IN (
      'SEQ_HA_DEPARTMENT_ID',
      'SEQ_HA_PATIENT_ID',
      'SEQ_HA_DOCTOR_ID',
      'SEQ_HA_STATUS_ID',
      'SEQ_HA_APPOINTMENT_ID',
      'SEQ_HA_DIAGNOSIS_ID',
      'SEQ_HA_TREATMENT_ID',
      'SEQ_HA_RECORD_ID',
      'SEQ_HA_BILL_ID',
      'SEQ_HA_AUDIT_ID'
    )
  ) LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
  END LOOP;
END;
/

-- HOSPITAL MANAGEMENT SYSTEM
-- Michael, Noah, Juan, Wenbo

-- 1. DEPARTMENTS
CREATE TABLE HOSPITAL_ASSIGNMENT_DEPARTMENTS (
    Department_ID NUMBER PRIMARY KEY,
    Department_Name VARCHAR2(100) NOT NULL UNIQUE,
    Department_Location VARCHAR2(100) NOT NULL
);

-- 2. PATIENTS
CREATE TABLE HOSPITAL_ASSIGNMENT_PATIENTS (
    Patient_ID NUMBER PRIMARY KEY,
    First_Name VARCHAR2(50) NOT NULL,
    Last_Name VARCHAR2(50) NOT NULL,
    Phone_Number VARCHAR2(20) NOT NULL,
    Email VARCHAR2(100) UNIQUE,
    Address VARCHAR2(200) NOT NULL,
    Date_Of_Birth DATE NOT NULL,
    Gender VARCHAR2(20) NOT NULL,
    Weight NUMBER(5,2),
    Height NUMBER(5,2),
    Blood_Type VARCHAR2(3),
    Allergies VARCHAR2(500),

    CONSTRAINT chk_ha_patient_gender
        CHECK (Gender IN ('Male', 'Female', 'Other')),

    CONSTRAINT chk_ha_patient_weight
        CHECK (Weight > 0),

    CONSTRAINT chk_ha_patient_height
        CHECK (Height > 0),

    CONSTRAINT chk_ha_patient_blood
        CHECK (Blood_Type IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'))
);

-- 3. DOCTORS
CREATE TABLE HOSPITAL_ASSIGNMENT_DOCTORS (
    Doctor_ID NUMBER PRIMARY KEY,
    Department_ID NUMBER NOT NULL,
    First_Name VARCHAR2(50) NOT NULL,
    Last_Name VARCHAR2(50) NOT NULL,
    Phone_Number VARCHAR2(20) NOT NULL,
    Email VARCHAR2(100) NOT NULL UNIQUE,
    Doctor_Type VARCHAR2(100) NOT NULL,
    Shift VARCHAR2(30) NOT NULL,
    Payroll NUMBER(10,2) NOT NULL,

    CONSTRAINT fk_ha_doctor_department
        FOREIGN KEY (Department_ID)
        REFERENCES HOSPITAL_ASSIGNMENT_DEPARTMENTS(Department_ID),

    CONSTRAINT chk_ha_doctor_shift
        CHECK (Shift IN ('Morning', 'Afternoon', 'Night')),

    CONSTRAINT chk_ha_doctor_payroll
        CHECK (Payroll > 0)
);

-- 4. APPOINTMENT STATUS
CREATE TABLE HOSPITAL_ASSIGNMENT_APPOINTMENT_STATUS (
    Status_ID NUMBER PRIMARY KEY,
    Status_Name VARCHAR2(30) NOT NULL UNIQUE,
    Description VARCHAR2(200)
);

-- 5. APPOINTMENTS
CREATE TABLE HOSPITAL_ASSIGNMENT_APPOINTMENTS (
    Appointment_ID NUMBER PRIMARY KEY,
    Patient_ID NUMBER NOT NULL,
    Doctor_ID NUMBER NOT NULL,
    Department_ID NUMBER NOT NULL,
    Status_ID NUMBER NOT NULL,
    Appointment_Date DATE NOT NULL,
    Notes VARCHAR2(500),

    CONSTRAINT fk_ha_appointment_patient
        FOREIGN KEY (Patient_ID)
        REFERENCES HOSPITAL_ASSIGNMENT_PATIENTS(Patient_ID),

    CONSTRAINT fk_ha_appointment_doctor
        FOREIGN KEY (Doctor_ID)
        REFERENCES HOSPITAL_ASSIGNMENT_DOCTORS(Doctor_ID),

    CONSTRAINT fk_ha_appointment_department
        FOREIGN KEY (Department_ID)
        REFERENCES HOSPITAL_ASSIGNMENT_DEPARTMENTS(Department_ID),

    CONSTRAINT fk_ha_appointment_status
        FOREIGN KEY (Status_ID)
        REFERENCES HOSPITAL_ASSIGNMENT_APPOINTMENT_STATUS(Status_ID)
);

-- 6. DIAGNOSES
CREATE TABLE HOSPITAL_ASSIGNMENT_DIAGNOSES (
    Diagnosis_ID NUMBER PRIMARY KEY,
    Appointment_ID NUMBER NOT NULL,
    Diagnosis_Details VARCHAR2(500) NOT NULL,
    Diagnosis_Date DATE NOT NULL,

    CONSTRAINT fk_ha_diagnosis_appointment
        FOREIGN KEY (Appointment_ID)
        REFERENCES HOSPITAL_ASSIGNMENT_APPOINTMENTS(Appointment_ID)
);

-- 7. TREATMENTS
CREATE TABLE HOSPITAL_ASSIGNMENT_TREATMENTS (
    Treatment_ID NUMBER PRIMARY KEY,
    Diagnosis_ID NUMBER NOT NULL,
    Treatment_Name VARCHAR2(100) NOT NULL,
    Treatment_Description VARCHAR2(500) NOT NULL,
    Prescription VARCHAR2(500),
    Medicine VARCHAR2(100),
    Treatment_Cost NUMBER(10,2) NOT NULL,

    CONSTRAINT fk_ha_treatment_diagnosis
        FOREIGN KEY (Diagnosis_ID)
        REFERENCES HOSPITAL_ASSIGNMENT_DIAGNOSES(Diagnosis_ID),

    CONSTRAINT chk_ha_treatment_cost
        CHECK (Treatment_Cost >= 0)
);

-- 8. MEDICAL RECORDS
CREATE TABLE HOSPITAL_ASSIGNMENT_MEDICAL_RECORDS (
    Record_ID NUMBER PRIMARY KEY,
    Patient_ID NUMBER NOT NULL,
    Diagnosis_ID NUMBER,
    Treatment_ID NUMBER,
    Record_Date DATE NOT NULL,
    Record_Data VARCHAR2(1000) NOT NULL,
    Notes VARCHAR2(500),

    CONSTRAINT fk_ha_record_patient
        FOREIGN KEY (Patient_ID)
        REFERENCES HOSPITAL_ASSIGNMENT_PATIENTS(Patient_ID),

    CONSTRAINT fk_ha_record_diagnosis
        FOREIGN KEY (Diagnosis_ID)
        REFERENCES HOSPITAL_ASSIGNMENT_DIAGNOSES(Diagnosis_ID),

    CONSTRAINT fk_ha_record_treatment
        FOREIGN KEY (Treatment_ID)
        REFERENCES HOSPITAL_ASSIGNMENT_TREATMENTS(Treatment_ID)
);

-- 9. BILLING
CREATE TABLE HOSPITAL_ASSIGNMENT_BILLING (
    Bill_ID NUMBER PRIMARY KEY,
    Appointment_ID NUMBER NOT NULL,
    Bill_Date DATE NOT NULL,
    Receipt_ID VARCHAR2(50) UNIQUE,
    Payment_Amount NUMBER(10,2) NOT NULL,
    Payment_Status VARCHAR2(20) NOT NULL,
    Insurance_ID VARCHAR2(50),

    CONSTRAINT fk_ha_billing_appointment
        FOREIGN KEY (Appointment_ID)
        REFERENCES HOSPITAL_ASSIGNMENT_APPOINTMENTS(Appointment_ID),

    CONSTRAINT chk_ha_payment_amount
        CHECK (Payment_Amount >= 0),

    CONSTRAINT chk_ha_payment_status
        CHECK (Payment_Status IN ('Paid', 'Pending', 'Partial', 'Cancelled'))
);

-- 10. APPOINTMENT AUDIT
CREATE TABLE HOSPITAL_ASSIGNMENT_APPOINTMENT_AUDIT (
    Audit_ID NUMBER PRIMARY KEY,
    Appointment_ID NUMBER NOT NULL,
    Action_Type VARCHAR2(20) NOT NULL,
    Old_Status NUMBER,
    New_Status NUMBER,
    Change_Date TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    Changed_By VARCHAR2(100) NOT NULL,

    CONSTRAINT fk_ha_audit_appointment
        FOREIGN KEY (Appointment_ID)
        REFERENCES HOSPITAL_ASSIGNMENT_APPOINTMENTS(Appointment_ID),

    CONSTRAINT chk_ha_audit_action
        CHECK (Action_Type IN ('INSERT', 'UPDATE', 'DELETE'))
);


-- SEQUENCE CREATION
-- The full 4.1 dataset below uses IDs 1-5 or 1-10.
-- These sequences begin after the inserted IDs to avoid duplicate primary keys.
CREATE SEQUENCE seq_ha_department_id START WITH 6 INCREMENT BY 1 MAXVALUE 50 NOCYCLE NOCACHE;
CREATE SEQUENCE seq_ha_patient_id START WITH 11 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_ha_doctor_id START WITH 1010 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_ha_status_id START WITH 6 INCREMENT BY 1 MAXVALUE 20 NOCYCLE NOCACHE;
CREATE SEQUENCE seq_ha_appointment_id START WITH 11 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_ha_diagnosis_id START WITH 11 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_ha_treatment_id START WITH 11 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_ha_record_id START WITH 11 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_ha_bill_id START WITH 11 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_ha_audit_id START WITH 2 INCREMENT BY 1 NOCACHE;

-- 4.3 INDEXES
CREATE INDEX idx_ha_patient_last_name
    ON HOSPITAL_ASSIGNMENT_PATIENTS (Last_Name);

CREATE INDEX idx_ha_appt_doctor_date
    ON HOSPITAL_ASSIGNMENT_APPOINTMENTS (Doctor_ID, Appointment_Date);

-- DEPARTMENTS

INSERT INTO HOSPITAL_ASSIGNMENT_DEPARTMENTS VALUES (1, 'Emergency', 'Floor 1');

INSERT INTO HOSPITAL_ASSIGNMENT_DEPARTMENTS VALUES (2, 'Cardiology', 'Floor 2');

INSERT INTO HOSPITAL_ASSIGNMENT_DEPARTMENTS VALUES (3, 'Neurology', 'Floor 3');

INSERT INTO HOSPITAL_ASSIGNMENT_DEPARTMENTS VALUES (4, 'Pediatrics', 'Floor 4');

INSERT INTO HOSPITAL_ASSIGNMENT_DEPARTMENTS VALUES (5, 'Radiology', 'Floor 5');

-- APPOINTMENT STATUS

INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENT_STATUS VALUES (1, 'Scheduled', 'Appointment is scheduled');

INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENT_STATUS VALUES (2, 'Completed', 'Appointment completed');

INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENT_STATUS VALUES (3, 'Cancelled', 'Appointment cancelled');

INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENT_STATUS VALUES (4, 'Pending', 'Awaiting confirmation');

INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENT_STATUS VALUES (5, 'Rescheduled', 'Moved to a new date');

-- PATIENTS

INSERT INTO HOSPITAL_ASSIGNMENT_PATIENTS VALUES ( 1, 'John', 'Smith', '4165551001', 'john.smith@email.com', '123 King Street', DATE '1988-04-12', 'Male', 82, 180, 'O+', 'Peanuts' );

INSERT INTO HOSPITAL_ASSIGNMENT_PATIENTS VALUES ( 2, 'Sarah', 'Johnson', '4165551002', 'sarah.johnson@email.com', '456 Queen Street', DATE '1992-08-15', 'Female', 65, 168, 'A+', 'None' );

INSERT INTO HOSPITAL_ASSIGNMENT_PATIENTS VALUES ( 3, 'Michael', 'Brown', '4165551003', 'michael.brown@email.com', '789 Dundas Street', DATE '1985-02-21', 'Male', 90, 185, 'B+', 'Penicillin' );

INSERT INTO HOSPITAL_ASSIGNMENT_PATIENTS VALUES ( 4, 'Emma', 'Davis', '4165551004', 'emma.davis@email.com', '321 Front Street', DATE '1990-07-09', 'Female', 72, 170, 'AB+', 'None' );

INSERT INTO HOSPITAL_ASSIGNMENT_PATIENTS VALUES ( 5, 'Daniel', 'Wilson', '4165551005', 'daniel.wilson@email.com', '654 Bay Street', DATE '1987-11-30', 'Male', 88, 182, 'O-', 'Shellfish' );

INSERT INTO HOSPITAL_ASSIGNMENT_PATIENTS VALUES ( 6, 'Olivia', 'Martin', '4165551006', 'olivia.martin@email.com', '987 College Street', DATE '1995-03-14', 'Female', 60, 165, 'A-', 'None' );

INSERT INTO HOSPITAL_ASSIGNMENT_PATIENTS VALUES ( 7, 'William', 'Lee', '4165551007', 'william.lee@email.com', '159 Bloor Street', DATE '1983-09-22', 'Male', 95, 188, 'B-', 'Latex' );

INSERT INTO HOSPITAL_ASSIGNMENT_PATIENTS VALUES ( 8, 'Ava', 'Thompson', '4165551008', 'ava.thompson@email.com', '753 Yonge Street', DATE '2000-05-28', 'Female', 55, 162, 'O+', 'None' );

INSERT INTO HOSPITAL_ASSIGNMENT_PATIENTS VALUES ( 9, 'Noah', 'Garcia', '4165551009', 'noah.garcia@email.com', '852 Finch Avenue', DATE '1998-12-10', 'Male', 78, 177, 'A+', 'Peanuts' );

INSERT INTO HOSPITAL_ASSIGNMENT_PATIENTS VALUES ( 10, 'Sophia', 'White', '4165551010', 'sophia.white@email.com', '951 Eglinton Avenue', DATE '1993-06-18', 'Female', 68, 169, 'AB-', 'Penicillin' );

-- DOCTORS

INSERT INTO HOSPITAL_ASSIGNMENT_DOCTORS VALUES ( 1, 1, 'William', 'Anderson', '4165552001', 'w.anderson@hospital.com', 'Emergency Physician', 'Morning', 120000 );

INSERT INTO HOSPITAL_ASSIGNMENT_DOCTORS VALUES ( 2, 2, 'Emma', 'Brown', '4165552002', 'e.brown@hospital.com', 'Cardiologist', 'Afternoon', 135000 );

INSERT INTO HOSPITAL_ASSIGNMENT_DOCTORS VALUES ( 3, 3, 'James', 'Wilson', '4165552003', 'j.wilson@hospital.com', 'Neurologist', 'Night', 140000 );

INSERT INTO HOSPITAL_ASSIGNMENT_DOCTORS VALUES ( 4, 4, 'Sophia', 'Taylor', '4165552004', 's.taylor@hospital.com', 'Pediatrician', 'Morning', 125000 );

INSERT INTO HOSPITAL_ASSIGNMENT_DOCTORS VALUES ( 5, 5, 'Daniel', 'Moore', '4165552005', 'd.moore@hospital.com', 'Radiologist', 'Afternoon', 130000 );

INSERT INTO HOSPITAL_ASSIGNMENT_DOCTORS VALUES ( 6, 1, 'Olivia', 'Jackson', '4165552006', 'o.jackson@hospital.com', 'Emergency Physician', 'Night', 122000 );

INSERT INTO HOSPITAL_ASSIGNMENT_DOCTORS VALUES ( 7, 2, 'Michael', 'White', '4165552007', 'm.white@hospital.com', 'Cardiologist', 'Morning', 138000 );

INSERT INTO HOSPITAL_ASSIGNMENT_DOCTORS VALUES ( 8, 3, 'Ava', 'Harris', '4165552008', 'a.harris@hospital.com', 'Neurologist', 'Afternoon', 142000 );

INSERT INTO HOSPITAL_ASSIGNMENT_DOCTORS VALUES ( 9, 4, 'Noah', 'Martin', '4165552009', 'n.martin@hospital.com', 'Pediatrician', 'Night', 126000 );

INSERT INTO HOSPITAL_ASSIGNMENT_DOCTORS VALUES ( 10, 5, 'Charlotte', 'Clark', '4165552010', 'c.clark@hospital.com', 'Radiologist', 'Morning', 129000 );

-- APPOINTMENTS

INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENTS VALUES ( 1, 1, 1, 1, 1, DATE '2026-11-15', 'Routine checkup' );

INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENTS VALUES ( 2, 2, 2, 2, 2, DATE '2026-11-16', 'Cardiology consultation' );

INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENTS VALUES ( 3, 3, 3, 3, 1, DATE '2026-11-17', 'Neurological assessment' );

INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENTS VALUES ( 4, 4, 4, 4, 2, DATE '2026-11-18', 'Pediatric follow-up' );

INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENTS VALUES ( 5, 5, 5, 5, 1, DATE '2026-11-19', 'Radiology imaging' );

INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENTS VALUES ( 6, 6, 6, 1, 4, DATE '2026-11-20', 'Emergency visit' );

INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENTS VALUES ( 7, 7, 7, 2, 1, DATE '2026-11-21', 'Heart examination' );

INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENTS VALUES ( 8, 8, 8, 3, 5, DATE '2026-11-22', 'Brain scan review' );

INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENTS VALUES ( 9, 9, 9, 4, 1, DATE '2026-11-23', 'Child wellness check' );

INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENTS VALUES ( 10, 10, 10, 5, 2, DATE '2026-11-24', 'Diagnostic imaging follow-up' );

-- DIAGNOSES

INSERT INTO HOSPITAL_ASSIGNMENT_DIAGNOSES VALUES ( 1, 1, 'Routine health assessment completed', DATE '2026-11-15' );

INSERT INTO HOSPITAL_ASSIGNMENT_DIAGNOSES VALUES ( 2, 2, 'Mild hypertension detected', DATE '2026-11-16' );

INSERT INTO HOSPITAL_ASSIGNMENT_DIAGNOSES VALUES ( 3, 3, 'Migraine symptoms identified', DATE '2026-11-17' );

INSERT INTO HOSPITAL_ASSIGNMENT_DIAGNOSES VALUES ( 4, 4, 'Childhood asthma follow-up', DATE '2026-11-18' );

INSERT INTO HOSPITAL_ASSIGNMENT_DIAGNOSES VALUES ( 5, 5, 'X-ray review completed', DATE '2026-11-19' );

INSERT INTO HOSPITAL_ASSIGNMENT_DIAGNOSES VALUES ( 6, 6, 'Minor injury treated', DATE '2026-11-20' );

INSERT INTO HOSPITAL_ASSIGNMENT_DIAGNOSES VALUES ( 7, 7, 'Irregular heartbeat observed', DATE '2026-11-21' );

INSERT INTO HOSPITAL_ASSIGNMENT_DIAGNOSES VALUES ( 8, 8, 'Neurological evaluation normal', DATE '2026-11-22' );

INSERT INTO HOSPITAL_ASSIGNMENT_DIAGNOSES VALUES ( 9, 9, 'Routine pediatric examination', DATE '2026-11-23' );

INSERT INTO HOSPITAL_ASSIGNMENT_DIAGNOSES VALUES ( 10, 10, 'Diagnostic imaging reviewed', DATE '2026-11-24' );

-- TREATMENTS

INSERT INTO HOSPITAL_ASSIGNMENT_TREATMENTS VALUES ( 1, 1, 'General Checkup', 'Routine annual examination', 'No prescription required', 'None', 0 );

INSERT INTO HOSPITAL_ASSIGNMENT_TREATMENTS VALUES ( 2, 2, 'Blood Pressure Management', 'Monitor blood pressure daily', 'Take medication once daily', 'Lisinopril', 150 );

INSERT INTO HOSPITAL_ASSIGNMENT_TREATMENTS VALUES ( 3, 3, 'Migraine Treatment', 'Reduce migraine frequency', 'Use as needed', 'Sumatriptan', 120 );

INSERT INTO HOSPITAL_ASSIGNMENT_TREATMENTS VALUES ( 4, 4, 'Asthma Care', 'Continue inhaler treatment', 'Twice daily', 'Ventolin', 90 );

INSERT INTO HOSPITAL_ASSIGNMENT_TREATMENTS VALUES ( 5, 5, 'Imaging Consultation', 'Review radiology results', 'None', 'None', 75 );

INSERT INTO HOSPITAL_ASSIGNMENT_TREATMENTS VALUES ( 6, 6, 'Injury Care', 'Treat minor injury', 'Pain relief as required', 'Ibuprofen', 50 );

INSERT INTO HOSPITAL_ASSIGNMENT_TREATMENTS VALUES ( 7, 7, 'Cardiac Monitoring', 'Monitor heart rhythm', 'Daily medication', 'Metoprolol', 200 );

INSERT INTO HOSPITAL_ASSIGNMENT_TREATMENTS VALUES ( 8, 8, 'Neurological Follow-up', 'Schedule follow-up examination', 'None', 'None', 100 );

INSERT INTO HOSPITAL_ASSIGNMENT_TREATMENTS VALUES ( 9, 9, 'Pediatric Wellness', 'Routine wellness care', 'None', 'None', 80 );

INSERT INTO HOSPITAL_ASSIGNMENT_TREATMENTS VALUES ( 10, 10, 'Radiology Review', 'Review imaging findings', 'None', 'None', 95 );


-- MEDICAL RECORDS

INSERT INTO HOSPITAL_ASSIGNMENT_MEDICAL_RECORDS VALUES ( 1, 1, 1, 1, DATE '2026-11-15', 'Routine checkup completed successfully', 'Patient in good health' );

INSERT INTO HOSPITAL_ASSIGNMENT_MEDICAL_RECORDS VALUES ( 2, 2, 2, 2, DATE '2026-11-16', 'Blood pressure assessment recorded', 'Follow-up recommended' );

INSERT INTO HOSPITAL_ASSIGNMENT_MEDICAL_RECORDS VALUES ( 3, 3, 3, 3, DATE '2026-11-17', 'Migraine evaluation documented', 'Monitor symptoms' );

INSERT INTO HOSPITAL_ASSIGNMENT_MEDICAL_RECORDS VALUES ( 4, 4, 4, 4, DATE '2026-11-18', 'Asthma follow-up completed', 'Continue treatment' );

INSERT INTO HOSPITAL_ASSIGNMENT_MEDICAL_RECORDS VALUES ( 5, 5, 5, 5, DATE '2026-11-19', 'Radiology review documented', 'No abnormalities noted' );

INSERT INTO HOSPITAL_ASSIGNMENT_MEDICAL_RECORDS VALUES ( 6, 6, 6, 6, DATE '2026-11-20', 'Minor injury treatment recorded', 'Healing normally' );

INSERT INTO HOSPITAL_ASSIGNMENT_MEDICAL_RECORDS VALUES ( 7, 7, 7, 7, DATE '2026-11-21', 'Cardiac monitoring initiated', 'Observe patient regularly' );

INSERT INTO HOSPITAL_ASSIGNMENT_MEDICAL_RECORDS VALUES ( 8, 8, 8, 8, DATE '2026-11-22', 'Neurological assessment completed', 'No concerns identified' );

INSERT INTO HOSPITAL_ASSIGNMENT_MEDICAL_RECORDS VALUES ( 9, 9, 9, 9, DATE '2026-11-23', 'Pediatric wellness visit recorded', 'Patient healthy' );

INSERT INTO HOSPITAL_ASSIGNMENT_MEDICAL_RECORDS VALUES ( 10, 10, 10, 10, DATE '2026-11-24', 'Imaging review documented', 'Follow-up as needed' );

-- BILLING

INSERT INTO HOSPITAL_ASSIGNMENT_BILLING VALUES (1, 1, DATE '2026-11-15', 'R1001', 250, 'Paid', 'INS1001');

INSERT INTO HOSPITAL_ASSIGNMENT_BILLING VALUES (2, 2, DATE '2026-11-16', 'R1002', 300, 'Paid', 'INS1002');

INSERT INTO HOSPITAL_ASSIGNMENT_BILLING VALUES (3, 3, DATE '2026-11-17', 'R1003', 275, 'Pending', 'INS1003');

INSERT INTO HOSPITAL_ASSIGNMENT_BILLING VALUES (4, 4, DATE '2026-11-18', 'R1004', 200, 'Paid', 'INS1004');

INSERT INTO HOSPITAL_ASSIGNMENT_BILLING VALUES (5, 5, DATE '2026-11-19', 'R1005', 350, 'Partial', 'INS1005');

INSERT INTO HOSPITAL_ASSIGNMENT_BILLING VALUES (6, 6, DATE '2026-11-20', 'R1006', 150, 'Paid', 'INS1006');

INSERT INTO HOSPITAL_ASSIGNMENT_BILLING VALUES (7, 7, DATE '2026-11-21', 'R1007', 450, 'Pending', 'INS1007');

INSERT INTO HOSPITAL_ASSIGNMENT_BILLING VALUES (8, 8, DATE '2026-11-22', 'R1008', 320, 'Paid', 'INS1008');

INSERT INTO HOSPITAL_ASSIGNMENT_BILLING VALUES (9, 9, DATE '2026-11-23', 'R1009', 180, 'Paid', 'INS1009');

INSERT INTO HOSPITAL_ASSIGNMENT_BILLING VALUES (10, 10, DATE '2026-11-24', 'R1010', 400, 'Partial', 'INS1010');


-- APPOINTMENT AUDIT SAMPLE
INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENT_AUDIT VALUES (1, 1, 'INSERT', NULL, 1, SYSTIMESTAMP, USER);


-- 4.4 Triggers: MICHAEL

-- REMOVE AUDIT TABLE FOREIGN KEY
ALTER TABLE HOSPITAL_ASSIGNMENT_APPOINTMENT_AUDIT DROP CONSTRAINT fk_ha_audit_appointment;

-- AUDIT/LOGGING TRIGGER
CREATE OR REPLACE TRIGGER trg_ha_appointment_audit AFTER INSERT OR UPDATE OR DELETE ON HOSPITAL_ASSIGNMENT_APPOINTMENTS FOR EACH ROW BEGIN IF INSERTING THEN INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENT_AUDIT (Audit_ID, Appointment_ID, Action_Type, Old_Status, New_Status, Change_Date, Changed_By) VALUES (seq_ha_audit_id.NEXTVAL, :NEW.Appointment_ID, 'INSERT', NULL, :NEW.Status_ID, SYSTIMESTAMP, USER); ELSIF UPDATING THEN INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENT_AUDIT (Audit_ID, Appointment_ID, Action_Type, Old_Status, New_Status, Change_Date, Changed_By) VALUES (seq_ha_audit_id.NEXTVAL, :NEW.Appointment_ID, 'UPDATE', :OLD.Status_ID, :NEW.Status_ID, SYSTIMESTAMP, USER); ELSIF DELETING THEN INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENT_AUDIT (Audit_ID, Appointment_ID, Action_Type, Old_Status, New_Status, Change_Date, Changed_By) VALUES (seq_ha_audit_id.NEXTVAL, :OLD.Appointment_ID, 'DELETE', :OLD.Status_ID, NULL, SYSTIMESTAMP, USER); END IF; END;
/

-- BUSINESS-RULE TRIGGER: VALIDATE DOCTOR DEPARTMENT
CREATE OR REPLACE TRIGGER trg_ha_validate_doctor_department BEFORE INSERT OR UPDATE ON HOSPITAL_ASSIGNMENT_APPOINTMENTS FOR EACH ROW DECLARE v_doctor_department NUMBER; BEGIN SELECT Department_ID INTO v_doctor_department FROM HOSPITAL_ASSIGNMENT_DOCTORS WHERE Doctor_ID = :NEW.Doctor_ID; IF v_doctor_department <> :NEW.Department_ID THEN RAISE_APPLICATION_ERROR(-20011, 'Appointment department must match the selected doctor department.'); END IF; EXCEPTION WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20012, 'The selected doctor does not exist.'); END;
/

-- TEST AUDIT TRIGGER
BEGIN INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENTS VALUES (9001, 1, 1, 1, 1, DATE '2026-11-25', 'Trigger audit test'); UPDATE HOSPITAL_ASSIGNMENT_APPOINTMENTS SET Status_ID = 2 WHERE Appointment_ID = 9001; DELETE FROM HOSPITAL_ASSIGNMENT_APPOINTMENTS WHERE Appointment_ID = 9001; COMMIT; END;
/

-- VIEW AUDIT RESULTS
SELECT * FROM HOSPITAL_ASSIGNMENT_APPOINTMENT_AUDIT WHERE Appointment_ID = 9001 ORDER BY Audit_ID;

-- this will raise an error but it enforces the business rule

INSERT INTO HOSPITAL_ASSIGNMENT_APPOINTMENTS VALUES (9002, 1, 2, 1, 1, DATE '2026-11-26', 'Invalid department test');

-- Error will occur because the doctor 2 belongs to department 2 but this assigns appointment to department 1

-- Error will occur if the doctor id does not exist in the doctors table

-- VERIFY TRIGGERS
SELECT TRIGGER_NAME, STATUS FROM USER_TRIGGERS WHERE TRIGGER_NAME IN ('TRG_HA_APPOINTMENT_AUDIT', 'TRG_HA_VALIDATE_DOCTOR_DEPARTMENT');




-- 4.5 Procedures: Noah

SET SERVEROUTPUT ON;

-- PROCEDURE 1: DISPLAY ALL APPOINTMENTS FOR A DOCTOR USING AN EXPLICIT CURSOR
CREATE OR REPLACE PROCEDURE pr_ha_doctor_appointments (p_doctor_id IN NUMBER)
IS
    CURSOR c_appointments IS
        SELECT a.Appointment_ID, p.First_Name || ' ' || p.Last_Name AS Patient_Name, a.Appointment_Date, s.Status_Name
        FROM HOSPITAL_ASSIGNMENT_APPOINTMENTS a
        JOIN HOSPITAL_ASSIGNMENT_PATIENTS p ON a.Patient_ID = p.Patient_ID
        JOIN HOSPITAL_ASSIGNMENT_APPOINTMENT_STATUS s ON a.Status_ID = s.Status_ID
        WHERE a.Doctor_ID = p_doctor_id;

    v_doctor_id NUMBER;
    v_appointment_id NUMBER;
    v_patient_name VARCHAR2(100);
    v_appointment_date DATE;
    v_status_name VARCHAR2(30);

BEGIN
    SELECT Doctor_ID INTO v_doctor_id
    FROM HOSPITAL_ASSIGNMENT_DOCTORS
    WHERE Doctor_ID = p_doctor_id;

    OPEN c_appointments;

    LOOP
        FETCH c_appointments INTO v_appointment_id, v_patient_name, v_appointment_date, v_status_name;
        EXIT WHEN c_appointments%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Appointment ID: ' || v_appointment_id);
        DBMS_OUTPUT.PUT_LINE('Patient Name: ' || v_patient_name);
        DBMS_OUTPUT.PUT_LINE('Appointment Date: ' || v_appointment_date);
        DBMS_OUTPUT.PUT_LINE('Status: ' || v_status_name);
        DBMS_OUTPUT.PUT_LINE('-----------------------------');
    END LOOP;

    CLOSE c_appointments;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Doctor ID does not exist.');
    WHEN INVALID_CURSOR THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid cursor operation.');
END;
/

-- PROCEDURE 2: UPDATE APPOINTMENT STATUS WITH VALIDATION
CREATE OR REPLACE PROCEDURE pr_ha_update_appointment_status (p_appointment_id IN NUMBER, p_status_id IN NUMBER)
IS
    v_appointment_count NUMBER;
    v_status_count NUMBER;
    v_current_status NUMBER;

    e_appointment_not_found EXCEPTION;
    e_status_not_found EXCEPTION;
    e_same_status EXCEPTION;

BEGIN
    SELECT COUNT(*) INTO v_appointment_count
    FROM HOSPITAL_ASSIGNMENT_APPOINTMENTS
    WHERE Appointment_ID = p_appointment_id;

    IF v_appointment_count = 0 THEN
        RAISE e_appointment_not_found;
    END IF;

    SELECT COUNT(*) INTO v_status_count
    FROM HOSPITAL_ASSIGNMENT_APPOINTMENT_STATUS
    WHERE Status_ID = p_status_id;

    IF v_status_count = 0 THEN
        RAISE e_status_not_found;
    END IF;

    SELECT Status_ID INTO v_current_status
    FROM HOSPITAL_ASSIGNMENT_APPOINTMENTS
    WHERE Appointment_ID = p_appointment_id;

    IF v_current_status = p_status_id THEN
        RAISE e_same_status;
    END IF;

    UPDATE HOSPITAL_ASSIGNMENT_APPOINTMENTS
    SET Status_ID = p_status_id
    WHERE Appointment_ID = p_appointment_id;

    DBMS_OUTPUT.PUT_LINE('Appointment ' || p_appointment_id || ' status successfully updated to ' || p_status_id || '.');

EXCEPTION
    WHEN e_appointment_not_found THEN
        RAISE_APPLICATION_ERROR(-20003, 'Appointment ID does not exist.');
    WHEN e_status_not_found THEN
        RAISE_APPLICATION_ERROR(-20004, 'Selected status does not exist.');
    WHEN e_same_status THEN
        RAISE_APPLICATION_ERROR(-20005, 'Appointment already has this status.');
END;
/

-- TEST PROCEDURE 1: VALID DOCTOR ID
EXEC pr_ha_doctor_appointments(1);

-- TEST PROCEDURE 1: INVALID DOCTOR ID (EXPECTED ERROR: ORA-20001)
EXEC pr_ha_doctor_appointments(9999);

-- TEST PROCEDURE 2: VALID APPOINTMENT AND STATUS (EXPECTED SUCCESS IF CURRENT STATUS IS NOT 2)
EXEC pr_ha_update_appointment_status(1, 2);

-- TEST PROCEDURE 2: INVALID APPOINTMENT ID (EXPECTED ERROR: ORA-20003)
EXEC pr_ha_update_appointment_status(9999, 2);

-- TEST PROCEDURE 2: INVALID STATUS ID (EXPECTED ERROR: ORA-20004)
EXEC pr_ha_update_appointment_status(1, 9999);

-- TEST PROCEDURE 2: SAME STATUS (EXPECTED ERROR: ORA-20005)
EXEC pr_ha_update_appointment_status(1, 2);

COMMIT;