WITH
airflow_math AS (
    SELECT
        output_table.age,
        output_table.number,
        output_table.timestamp,
        output_table.age*output_table.number as multiple
    FROM
        `{{ params.AF_TASK_INPUT_TABLE }}` output_table
    WHERE
        output_table.timestamp > DATETIME_ADD(CURRENT_TIMESTAMP(), INTERVAL -1 HOUR)
)
SELECT * FROM airflow_math

-- SELECT *, age*number as multiple FROM `{{ params.AF_TASK_INPUT_TABLE }}`