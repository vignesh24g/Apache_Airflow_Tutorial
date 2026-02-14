import pendulum
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from datetime import timedelta

# Timezone-aware start date
local_tz = pendulum.timezone("Asia/Kolkata")

# Default arguments applied to all tasks
default_args = {
    "owner": "vignesh",
    "depends_on_past": False,
    "email": ["alerts@example.com"],
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 3,                               # retry up to 3 times
    "retry_delay": timedelta(seconds=10),       # wait 10 seconds between retries
    "execution_timeout": timedelta(hours=1),    # max runtime per task
}

# Example ETL functions
def extract_data():
    print("Extracting data...")

def transform_data():
    print("Transforming data...")

def load_data():
    print("Loading data into target system...")

# DAG definition
with DAG(
    dag_id="etl_pipeline",
    description="ETL DAG using Pendulum and default_args",
    default_args=default_args,
    start_date=pendulum.datetime(2026, 2, 14, tz=local_tz),
    schedule_interval="0 9 * * *",   # runs daily at 9 AM IST
    catchup=False,
    tags=["etl", "tutorial", "default_args"],
) as dag:

    # Extract task (uses default retries)
    extract = PythonOperator(
        task_id="extract",
        python_callable=extract_data
    )

    # Transform task (overrides retry settings)
    transform = PythonOperator(
        task_id="transform",
        python_callable=transform_data,
        retries=5,                                # overrides default (3)
        retry_delay=timedelta(minutes=1),         # overrides default (10s)
    )

    # Load task (uses default retries)
    load = PythonOperator(
        task_id="load",
        python_callable=load_data
    )

    # Notify task (runs regardless of upstream success/failure)
    notify = BashOperator(
        task_id="notify",
        bash_command="echo 'ETL DAG finished (success or fail)'",
        trigger_rule="all_done"
    )

    # Dependencies
    extract >> transform >> load >> notify
