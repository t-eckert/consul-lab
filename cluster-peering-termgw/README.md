# Cluster Peering Terminating Gateway

This experiment tests a configuration where two Consul clusters in separate Kubernetes clusters are connected
using a cluster peering. One cluster has a terminating gateway and the other has a service that should be 
able to reach the external service configured for the terminating gateway.

```text
__ dc1 ________________          __ dc2 ________________    
|  ____________       |          |                     | 
|  |          |       |          |                     | 
|  | frontend |       |          |                     | 
|  |__________|       |          |                     |
|        |            |          |                     |
|        |    ___________     ___________     _______________    __________
|        |    |         |     |         |     |             |    |        |
|        ---->|  Mesh   |---->|  Mesh   |---->| Terminating |--->| Google |
|             | Gateway |     | Gateway |     |   Gateway   |    |________|
|             |_________|     |_________|     |_____________|
|                     |          |                     | 
|_____________________|          |_____________________|
```
