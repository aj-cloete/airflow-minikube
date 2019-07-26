# airflow-minikube
Airflow natively on minikube (services and executors)

## Quick deploy
- Step 1: Make a copy of *values.template.yaml* file in the *airflow* folder and edit it to the desired state.  Save this file within the *airflow* folder as *values.yaml*.  This configures your airflow deploy. 
  - `cp ./airflow/values.template.yaml ./airflow/values.yaml`
  - `nano ./airflow/values.yaml`
  While the default settings will work, you should really look into the configuration you need and customize the deployment.
- Step 2: 
Run `./scripts/deploy-airflow-minikube.sh`

### Notes:
If you don't yet have virtualbox installed, you may need to run the script again after restarting your machine in order for virtualbox to apply the necessary settings.  
Docker.app should open during execution of the script and allow you to sign in (optional) but if you are having a hard time getting the `deploy` script to run properly, you may need to manually launch the docker application.  Also keep an eye on the output from the script and follow the recommendations from `apt` or `brew`.  Especially as it pertains to creating symlinks and/or adding binaries to PATH.
