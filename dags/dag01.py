from airflow.decorators import dag, task
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from datetime import datetime

default_args = {
    "owner": "vignesh",
}

@dag(
    dag_id='dag01',
    default_args=default_args,
    description='A simple DAG with Bash and Python tasks'
)
#task flow should have an  func to initiate the dag, 
# and the tasks should be defined inside that function,
#  and the function should be called at the end of the file to
#  create the DAG object.

#in case classic operator is used, 
# the tasks can be defined outside the function and called diretly in the function, 
# but the function should be called at the end of the file to create the DAG object.
def dag01():

    def get_name(ti):
      print("My name is Vignesh")
      ti.xcom_push(key='quotes', value='try harder')
      return 'Haha'

    task1=PythonOperator(
        task_id='get_name',
        python_callable=get_name,
    )

    #normal return can be get from xcom_pull without key, 
    # but if you want to push multiple values, then you need to use key and value pair in xcom_push and xcom_pull
    @task()
    def print_date(ti):
        print("Current date is: ", datetime.now())
        name = ti.xcom_pull(task_ids='get_name')
        print("Name from get_name task: ", name)
    
    @task()
    def print_quotes(ti):
        quotes = ti.xcom_pull(task_ids='get_name', key='quotes')
        print("Quotes from get_name task: ", quotes)
    #functions should be called inside the dag function to create the tasks,
    #  and the tasks should be defined in the order of execution, 
    # and the dependencies should be defined using >> operator.
    dat=print_date()
    q=print_quotes()
    task1>>dat
    task1>>q

dag01()
