# Coffee Shop GitOps Infrastructure Repository

The repository will help you set up a cluster to run the Coffee Shop demo. Red Hat OpenShift 4.4 is required. Follow the instructions below once for each cluster on which you will deploy the applications.  

## Apply with Kustomize

1. Apply the operator components. 
   `oc apply -k operators`
1. Deploy the Grafana operator from the Grafana GitHub:
   * `./install-grafana.sh coffeeshop-monitoring`
1. You can check the status of the operators using the following command.
   * `oc get csv -n coffeeshop-monitoring`
1. Retrieve the service account token from the prometheus reader.
   * `oc -n coffeeshop-monitoring serviceaccounts get-token prometheus-reader`
1. Update the GrafanaDataSource in `monitoring\base\grafana\base\grafana.yaml` replacing both occurrences of `[TOKEN]` with the token from the previous step.
1. Once the operators have finished deploying, you can apply the monitoring components.
   * `oc apply -k monitoring`

## Monitoring

After applying the contents of this repository, and the [GitOps repository](https://github.com/ibm-icpa-coffeeshop/gitops-dev), you can view the dashboard as follows:

* On OpenShift go to 'Networking -> Routes' and select the `coffeeshop-monitoring` project.
* There should be a `grafana-route`. Select the link to the dashboard location.
* Log in using the username `root` and password `secret`. You can change the default value in `monitoring/base/grafana/base/grafana.yaml`. Once you login, Grafana will prompt you to change the password.
* You should now see the 'Home Dashboard'.
* On the top left of the screen, select the dashboard dropdown where it currently displays 'Home' and select `Kafka-Dashboard` to navigate it.

If you want to find more information on how monitoring is setup, there is a more in-depth guide in the docs: <a href="docs/openshift-user-workload-monitoring">OpenShift User Workload Monitoring</a>

## Uninstalling the infrastructure

* `oc delete -k monitoring`
* Delete the Grafana operator and its components using the Grafana GitHub yamls:
   * `./delete-grafana.sh coffeeshop-monitoring`
* Delete the operators.   
  `oc delete -k operators` 
* Delete the remaining CSVs. As we are using global subscription, some CSVs may remain in your cluster. You will need to delete the source CSV present in the openshift-operators namespace which will remove the other CSVs in the other namespaces as well.
  * In the case where you may have other operators outside this projects installation, identify any exisiting subscriptions. You will want to remove the CSVs where there is no subscription:  
  `oc get subscription -n openshift-operators`
  * Identity the remaining CSVs:  
  `oc get csv -n openshift-operators`  
  * Remove the CSVs with no present subscription, replacing `<csv>` with the one you want to remove:  
  `oc delete csv -n openshift-operators <csv>`
  * Or indiscriminately delete all CSVs with the following command:  
  `oc delete csv -n openshift-operators --all`
