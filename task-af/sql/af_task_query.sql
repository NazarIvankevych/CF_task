WITH
multiple AS (
    SELECT
        *,
        age*number,
        timestamp
    FROM
        `{{ params.AF_TASK_INPUT_TABLE }}` 
    WHERE
        output_table.timestamp > DATE_ADD(CURRENT_TIMESTAMP(), INTERVAL -1 HOUR)
)
SELECT * FROM multiple 
