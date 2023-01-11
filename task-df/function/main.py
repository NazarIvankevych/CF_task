import apache_beam as beam
import argparse
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions
from datetime import datetime
import json
import logging
import datetime
import time

logging.basicConfig(level=logging.INFO)

SCHEMA = ",".join(
    [
        "name:STRING",
        "age:INTEGER",
        "height:FLOAT64",
        "timestamp:TIMESTAMP",
    ]
)

ERROR_SCHEMA = ",".join(
    [
        "msg:STRING",
        "timestamp:TIMESTAMP",
    ]
)


class Parser(beam.DoFn):
    ERROR_TAG = "error"

    def process(self, line):
        try:
            row = json.loads(line.decode("utf-8"))

            logging.info(f"MESSAGE, {row}")
            yield {
                "message": row["message"],
                "number_int": int(row["number_int"]),
                "number_float": float(row["number_float"]),
                "timestamp": row["timestamp"],
            }
        except Exception as error:
            logging.info("ERROR")
            now = datetime.datetime.utcnow()
            ts = now.strftime("%Y-%m-%d %H:%M:%S")
            error_row = {"msg": str(error), "timestamp": ts}
            time.sleep(1)
            yield beam.pvalue.TaggedOutput(self.ERROR_TAG, error_row)


def run(options, input_subscription, output_table, output_error_table):
    with beam.Pipeline(options=options) as pipeline:
        rows, error_rows = (
            pipeline
            | "Read from PubSub"
            >> beam.io.ReadFromPubSub(subscription=input_subscription)
            | "Parse JSON messages"
            >> beam.ParDo(Parser()).with_outputs(Parser.ERROR_TAG, main="rows")
        )

        _ = rows | "Write data to BigQuery" >> beam.io.WriteToBigQuery(
            output_table,
            create_disposition=beam.io.BigQueryDisposition.CREATE_NEVER,
            write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
            schema=SCHEMA,
        )

        _ = error_rows | "Write errors to BigQuery" >> beam.io.WriteToBigQuery(
            output_error_table,
            create_disposition=beam.io.BigQueryDisposition.CREATE_NEVER,
            write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
            schema=ERROR_SCHEMA,
        )


if "__main__" == __name__:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input_subscription",
        required=True,
        default="projects/task-cf-370710/subscriptions/cf-pub_sub-subscription",
        help='Input PubSub subscription of the form "/subscriptions/task-cf-370710/cf-pub_sub-subscription".',
    )
    parser.add_argument(
        "--output_table",
        required=True,
        default="../schemas/dataflow-cf-raw.json",
        help="Output BigQuery table for data",
    )
    parser.add_argument(
        "--output_error_table",
        required=True,
        default="../schemas/dataflow-cf-error-raw.json",
        help="Output BigQuery table for errors",
    )
    print("####")
    known_args, pipeline_args = parser.parse_known_args()
    pipeline_options = PipelineOptions(pipeline_args)
    pipeline_options.view_as(SetupOptions).save_main_session = True
    print("###", pipeline_options.__dict__)
    pipeline_options = {
        "project": "task-cf-370710",
        "runner": "DataflowRunner",
        "region": "US",
        "staging_location": "gs://task-cf-370710-dataflow-bucket/tmp",
        "temp_location": "gs://task-cf-370710-dataflow-bucket/tmp",
        "template_location": "gs://task-cf-370710-dataflow-bucket/template/dataflow-job",
        "save_main_session": True,
        "streaming": True,
        "job_name": "dataflow-pipeline",
    }
    pipeline_options = PipelineOptions.from_dictionary(pipeline_options)
    run(
        options=pipeline_options,
        
        input_subscription="projects/task-cf-370710/subscriptions/cf-pub_sub-subscription",
        output_table="task-cf-370710:task_df_dataset.table-df-table-dataflow",
        output_error_table="task-cf-370710:task_df_dataset.table-df-table-dataflow-error",
    )

# python3 -m main --input_subscription "projects/task-cf-370710/subscriptions/cf-pub_sub-subscription" --output_table "task-cf-370710.dataflow.dataflow-cf-raw" --output_error_table "task-cf-370710.dataflow.dataflow-cf-error-raw" --streaming
