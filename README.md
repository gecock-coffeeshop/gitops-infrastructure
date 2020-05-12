# Coffee Shop GitOps Infrastructure Repository

## Apply with Kustomize

Apply the operator components. Depending on your cluster, you will need to apply different operators.  
* ICPA OpenShift cluster:  
`kubectl apply -k operators-icpa`  
* Empty OpenShift cluster:  
`kubectl apply -k operators-openshift`

You can check the status of the operators using the following command.
* `oc get csv -n coffeeshop-monitoring`

Once the operators have finished deploying, you can apply the monitoring components.
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
* Delete the remaining CSVs. As we are using global subscription, some CSVs may remain in your cluster. You will need to delete the source CSV present in the openshift-operators namespace which will remove the other CSVs in the other namespaces as well.
  * In the case where you may have other operators outside this projects installation, identify any exisiting subscriptions. You will want to remove the CSVs where there is no subscription:  
  `kubectl get subscription -n openshift-operators`
  * Identity the remaining CSVs:  
  `kubectl get csv -n openshift-operators`  
  * Remove the CSVs with no present subscription, replacing `<csv>` with the one you want to remove:  
  `kubectl delete csv -n openshift-operators <csv>`
  * Or indiscriminately delete all CSVs with the following command:  
  `kubectl delete csv -n openshift-operators --all`

# Testing Monitoring Tech Preview
<!-- TODO: Test using OperaturHub one instead of own deployment (6.5.1) -->
<!-- TODO: Deploy from Github rather than cloned copy -->
1. Deploy
   * `kubectl apply -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/crds/Grafana.yaml`
   * `kubectl apply -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/crds/GrafanaDashboard.yaml`
   * `kubectl apply -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/crds/GrafanaDataSource.yaml`
   * `kubectl apply -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/cluster_roles/cluster_role_binding_grafana_operator.yaml`
   * `kubectl apply -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/cluster_roles/cluster_role_grafana_operator.yaml`
   * `kubectl apply -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/roles/role.yaml -n coffeeshop-monitoring`
   * `kubectl apply -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/roles/role_binding.yaml -n coffeeshop-monitoring`
   * `kubectl apply -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/roles/service_account.yaml -n coffeeshop-monitoring`
   * `kubectl apply -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/operator.yaml -n coffeeshop-monitoring`
   * `kubectl patch deployment grafana-operator -n coffeeshop-monitoring --patch "$(cat operator-patch.yaml)"`
   * `kubectl patch clusterrolebinding grafana-operator --patch "$(cat clusterrolebinding-patch.yaml)"`
1. Get Token <!-- Try using specific permissions and convert steps into yaml -->
   * `oc -n coffeeshop-monitoring create sa prometheus-reader`
   * `oc -n coffeeshop-monitoring adm policy add-cluster-role-to-user view -z prometheus-reader`
   * `oc -n  coffeeshop-monitoring serviceaccounts get-token prometheus-reader`
1. Update GrafanaDataSource with token from above.
1. `kubectl apply -k monitoring`
1. When finished testing, delete grafana as following:
   * `kubectl delete -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/crds/Grafana.yaml`
   * `kubectl delete -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/crds/GrafanaDashboard.yaml`
   * `kubectl delete -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/crds/GrafanaDataSource.yaml`
   * `kubectl delete -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/cluster_roles/cluster_role_binding_grafana_operator.yaml`
   * `kubectl delete -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/cluster_roles/cluster_role_grafana_operator.yaml`
   * `kubectl delete -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/roles/role.yaml -n coffeeshop-monitoring`
   * `kubectl delete -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/roles/role_binding.yaml -n coffeeshop-monitoring`
   * `kubectl delete -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/roles/service_account.yaml -n coffeeshop-monitoring`
   * `kubectl delete -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/operator.yaml -n coffeeshop-monitoring`
