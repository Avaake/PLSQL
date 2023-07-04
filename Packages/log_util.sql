create or replace PACKAGE log_util AS

    PROCEDURE log_start (p_proc_name IN VARCHAR2,
                         p_text      IN VARCHAR2 DEFAULT NULL);
    
    PROCEDURE log_finish (p_proc_name IN VARCHAR2,
                          P_text      IN VARCHAR2 DEFAULT NULL);
    
    PROCEDURE log_error (p_proc_name IN VARCHAR2,
                         p_sqlerrm   IN VARCHAR2,
                         p_text      IN VARCHAR2 DEFAULT NULL);

END log_util;