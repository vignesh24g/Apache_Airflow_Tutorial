**To install Apache Airflow on Ubuntu, you’ll need Python, a virtual environment, and pip. The safest method is to use a dedicated environment, install Airflow via pip with required extras, initialize the database, and start the webserver and scheduler.**

---

## 🔧 Step-by-Step Installation Guide (Ubuntu 20.04/22.04/24.04)

### 1. Update System Packages

```bash
sudo apt update && sudo apt upgrade -y

```

### 2. Install Python and pip

- Airflow requires **Python 3.8+**.

```bash
sudo apt install python3 python3-pip python3-venv -y

```

### 3. Create a Virtual Environment

It’s best to isolate Airflow from system Python.

```bash
python3 -m venv airflow_env
source airflow_env/bin/activate

```

### 4. Upgrade pip and setuptools

```bash
pip install --upgrade pip setuptools wheel

```

### 5. Install Apache Airflow

Airflow is distributed via PyPI. Choose the version compatible with your Python.

```bash
export AIRFLOW_VERSION=2.9.3
export PYTHON_VERSION="$(python --version | cut -d " " -f 2 | cut -d "." -f 1-2)"
export CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"

pip install "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"

```

- You can add extras like `postgres`, `mysql`, `celery`, or `redis`:

```bash
pip install "apache-airflow[postgres,celery]==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"

```

### 6. Initialize Airflow Database

Airflow uses a metadata database (default SQLite).

```bash
airflow db init

```

### 7. Create an Admin User

```bash
airflow users create \
    --username admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@example.com

```

### 8. Start Airflow Services

- **Webserver** (default port 8080):

```bash
airflow webserver --port 8080

```

- **Scheduler** (in a separate terminal):

```bash
airflow scheduler

```

### 9. Access the UI

Open your browser and go to:

**http://localhost:8080**

---

## ⚠️ Important Notes

- **System Requirements**: At least **4 GB RAM** recommended for smooth operation.
- **Database Choice**: SQLite is fine for testing, but for production use **PostgreSQL or MySQL**. [Apache Airflow](https://airflow.apache.org/docs/apache-airflow/stable/installation/index.html)
- **Security**: For production, configure Airflow behind **Nginx with SSL**.

---

✅ With these steps, you’ll have Airflow running locally on Ubuntu. Do you want me to also show you how to set it up with **PostgreSQL backend** (better for production) instead of SQLite?

Great question 👍. Once Apache Airflow is installed and initialized, you don’t need to repeat the whole installation process every time. For subsequent launches, you only need to start the **webserver** and the **scheduler** inside your Airflow environment.

---

## 🚀 Commands to Run Next Time

1. **Activate your virtual environment** (if you created one):

```bash
source airflow_env/bin/activate

```

1. **Start the Airflow webserver** (default port 8080):

```bash
airflow webserver --port 8080
#or
nohup airflow webserver --port 8080 > webserver.log 2>&1 &


```

1. **Start the Airflow scheduler** (in a separate terminal):

```bash
airflow scheduler

```

---

## 🔑 Notes

- Always run **both** the webserver and scheduler, otherwise DAGs won’t execute.
- If you want them to run in the background, you can use:

```bash
airflow webserver -D
airflow scheduler -D

```

(`-D` runs them as daemons).

- Then just open your browser at **http://localhost:8080** to access the UI.
- You don’t need to re-run `airflow db init` or recreate the user unless you reset the database.

---

👉 So next time, just **activate the environment** and run **webserver + scheduler**.
