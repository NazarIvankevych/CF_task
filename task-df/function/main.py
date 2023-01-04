import datetime
import json

import apache_beam as beam
import argparse
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions

SCHEMA = ",".join(
    [
        "field1:STRING",
        "field2:INTEGER",
        "field3:FLOAT64",
        "field4:TIMESTAMP",
    ]
)

ERROR_SCHEMA = ",".join(
    [
        "field1:STRING",
        "field2:TIMESTAMP",
    ]
)


class Parser(beam.DoFn):
    ERROR_TAG = 'error'

    def process(self, line):
        try:
            line = json.loads(line.decode("utf-8"))
            if not all(field in line for field in ["name", "age"]):
                raise
            line["timestamp"] = datetime.datetime.utcnow()

            yield line
        except Exception as error:
            err_record = {"msg": str(error), "timestamp": datetime.datetime.utcnow()}
            yield beam.pvalue.TaggedOutput(self.ERROR_TAG, err_record)


def run(options, input_subscription, output_table, output_error_table):

    with beam.Pipeline(options=options) as pipeline:
        rows, error_rows = \
            (pipeline | 'Read from PubSub' >> beam.io.ReadFromPubSub(subscription=input_subscription)
             | 'Parse JSON messages' >> beam.ParDo(Parser()).with_outputs(Parser.ERROR_TAG,
                                                                                main='rows')
             )

        _ = (rows | 'Write data to BigQuery'
             >> beam.io.WriteToBigQuery(output_table,
                                        create_disposition=beam.io.BigQueryDisposition.CREATE_NEVER,
                                        write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
                                        schema=SCHEMA
                                        )
             )

        _ = (error_rows | 'Write errors to BigQuery'
             >> beam.io.WriteToBigQuery(output_error_table,
                                        create_disposition=beam.io.BigQueryDisposition.CREATE_NEVER,
                                        write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
                                        schema=ERROR_SCHEMA
                                        )
             )


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--input_subscription', required=True,
        help='Input PubSub subscription of the form "/subscriptions/task-cf-370710/cf-pub_sub-subscription".')
    parser.add_argument(
        '--output_table', required=True,
        help='Output BigQuery table for data')
    parser.add_argument(
        '--output_error_table', required=True,
        help='Output BigQuery table for errors')
    print("####")
    known_args, pipeline_args = parser.parse_known_args()
    pipeline_options = PipelineOptions(pipeline_args)
    pipeline_options.view_as(SetupOptions).save_main_session = True
    print("###", pipeline_options.__dict__)
    pipeline_options = {
        'project': 'task-cf-370710',
        'runner': 'DataflowRunner',
        'region': 'US',
        'staging_location': 'gs://task-df/tmp',
        'temp_location': 'gs://task-df/tmp',
        'template_location': 'gs://task-df/template/dataflow-job',
        'save_main_session': True,
        'streaming': True,
        'job_name': 'dataflow-custom-pipeline-v1',
    }
    pipeline_options = PipelineOptions.from_dictionary(pipeline_options)
    run(pipeline_options, known_args.input_subscription, known_args.output_table, known_args.output_error_table)
