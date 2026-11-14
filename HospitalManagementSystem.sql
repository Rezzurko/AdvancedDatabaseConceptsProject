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