-- HOSPITAL MANAGEMENT SYSTEM
-- Michael, Noah, Juan, Wenbo

-- CLEANUP (drop in reverse dependency order)
BEGIN
  FOR t IN (SELECT table_name FROM user_tables
            WHERE table_name IN ('HOSPITAL_ASSIGNMENT_APPOINTMENT_AUDIT', 'HOSPITAL_ASSIGNMENT_BILLING','HOSPITAL_ASSIGNMENT_MEDICAL_RECORDS',
'HOSPITAL_ASSIGNMENT_TREATMENTS','HOSPITAL_ASSIGNMENT_DIAGNOSES','HOSPITAL_ASSIGNMENT_APPOINTMENTS','HOSPITAL_ASSIGNMENT_DOCTORS','HOSPITAL_ASSIGNMENT_APPOINTMENT_STATUS','HOSPITAL_ASSIGNMENT_PATIENTS','HOSPITAL_ASSIGNMENT_DEPARTMENTS'))
  LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
  END LOOP;
END;
/

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

-- SEQUENCES

-- SEQUENCE CLEANUP 
--BEGIN
--  FOR s IN (SELECT sequence_name FROM user_sequences
--            WHERE sequence_name IN ('SEQ_HA_PATIENT_ID',
--'SEQ_HA_DEPARTMENT_ID',
--'SEQ_HA_DOCTOR_ID',
--'SEQ_HA_STATUS_ID',
--'SEQ_HA_APPOINTMENT_ID',
--'SEQ_HA_DIAGNOSIS_ID',
--'SEQ_HA_TREATMENT_ID',
--'SEQ_HA_RECORD_ID',
--'SEQ_HA_BILL_ID',
--'SEQ_HA_AUDIT_ID'))
--  LOOP
--    EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
--  END LOOP;
--END;
--/

-- SEQUENCE CREATION
CREATE SEQUENCE seq_ha_department_id START WITH 1 INCREMENT BY 1 MAXVALUE 50 NOCYCLE NOCACHE;

CREATE SEQUENCE seq_ha_patient_id START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE SEQUENCE seq_ha_doctor_id START WITH 1000 INCREMENT BY 1 NOCACHE;

CREATE SEQUENCE seq_ha_status_id START WITH 1 INCREMENT BY 1 MAXVALUE 20 NOCYCLE NOCACHE;

CREATE SEQUENCE seq_ha_appointment_id START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE SEQUENCE seq_ha_diagnosis_id START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE SEQUENCE seq_ha_treatment_id START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE SEQUENCE seq_ha_record_id START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE SEQUENCE seq_ha_bill_id START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE SEQUENCE seq_ha_audit_id START WITH 1 INCREMENT BY 1 NOCACHE;

-- DATA INSERTION 
insert into HOSPITAL_ASSIGNMENT_DEPARTMENTS values(seq_ha_department_id.nextval, 'Emergency', 'Building C');

insert into hospital_assignment_patients values(seq_ha_patient_id.nextval, 'Jane','Doe','(777) 777-7777','example@email.com','10 First Street, Toronto, ON', '2000-01-01','Male',160,160,'A+','None');

insert into HOSPITAL_ASSIGNMENT_APPOINTMENT_STATUS values(seq_ha_status_id.nextval, 'Reserved', 'Fatigue');

insert into hospital_assignment_doctors values(seq_ha_doctor_id.nextval,1,'John','Smith','(777) 777-7777','doctor@hospital.com','General practitioner','Morning',100000);

insert into HOSPITAL_ASSIGNMENT_APPOINTMENTS values(seq_ha_appointment_id.nextval, 1, 1000, 1, 1, '2026-11-16', 'No notes');

insert into HOSPITAL_ASSIGNMENT_DIAGNOSES values(seq_ha_diagnosis_id.nextval, 1, 'Hypertension', '2026-11-17');
--select * from HOSPITAL_ASSIGNMENT_TREATMENTS;
--alter sequence seq_ha_treatment_id restart;
--truncate table HOSPITAL_ASSIGNMENT_TREATMENTS;
insert into HOSPITAL_ASSIGNMENT_TREATMENTS values(seq_ha_treatment_id.nextval, 1, 'Blood Pressure Management', 'Regular monitoring and management of blood pressure', 'Take medication once daily','Lisinopril',85.00);

insert into HOSPITAL_ASSIGNMENT_MEDICAL_RECORDS values(seq_ha_record_id.nextval, 1, 1, 1, '2026-11-17', 'Patient diagnosed with hypertension. Treatment initiated.', 'Follow-up required in 30 days.');

insert into hospital_assignment_billing values(seq_ha_bill_id.nextval, 1, '2026-11-17', 'REC-1001', 50.00, 'Pending', 'INS-100');

insert into HOSPITAL_ASSIGNMENT_APPOINTMENT_AUDIT values(seq_ha_audit_id.nextval,1, 'INSERT', NULL, 1, SYSTIMESTAMP, USER); --TO BE CHANGED

-- UPDATING AUDIT TABLE
select * from HOSPITAL_ASSIGNMENT_APPOINTMENT_AUDIT;
update HOSPITAL_ASSIGNMENT_APPOINTMENT_AUDIT set audit_id = seq_ha_audit_id.nextval where audit_id=1;   --TO BE CHANGED
select * from HOSPITAL_ASSIGNMENT_APPOINTMENT_AUDIT;