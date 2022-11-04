n_servers = 100

for i in range(n_servers):
    template = f"""apiVersion: apps/v1
kind: Deployment
metadata:
  name: server-{i}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: server-{i}
  template:
    metadata:
      name: server-{i}
      labels:
        app: server-{i}
    spec:
      containers:
        - name: server
          image: docker.mirror.hashicorp.services/hashicorp/http-echo:latest
          args:
            - -text="hello world"
            - -listen=:8080
          ports:
            - containerPort: 8080
              name: http
          resources:
            requests:
              memory: "64Mi"
              cpu: "250m"
            limits:
              memory: "128Mi"
              cpu: "500m"
      serviceAccountName: server-{i}
      terminationGracePeriodSeconds: 0
---
apiVersion: v1
kind: Service
metadata:
  name: server-{i}
spec:
  selector:
    app: server-{i}
  ports:
    - name: http
      port: 80
      targetPort: 8080
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: server-{i}
---
apiVersion: consul.hashicorp.com/v1alpha1
kind: ServiceDefaults
metadata:
  name: server-{i}
spec:
  protocol: http"""

    with open(f"spec/server-{i}.yaml", "w+") as f:
        f.write(template)

