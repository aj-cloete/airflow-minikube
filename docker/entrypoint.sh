#!/usr/bin/env bash

TRY_LOOP="20"

: "${POSTGRES_HOST:="postgres"}"
: "${POSTGRES_PORT:="5432"}"
: "${POSTGRES_USER:="airflow"}"
: "${POSTGRES_PASSWORD:="airflow"}"
: "${POSTGRES_DB:="airflow"}"

# Defaults and back-compat
: "${AIRFLOW__CORE__FERNET_KEY:=${FERNET_KEY:=$(python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)")}}"
: "${AIRFLOW__CORE__EXECUTOR:=${EXECUTOR:-Sequential}Executor}"

export \
  AIRFLOW__CORE__EXECUTOR \
  AIRFLOW__CORE__FERNET_KEY \
  AIRFLOW__CORE__LOAD_EXAMPLES \
  AIRFLOW__CORE__SQL_ALCHEMY_CONN \


# Load DAGs exemples (default: Yes)
if [[ -z "$AIRFLOW__CORE__LOAD_EXAMPLES" && "${LOAD_EX:=n}" == n ]]
then
  AIRFLOW__CORE__LOAD_EXAMPLES=False
fi

wait_for_port() {
  local name="$1" host="$2" port="$3"
  local j=0
  while ! nc -z "$host" "$port" >/dev/null 2>&1 < /dev/null; do
    j=$((j+1))
    if [ $j -ge $TRY_LOOP ]; then
      echo >&2 "$(date) - $host:$port still not reachable, giving up"
      exit 1
    fi
    echo "$(date) - waiting for $name... $j/$TRY_LOOP"
    sleep 5
  done
}

if [ "$AIRFLOW__CORE__EXECUTOR" != "SequentialExecutor" ]; then
  AIRFLOW__CORE__SQL_ALCHEMY_CONN="postgresql+psycopg2://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB"
  wait_for_port "Postgres" "$POSTGRES_HOST" "$POSTGRES_PORT"
fi

if [ ! -z "$SQL_DESTINATION" ]; then
  echo "Pulling from repo cloned to ${SQL_DESTINATION}"
  cd $SQL_DESTINATION && git pull --depth 1 >/dev/null 2>/dev/null && cd $AIRFLOW_HOME
fi

if [ ! -z "$DAGS_DESTINATION" ]; then
  echo "Pulling from repo cloned to ${DAGS_DESTINATION}"
  cd $DAGS_DESTINATION && git pull --depth 1 >/dev/null 2>/dev/null && cd $AIRFLOW_HOME
fi

case "$1" in
  webserver)
    airflow initdb
    if [ "$AIRFLOW__CORE__EXECUTOR" = "LocalExecutor" ] || [ "$AIRFLOW__CORE__EXECUTOR" = "SequentialExecutor" ]; then
      # With the "Local" executor it should all run in one container.
      airflow scheduler &
    fi
    exec airflow webserver
    ;;
  scheduler)
    # To give the webserver time to run initdb.
    sleep 10
    exec airflow "$@"
    ;;
  version)
    exec airflow "$@"
    ;;
  *)
    # For other commands that is not airflow keyword commands
    exec "$@"
    ;;
esac
