# Coffee Shop GitOps Infrastructure Repository

## Apply with Kustomize

Apply the operator components.
* `kubectl apply -k operators/overlays`

Once the operators have finished deploying, you can apply the monitoring components.
* `kubectl apply -k monitoring/overlays`

## Monitoring

After applying the contents of this repository, you can view the dashboard as follows:

* On OpenShift go to 'Networking -> Routes' and select the `coffeeshop-monitoring` project.
* There should be a `grafana-route`. Select the link to the dashboard location.
* You should now see the 'Home Dashboard'.
* On the top left of the screen, select the dashboard dropdown where it currently displays 'Home' and select `Kafka-Dashboard` to navigate to the coffeeshop scenario one.
