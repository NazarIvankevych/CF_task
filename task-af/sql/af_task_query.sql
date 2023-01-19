WITH
multiple AS (
    SELECT
        *,
        number*age,
        output_table.timestamp
    FROM
        `{{ params.AF_TASK_INPUT_TABLE }}` output_table
    WHERE
        output_table.timestamp > DATE_ADD(CURRENT_TIMESTAMP(), INTERVAL -1 HOUR)
)
SELECT * FROM multiple
-- SELECT *, number*age as multiple FROM `{{ params.AF_TASK_INPUT_TABLE }}`
