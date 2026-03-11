FROM apache/airflow:3.0.2-python3.11

COPY ./dags/ /opt/airflow/dags/
COPY ./requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt