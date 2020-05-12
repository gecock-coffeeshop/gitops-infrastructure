# Coffee Shop GitOps Infrastructure Repository

## Apply with Kustomize

Apply the operator components.
* `kubectl apply -k operators/overlays`

You can check the status of the operators using the following command.
* `oc get clusterserviceversion -n coffeeshop-monitoring`

Once the operators have finished deploying, you can apply the monitoring components.
* `kubectl apply -k monitoring/overlays`

## Monitoring

After applying the contents of this repository, you can view the dashboard as follows:

* On OpenShift go to 'Networking -> Routes' and select the `coffeeshop-monitoring` project.
* There should be a `grafana-route`. Select the link to the dashboard location.
* You should now see the 'Home Dashboard'.
* On the top left of the screen, select the dashboard dropdown where it currently displays 'Home' and select `Kafka-Dashboard` to navigate to the coffeeshop scenario one.



# Testing Monitoring Tech Preview
<!-- TODO: Test using OperaturHub one instead of own deployment (6.5.1) -->
<!-- TODO: Deploy from Github rather than cloned copy -->
1. Using own, add scan-all flag to operator deployment and change namespace from default to coffeeshop-monitoring in clusterrole binding.
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
   * `kubectl patch clusterrolebinding grafana-operator --patch "$(cat clusterrole-patch.yaml)"`
1. Get Token <!-- Try using specific permissions and convert steps into yaml -->
   * `oc -n coffeeshop-monitoring create sa prometheus-reader`
   * `oc -n coffeeshop-monitoring adm policy add-cluster-role-to-user view -z prometheus-reader`
   * `oc -n  coffeeshop-monitoring serviceaccounts get-token prometheus-reader`
1. Update GrafanaDataSource with token from above.
1. `kubectl apply -k monitoring/overlays`
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