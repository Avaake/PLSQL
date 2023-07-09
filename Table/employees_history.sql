CREATE TABLE employees_history (
    employee_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR2(255), 
    last_name VARCHAR2(255),
    job_id VARCHAR2(255),
    department_id NUMBER,
    release_date DATE DEFAULT SYSDATE
);