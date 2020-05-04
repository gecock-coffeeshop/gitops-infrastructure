# Coffee Shop GitOps Infrastructure Repository

## Apply with Kustomize

Apply the operator components. Depending on your cluster, you will need to apply different operators.  
* ICPA OpenShift cluster:  
`kubectl apply -k operators-icpa/overlays`  
* Empty OpenShift cluster:  
`kubectl apply -k operatos-openshift/overlays`

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

## Uninstalling the infrastructure

* `kubectl delete -k monitoring/overlays`
* Delete the operators. You will need to delete different operators depending on your cluster:
  * ICPA OpenShift cluster:  
  `kubectl delete -k operators-icpa/overlays`  
  * Empty OpenShift cluster:  
  `kubectl delete -k operators-openshift/overlays`  
* Delete the remaining CSVs. As we are using global subscription, some CSVs may remain in your cluster.
  * After you identify them, you can use the following command to remove them, replacing `<csv>` with the one you want to remove:  
  `kubectl delete csv -n openshift-operators <csv>`
  * Or indiscriminately delete all CSVs with the following command:  
  `kubectl delete csv -n openshift-operators --all`
