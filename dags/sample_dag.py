from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

# Define the DAG
with DAG(
    dag_id="sample_dag",
    start_date=datetime(2026, 2, 14),   # any past date
    schedule_interval="@daily",         # runs once per day
    catchup=False,                      # don’t backfill old runs
    tags=["example"],                   # helpful for grouping in UI
) as dag:

    # Task 1: print the date
    print_date = BashOperator(
        task_id="print_date",
        bash_command="date"
    )

    # Task 2: sleep for 5 seconds
    sleep_task = BashOperator(
        task_id="sleep_task",
        bash_command="sleep 5"
    )

    # Task 3: echo a message
    echo_task = BashOperator(
        task_id="echo_task",
        bash_command="echo 'Airflow DAG executed successfully!'"
    )

    # Define dependencies
    print_date >> sleep_task >> echo_task
