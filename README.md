# Coffee Shop GitOps Infrastructure Repository

## Apply with Kustomize

1. Apply the operator components. Depending on your cluster, you will need to apply different operators.  
   * ICPA OpenShift cluster:  
   `kubectl apply -k operators-icpa`  
   * Empty OpenShift cluster:  
   `kubectl apply -k operators-openshift`
1. Deploy the Grafana operator from the Grafana GitHub:
   * `./deploy-grafana.sh coffeeshop-monitoring`
1. You can check the status of the operators using the following command.
   * `oc get csv -n coffeeshop-monitoring`
1. Retrieve the service account token from the prometheus reader.
   * `oc -n  coffeeshop-monitoring serviceaccounts get-token prometheus-reader`
1. Update the GrafanaDataSource in `monitoring\base\grafana\base\grafana.yaml` with the token from the previous step.
1. Once the operators have finished deploying, you can apply the monitoring components.
   * `kubectl apply -k monitoring`

## Monitoring

After applying the contents of this repository, you can view the dashboard as follows:

* On OpenShift go to 'Networking -> Routes' and select the `coffeeshop-monitoring` project.
* There should be a `grafana-route`. Select the link to the dashboard location.
* You should now see the 'Home Dashboard'.
* On the top left of the screen, select the dashboard dropdown where it currently displays 'Home' and select `Kafka-Dashboard` to navigate to the coffeeshop scenario one.

## Uninstalling the infrastructure

* `kubectl delete -k monitoring`
* Delete the operators. You will need to delete different operators depending on your cluster:
  * ICPA OpenShift cluster:  
  `kubectl delete -k operators-icpa`  
  * Empty OpenShift cluster:  
  `kubectl delete -k operators-openshift` 
* Delete the Grafana operator and its components using the Grafana GitHub yamls:
   * `./delete-grafana.sh coffeeshop-monitoring`
* Delete the remaining CSVs. As we are using global subscription, some CSVs may remain in your cluster. You will need to delete the source CSV present in the openshift-operators namespace which will remove the other CSVs in the other namespaces as well.
  * In the case where you may have other operators outside this projects installation, identify any exisiting subscriptions. You will want to remove the CSVs where there is no subscription:  
  `kubectl get subscription -n openshift-operators`
  * Identity the remaining CSVs:  
  `kubectl get csv -n openshift-operators`  
  * Remove the CSVs with no present subscription, replacing `<csv>` with the one you want to remove:  
  `kubectl delete csv -n openshift-operators <csv>`
  * Or indiscriminately delete all CSVs with the following command:  
  `kubectl delete csv -n openshift-operators --all`
