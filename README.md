# Coffee Shop GitOps Monitoring Repository

## Setup

1. Prometheus Operator

   * `kubectl create ns coffeeshop-monitoring`
   * Navigate in the web console to the **Operators** → **OperatorHub** page.
   * Type **Prometheus** into the **Filter by keyword** box.
   * Select the Operator and click **Install**.
   * On the **Create Operator Subscription** page:
     * Select **A specific namespace on the cluster** and select the `coffeeshop-monitoring` namespace
     * Select **Automatic** or **Manual** approval strategy. If you choose Automatic, Operator Lifecycle Manager (OLM) automatically upgrades the operator as a new version is available.
     * Click **Subscribe**.
   * In the `prometheus/prometheus-config-secret.yaml` file you will need to replace the value of `prometheus-additional-config.yaml` with the base64 encoded contents of the file with the same name. Use the following command to encode the file contents to replace the above values with:
     * `cat prometheus/prometheus-additional-config.yaml | base64 -w 0 > base64.txt`
     * The base64 encoded contents can then be found in the `base64.txt` file.
   * `kubectl apply -f prometheus/prometheus-config-secret.yaml`
   * `kubectl apply -f prometheus/prometheus.yaml`
   * `kubectl apply -f prometheus/prometheus-clusterroles.yaml`

1. Grafana Operator (Optional)

   * Navigate in the web console to the **Operators** → **OperatorHub** page.
   * Type **Grafana** into the **Filter by keyword** box.
   * Select the Operator and click **Install**.
   * On the **Create Operator Subscription** page:
     * Select **A specific namespace on the cluster** and select the `coffeeshop-monitoring` namespace
     * Select **Automatic** or **Manual** approval strategy. If you choose Automatic, Operator Lifecycle Manager (OLM) automatically upgrades the operator as a new version is available.
   * Click **Subscribe**.
   * After the operator has installed, you will need to update it to watch for dashboards in other namespaces:
     * Select the Grafana Operator in the Installed Operators page and navigate to YAML.
     * In the container args found under the following path `spec.install.spec.deployments.spec.template.spec.containers.args`, add the `--scan-all` flag.
     * The `args` should now look similar to the following:
        ```yaml
        args:
            - '--grafana-image=quay.io/openshift/origin-grafana'
            - '--grafana-image-tag=4.2'
            - '--scan-all'
        ```
   * `kubectl apply -f grafana/grafana-clusterroles.yaml`
   * `kubectl apply -f grafana/grafana.yaml`
   * You can now view the dashboard.
     * On OpenShift go to 'Networking -> Routes' and select the `coffeeshop-monitoring` project.
     * There should be a `grafana-route`. Select the link to the dashboard location.
     * You should now see the 'Home Dashboard'.
     * On the top left of the screen, select the dashboard dropdown where it currently displays 'Home' and select `Coffeeshop-Kafka-Dashboard` to navigate to the coffeeshop scenario one.
