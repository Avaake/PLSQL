create or replace PACKAGE utill AS
    
    PROCEDURE add_employee (p_first_name     IN VARCHAR2,
                            p_last_name      IN VARCHAR2,
                            p_email          IN VARCHAR2,
                            p_phone_number   IN VARCHAR2,
                            p_hire_date      IN DATE DEFAULT TRUNC(SYSDATE, 'dd'),
                            p_job_id         IN VARCHAR2,
                            p_salary         IN NUMBER,
                            p_commission_pct IN VARCHAR2 DEFAULT NULL,
                            p_manager_id     IN NUMBER DEFAULT 100,
                            p_department_id  IN NUMBER);
    
    PROCEDURE fire_an_employee (p_employee_id IN NUMBER);
    
END utill;

create or replace PACKAGE BODY utill AS
    
    --PROCEDURE add_emp_history
    PROCEDURE add_emp_history (p_first_name IN VARCHAR2,
                               p_last_name  IN VARCHAR2, 
                               p_job_id     IN VARCHAR2, 
                               p_dep_id     IN NUMBER) IS
    BEGIN
        log_util.log_start(p_proc_name => 'add_emp_history');
        
        BEGIN 
            INSERT INTO employees_history (first_name, last_name, job_id, department_id)
            VALUES (p_first_name, p_last_name, p_job_id, p_dep_id);
            --COMMIT;
        
            DBMS_OUTPUT.PUT_LINE('Співробітник ' || p_first_name || ',' || p_last_name ||', КОД ПОСАДИ: ' || p_job_id ||', ІД ДЕПАРТАМЕНТУ: ' || p_dep_id ||' дадано в таблицю employees_history');
        EXCEPTION
            WHEN OTHERS THEN
                log_util.log_error(p_proc_name => 'add_employee', p_sqlerrm => TO_CHAR(SQLERRM));
                RAISE;
        END;
         
        log_util.log_finish(p_proc_name => 'add_emp_history');

    END add_emp_history;
    
    --PROCEDURE add_employee
    PROCEDURE add_employee (p_first_name     IN VARCHAR2,
                            p_last_name      IN VARCHAR2,
                            p_email          IN VARCHAR2,
                            p_phone_number   IN VARCHAR2,
                            p_hire_date      IN DATE DEFAULT TRUNC(SYSDATE, 'dd'),
                            p_job_id         IN VARCHAR2,
                            p_salary         IN NUMBER,
                            p_commission_pct IN VARCHAR2 DEFAULT NULL,
                            p_manager_id     IN NUMBER DEFAULT 100,
                            p_department_id  IN NUMBER)IS
        v_job_count NUMBER;
        v_dep_count NUMBER;
        v_min_salary jobs.min_salary%TYPE;
        v_max_salary jobs.max_salary%TYPE;
        v_employee_id employees.employee_id%TYPE;
        v_error_message VARCHAR2(255);
    
    BEGIN
    
        log_util.log_start(p_proc_name => 'add_employee');
        --перевірка існування job_id
        SELECT count(*)
        INTO v_job_count
        FROM JOBS j
        WHERE j.job_id = p_job_id;
    
        IF v_job_count = 0 THEN
            v_error_message := 'Введено неіснуючий код посади';
            RAISE_APPLICATION_ERROR (-20001, v_error_message);
        END IF;
        --перевірка існування department_id
        SELECT count(*)
        INTO v_dep_count
        FROM departments dep
        WHERE DEP.department_id = p_department_id;
    
        IF v_dep_count = 0 THEN
            v_error_message := 'Введено неіснуючий ідентифікатор відділу';
            RAISE_APPLICATION_ERROR (-20001, v_error_message);
        END IF;
    
        --перевірка ЗП
        SELECT j.min_salary, j.max_salary
        INTO v_min_salary, v_max_salary
        FROM jobs j 
        WHERE j.job_id = p_job_id;
    
        IF p_salary < v_min_salary OR p_salary > v_max_salary THEN
            v_error_message := 'Введено неприпустиму заробітну плату для даного коду посади';
            RAISE_APPLICATION_ERROR (-20001, v_error_message);
        END IF;
    
         --перевірка дати
         IF TO_CHAR(p_hire_date, 'DY') IN ('SAT','SUN')OR (TO_CHAR(p_hire_date, 'HH24:MI') >= '18:01' AND TO_CHAR(p_hire_date, 'HH24:MI') < '07:59') THEN
            v_error_message := 'Ви можете додавати нового співробітника лише в робочий час';
            RAISE_APPLICATION_ERROR (-20001, v_error_message);
         END IF;
    
         SELECT MAX(employee_id) + 1
         INTO v_employee_id
         FROM employees;
    
         BEGIN
    
            INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id) 
            VALUES (v_employee_id, p_first_name, p_last_name,p_email,p_phone_number, p_hire_date, p_job_id, p_salary, p_commission_pct, p_manager_id, p_department_id);
    
            --COMMIT;
            DBMS_OUTPUT.PUT_LINE('Співробітник ' || p_first_name || ',' || p_last_name ||', КОД ПОСАДИ: ' || p_job_id ||', ІД ДЕПАРТАМЕНТУ: ' || p_department_id ||' успішно додано до системи');
         EXCEPTION
            WHEN OTHERS THEN
                v_error_message := TO_CHAR(SQLERRM);
                log_util.log_error(p_proc_name => 'add_employee', p_sqlerrm => v_error_message);
                RAISE;
         END;
         log_util.log_finish(p_proc_name => 'add_employee');
    
    END add_employee;
    
    --PROCEDURE fire_an_employee
    PROCEDURE fire_an_employee (p_employee_id IN NUMBER) IS
    
        v_count_emp NUMBER;
        v_first_name employees.first_name%TYPE;
        v_last_name employees.last_name%TYPE;
        v_job_id employees.job_id%TYPE;
        v_dep_id employees.department_id%TYPE;
    BEGIN
    
        log_util.log_start(p_proc_name => 'fire_an_employee');
    
        SELECT COUNT(employee_id)
        INTO v_count_emp
        FROM employees
        WHERE employee_id = p_employee_id;
        --перевірка співробітника
        IF v_count_emp = 0 THEN
            RAISE_APPLICATION_ERROR (-20001,'Переданий співробітник не існує ');
        END IF;
        --перевірка дати
        IF TO_CHAR(SYSDATE, 'DY') IN ('SAT','SUN')OR (TO_CHAR(SYSDATE, 'HH24:MI') >= '18:01' AND TO_CHAR(SYSDATE, 'HH24:MI') < '07:59') THEN
            RAISE_APPLICATION_ERROR (-20001, 'Ви можете додавати нового співробітника лише в робочий час');
        END IF;
    
        BEGIN
            --значенння для DBMS_OUTPUT.PUT_LINE
            SELECT em.first_name, em.last_name, em.job_id, em.department_id 
            INTO v_first_name, v_last_name, v_job_id, v_dep_id
            FROM employees em 
            WHERE employee_id = p_employee_id;
    
            DELETE FROM employees WHERE employee_id = p_employee_id;       
    
            DBMS_OUTPUT.PUT_LINE('Співробітник ' || v_first_name || ',' || v_last_name ||' звільнений , КОД ПОСАДИ: ' || v_job_id ||', ІД ДЕПАРТАМЕНТУ: ' || v_dep_id);
            --виклик PROCEDURE add_emp_history
            add_emp_history (p_first_name => v_first_name,
                             p_last_name  => v_last_name, 
                             p_job_id     => v_job_id, 
                             p_dep_id     => v_dep_id);
            --COMMIT;
            
        EXCEPTION
            WHEN OTHERS THEN
                log_util.log_error(p_proc_name => 'fire_an_employee', p_sqlerrm => TO_CHAR(SQLERRM));
                RAISE;
        END;
    
    
        log_util.log_finish(p_proc_name => 'fire_an_employee');
    
    END fire_an_employee;

    
    
END utill;