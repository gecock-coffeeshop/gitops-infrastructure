NAMESPACE=$1

kubectl delete -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/crds/Grafana.yaml
kubectl delete -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/crds/GrafanaDashboard.yaml
kubectl delete -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/crds/GrafanaDataSource.yaml
kubectl delete -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/cluster_roles/cluster_role_binding_grafana_operator.yaml
kubectl delete -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/cluster_roles/cluster_role_grafana_operator.yaml
kubectl delete -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/roles/role.yaml -n $NAMESPACE
kubectl delete -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/roles/role_binding.yaml -n $NAMESPACE
kubectl delete -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/roles/service_account.yaml -n $NAMESPACE
kubectl delete -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/operator.yaml -n $NAMESPACE