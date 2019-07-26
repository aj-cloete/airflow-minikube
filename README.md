# airflow-minikube
Airflow natively on minikube (services and executors)

## Quick deploy
Run `./scripts/deploy-airflow-minikube.sh`

### Notes:
If you don't yet have virtualbox installed, you may need to run the script again after restarting your machine in order for virtualbox to apply the necessary settings.  
Docker.app should open during execution of the script and allow you to sign in (optional) but if you are having a hard time getting the `deploy` script to run properly, you may need to manually launch the docker application.  Also keep an eye on the output from the script and follow the recommendations from `apt` or `brew`.  Especially as it pertains to creating symlinks and/or adding binaries to PATH.
