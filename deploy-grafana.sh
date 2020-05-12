NAMESPACE=$1

kubectl apply -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/crds/Grafana.yaml
kubectl apply -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/crds/GrafanaDashboard.yaml
kubectl apply -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/crds/GrafanaDataSource.yaml
kubectl apply -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/cluster_roles/cluster_role_binding_grafana_operator.yaml
kubectl apply -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/cluster_roles/cluster_role_grafana_operator.yaml
kubectl apply -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/roles/role.yaml -n $NAMESPACE
kubectl apply -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/roles/role_binding.yaml -n $NAMESPACE
kubectl apply -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/roles/service_account.yaml -n $NAMESPACE
kubectl apply -f https://raw.githubusercontent.com/integr8ly/grafana-operator/v3.3.0/deploy/operator.yaml -n $NAMESPACE
kubectl patch deployment grafana-operator --patch "{\"spec\": {\"template\": {\"spec\": {\"containers\": [{\"name\":\"grafana-operator\", \"args\": [\"--scan-all\"] }] }}}}" -n $NAMESPACE
kubectl patch clusterrolebinding grafana-operator --patch "{\"subjects\": [{ \"kind\":\"ServiceAccount\", \"name\":\"grafana-operator\", \"namespace\":\"$NAMESPACE\"}] }"