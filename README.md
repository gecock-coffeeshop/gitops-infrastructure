# Coffee Shop GitOps Monitoring Repository

## Kustomize

* `kubectl apply -k overlays`
* You can now view the dashboard.
     * On OpenShift go to 'Networking -> Routes' and select the `coffeeshop-monitoring` project.
     * There should be a `grafana-route`. Select the link to the dashboard location.
     * You should now see the 'Home Dashboard'.
     * On the top left of the screen, select the dashboard dropdown where it currently displays 'Home' and select `Kafka-Dashboard` to navigate to the coffeeshop scenario one.
