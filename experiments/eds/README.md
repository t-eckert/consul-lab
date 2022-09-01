# EDS Bugfix

Issue found by Iryna.

From Slack:

I think this a bug. I’ve deployed static-server and static client and when I 
read the proxy for the static-client, I don’t see the static-server cluster for 
its endpoint:

```
==> Endpoints (4)
Address:Port     	Cluster    	Weight	Status
127.0.0.1:19000  	self_admin 	1.00  	HEALTHY
172.18.0.2:8502  	local_agent	1.00  	HEALTHY
10.244.0.13:20000	           	1.00  	HEALTHY
127.0.0.1:0      	local_app  	1.00  	HEALTHY
```

the third endpoint should point to the static-server cluster but it’s empty in 
the Cluster column

Similarly, for the static-server cluster there’s no endpoint shown:

```
==> Clusters (5)
Name                	FQDN                                                                          	Endpoints      	Type        	Last Updated
local_agent         	local_agent                                                                   	172.18.0.2:8502	STATIC      	2022-07-25T16:35:49.173Z
self_admin          	self_admin                                                                    	127.0.0.1:19000	STATIC      	2022-07-25T16:35:49.186Z
local_app           	local_app                                                                     	127.0.0.1:0    	STATIC      	2022-07-25T16:35:49.270Z
original-destination	original-destination                                                          	               	ORIGINAL_DST	2022-07-25T16:35:49.214Z
static-server       	static-server.default.dc1.internal.406de4d4-5d46-c41c-314e-a3ca74108c8f.consul	               	EDS         	2022-07-25T16:35:49.256Z
```

the endpoint config does not have cluster name

I installed it with `consul-k8s install -preset demo`

``` yaml
---
apiVersion: v1
kind: Service
metadata:
  name: static-server
spec:
  selector:
    app: static-server
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: static-server
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: static-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: static-server
  template:
    metadata:
      name: static-server
      labels:
        app: static-server
      annotations:
        "consul.hashicorp.com/connect-inject": "true"
    spec:
      containers:
        - name: static-server
          env:
            - name: POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP
          image: ishustava/http-echo:latest
          command:
              - "/bin/sh"
              - "-ec"
              - |
                /http-echo -listen=:8080 -text="hello world $POD_IP"
          ports:
            - containerPort: 8080
              name: http
      terminationGracePeriodSeconds: 0
      serviceAccountName: static-server
```

``` yaml
apiVersion: v1
kind: Service
metadata:
  name: static-client
spec:
  selector:
    app: static-client
  ports:
    - port: 80
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: static-client
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: static-client
spec:
  replicas: 1
  selector:
    matchLabels:
      app: static-client
  template:
    metadata:
      name: static-client
      labels:
        app: static-client
      annotations:
        "consul.hashicorp.com/connect-inject": "true"
        "consul.hashicorp.com/connect-service-upstreams": "static-server:1234"
    spec:
      containers:
        - name: static-client
          image: docker.mirror.hashicorp.services/curlimages/curl:latest
          command: [ "/bin/sh", "-c", "--" ]
          args: [ "while true; do sleep 30; done;" ]
      serviceAccountName: static-client
```

It looks like none of the EDS endpoints are being displayed or linked to their 
clusters. I’m seeing it consistently in my testing with other gateways. I think 
it’s a pretty important bug to fix before we release because this is crucial 
information for someone trying to debug as this will show dynamic cluster info.
The static info is rarely the cause of your problems.

This is especially true for mesh gateways because you see a bunch of endpoints 
but no info about their clusters (and vice versa for clusters), and so I feel 
like I need to look at raw envoy config instead of using the CLI. Here is what 
I’m seeing for the mesh gateway:



