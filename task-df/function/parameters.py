if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--input_subscription', required=True,
        help='Input PubSub subscription of the form "/subscriptions/<PROJECT>/<SUBSCRIPTION>".')
    parser.add_argument(
        '--output_table', required=True,
        help='Output BigQuery table for data')
    parser.add_argument(
        '--output_error_table', required=True,
        help='Output BigQuery table for errors')
    parser.add_argument(
        '--project', required=True,
        help='Project Id')
    parser.add_argument(
        '--region', required=False, default="US",
        help='Region')
    parser.add_argument(
        '--job_name', required=False, default="dataflow-job-task-three",
        help='Dataflow Job name')
    parser.add_argument(
        '--template_location', required=True,
        help='Template location')
    parser.add_argument(
        '--staging_location', required=True,
        help='Staging location')
    parser.add_argument(
        '--temp_location', required=True,
        help='Temporary location')
    parser.add_argument(
        '--runner', required=False, default="DataflowRunner",
        help='DF runner')
    parser.add_argument(
        '--setup_file', required=False, default="task_two/setup.py",
        help='Setup file path')
    parser.add_argument(
        '--autoscaling_algorithm', required=False, default=None,
        help='Autoscaling algorithm')

    args = parser.parse_args()
    pipeline_options = {
        'project': args.project,
        'runner': args.runner,
        'region': args.region,
        'staging_location': args.staging_location,
        'temp_location': args.temp_location,
        'template_location': args.template_location,
        'save_main_session': True,
        'streaming': True,
        'job_name': args.job_name,
    }
    pipeline_options = PipelineOptions.from_dictionary(pipeline_options)
    run(
        options=pipeline_options,
        input_subscription=args.input_subscription,
        output_table=args.output_table,
        output_error_table=args.output_error_table,
    )
    
    
# print("####")
# known_args, pipeline_args = parser.parse_known_args()
# pipeline_options = PipelineOptions(pipeline_args)
# pipeline_options.view_as(SetupOptions).save_main_session = True
# print("###", pipeline_options.__dict__)
# pipeline_options = {
#     "project": "task-cf-370710",
#     "runner": "DataflowRunner",
#     "region": "US",
#     "staging_location": "gs://task-cf-370710-dataflow-bucket/tmp",
#     "temp_location": "gs://task-cf-370710-dataflow-bucket/tmp",
#     "template_location": "gs://task-cf-370710-dataflow-bucket/template/dataflow-job",
#     "save_main_session": True,
#     "streaming": True,
#     "job_name": "dataflow-pipeline",
# }

# input_subscription="projects/task-cf-370710/subscriptions/cf-pub_sub-subscription",
#         output_table="task-cf-370710:task_df_dataset.table-dataflow",
#         output_error_table="task-cf-370710:task_df_dataset.table-dataflow-error",

# python3 -m main --input_subscription "projects/task-cf-370710/subscriptions/cf-pub_sub-subscription" --output_table "task-cf-370710.dataflow.dataflow-cf-raw" --output_error_table "task-cf-370710.dataflow.dataflow-cf-error-raw" --streaming