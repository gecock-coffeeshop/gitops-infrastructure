# OpenShift User Workload Monitoring

OpenShift offers an out of the box solution to monitor your application. At time of writing, this feature is in tech preview so there may be some changes in future.

This guide will explain how monitoring is set up for the coffeeshop application. 

The components are spread out across multiple repositories:

* **gitops-infrastructure**  
    Installs Grafana and enables the user workload monitoring on OpenShift.
* **gitops-dev**  
    Contains the Grafana dashboards and the relevant deploy files for the microservices, e.g. `app-deploy.yaml` and ServiceMonitors for monitoring.
* **The microservices themselves, e.g. coffeeshop-ui**  
    Enables the monitoring for the microservices if necessary and contains the necessary deploy files.

## Pre-requisites

* OpenShift 4.4 cluster
* Assumption that you are using the coffeeshop scenarion and have a `coffeeshop-monitoring` and `coffeeshop` namespace similar to the coffeeshop scenario.

## Setup Application Monitoring

This setup will focus on the coffeeshop-ui service but the steps will generally be similar across the other microservices, i.e. turn on monitoring, handle any relevant configuration and create a ServiceMonitor.

### Coffeeshop-UI Repository

1. Turn on monitoring in the coffeeshop-ui service:
    * In `src/main/liberty/config/server.xml`, add the following to the `featureManager` tag:
        ```xml
        <feature>mpMetrics-2.2</feature>
        <feature>monitor-1.0</feature>
        ```
1. Configure OpenLiberty security. We use quick-start security with the password in plaintext. This configuration is only used for demonstration purposes and is not suitable for production use. Add the following to `src/main/liberty/config/server.xml` inside the `<server>` tags:
    ```xml
    <quickStartSecurity userName="admin" userPassword="password" />
    ```
1. Create a Secret which contains the credentials from above so that Prometheus can scrape the metrics:
    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: metrics-liberty
      type: Opaque
      namespace: coffeeshop
    stringData:
      password: password
      username: admin
    ```
1. Update the `app-deploy.yaml` to turn on monitoring. Appsody will then create a ServiceMonitor resource for you with the necessary configuration:
    ```yaml
    spec:
      monitoring:
        endpoints:
          - basicAuth:
              password:
                key: password
                name: metrics-liberty
              username:
                key: username
                name: metrics-liberty
            interval: 10s
            tlsConfig:
              insecureSkipVerify: true
        labels:
          app.kubernetes.io/instance: coffeeshop-ui
    ```
    **basicAuth**  
    This property references the previously created secret file to retrieve the username and password.  
    **labels**  
    These are any labels you want to add to your ServiceMonitor.

### Gitops-Dev Repository

For monitoring the microservices, not much needs to be done in this repository as the relevant files will get merged into the services respective config folders as part of the CI/CD pipeline.

Confirm that the config directory for the service reflects the config within the services repository and has the updated `app-deploy.yaml` as well.

If you want to visualise your metrics on Grafana with premade dashboards, then you can add the yaml for them in this repository. There is currently no example of a GrafanaDashboard for one of the microservices.

Although this guide looks at monitoring your microservices, you can add any relevant ServiceMonitor or GrafanaDashboards within this repository for other components such as your applications Kafka.

### Gitops-Infrastructure Repository

Now that you have setup the service itself for monitoring, you will need to configure your cluster.

1. Enable tech preview in your cluster to be able to monitor your services using OpenShift's Prometheus:
    * Create or update your configmap as following to enable tech preview:
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: cluster-monitoring-config
      namespace: openshift-monitoring
    data:
      config.yaml: |
        techPreviewUserWorkload:
          enabled: true
    ```
1. Install the Grafana Operator and the CRDs into your cluster:
    * The steps to install Grafana are listed in their <a href="https://github.com/integr8ly/grafana-operator/blob/master/documentation/deploy_grafana.md#manual-procedure">repository</a> or take a look at the <a href="../install-grafana.sh">install-grafana.sh</a> which deploys and patches all the required resources.
    * If you install Grafana manually from their repository as described in their documentation, you will need to patch the `grafana-operator` deployment to be able to watch all namespaces to find the relevant service's dashboards. You can use `kubectl` as shown in the install script mentioned above. Alternatively, if you cloned the Grafana repository, you will need to add the following argument in the container:
        ```yaml
        args:
          - '--scan-all'
        ```
    * The ClusterRoleBinding in the Grafana repository also links the ClusterRole to a ServiceAccount in the `Grafana` namespace, you will need to patch this to point to the namespace you deployed to if necessary.
1. Setup Grafana
    ```yaml
    apiVersion: integreatly.org/v1alpha1
    kind: Grafana
    metadata:
      name: Grafana
      namespace: coffeeshop-monitoring
    spec:
      ingress:
        enabled: true
      config:
        security:
          admin_user: "root"
          admin_password: "secret"
        auth:
          disable_login_form: False
          disable_signout_menu: True
        auth.anonymous:
          enabled: False
    dashboardLabelSelector:
      - matchExpressions:
        - key: app
          operator: In
          values:
            - Grafana
    ```
    **security**  
    This section contains the admin username and password. When you login with these credentials, Grafana will prompt you to change your password.  
    **dashboardLabelSelector**  
    The selector will find the dashboards based on the criteria across all namespaces. The argument that we updated earlier inside the container of the Grafana-operator deployment enables searching across all namespaces.
1. Before we continue adding the GrafanaDataSource, we will need a ServiceAccount for Grafana to use to authenticate against the user Workload Prometheus:
    ```yaml
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: prometheus-reader
      namespace: coffeeshop-monitoring
    ```
    I have found several guides online that mention giving view permission for all the resources within the cluster to this ServiceAccount but I have found this was not necessary, at least for the current stage of the coffeeshop application. This may change as the application and monitoring requirements evolve.
1. Now that we have a ServiceAccount for Grafana to authenticate with Prometheus, we can add a GrafanaDataSource:
    * Retrieve the token from the ServiceAccount that we created earlier. You can navigate to the ServiceAccount in the OpenShift Console, or use the following command to get it:  
    `oc -n coffeeshop-monitoring serviceaccounts get-token prometheus-reader`
    * Create the GrafanaDataSource and replace `[TOKEN]` with the one we got in the previous step.
    ```yaml
    apiVersion: integreatly.org/v1alpha1
    kind: GrafanaDataSource
    metadata:
      name: Grafana-datasource
      namespace: coffeeshop-monitoring
    spec:
      name: Grafana-datasources.yaml
      datasources:
        - name: Prometheus
          type: prometheus
          url: 'https://prometheus-operated.openshift-user-workload-monitoring.svc.cluster.local:9091/'
          access: proxy
          basicAuth: false
          withCredentials: false
          isDefault: true
          editable: true
          jsonData:
            httpHeaderName1: "Authorization"
            tlsSkipVerify: true
          secureJsonData:
            httpHeaderValue1: "Bearer [TOKEN]"
    ```
    **url**  
    This is the local cluster url to the User Workload Prometheus service.  
    **httpHeaderName1**  
    This custom header will be attached to the request that Grafana makes to Prometheus.  
    **httpHeaderValue1**  
    The value for the custom header will be added here. `secureJsonData` will ensure that the data will be encrypted.
1. After deploying everything, test that your data source works correctly.
    * On OpenShift, navigate to the `coffeeshop-monitoring` project and on the left-hand side, under Administrator, select Networking -> Routes.
    * Select the url for the grafana-route.
    * Enter the admin credentials as set in the Grafana resource. At this point, you may change the password to better protect your Grafana.
    * On the left-hand side on the Grafana page, select Configuration -> Prometheus Data Source.
    * Select the Save & Test button and Grafana will test the connection and let you know if it was successful.
1. Now you can freely add dashboards and query your service.
