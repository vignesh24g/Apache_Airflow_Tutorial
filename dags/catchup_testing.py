from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'retry_delay': timedelta(minutes=5),
    'retries':5,
}

with DAG(
    'catchup_testing',
    default_args=default_args,
    description='A simple DAG to test catchup behavior',
    schedule_interval='@daily',
    start_date=datetime(2026,7,3),
    catchup=True,
) as dag:

    task1 = BashOperator(
        task_id='print_date',
        bash_command='echo hii all',
    )

    task1