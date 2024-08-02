# eviction-memory-monitor
This pod will run as a Daemonset in each node and will run the script provided by k8s to simulate the data gathering done for eviction on nodes as is shown here:

https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/

The scripts are refered in the following section of the page:

"""  
[...]  
The value for memory.available is derived from the cgroupfs instead of tools like free -m. This is important because free -m does not work in a container, and if users use the node allocatable feature, out of resource decisions are made local to the end user Pod part of the cgroup hierarchy as well as the root node. This (script)[https://kubernetes.io/examples/admin/resource/memory-available.sh] or (cgroupv2 script)[https://kubernetes.io/examples/admin/resource/memory-available-cgroupv2.sh] reproduces the same set of steps that the kubelet performs to calculate memory.available. The kubelet excludes inactive_file (the number of bytes of file-backed memory on the inactive LRU list) from its calculation, as it assumes that memory is reclaimable under pressure.  
[...]  
"""  

This script will run and get the values mentioned on this k8s documentation, you can check the collected data using `oc logs` for the pod and node you want to validate.

It usese the rhel8/support-tool image as base and the scripts. To simplify the deployment I use 3 configmaps to deploy the scripts used here.

By default the script will wait $SLEEPTIME for each data capture, default is set to 10s, you can adjust this on the eviction-memory-monitor.yaml file.

Instructions:

- Create the eviction-memory-monitor project:
```
 $ oc new-project eviction-memory-monitor
```
- Add the label `eviction-memory-monitor: true` to the nodes where the pod will run.
- Be sure to switch to the new project created using:
```
 $ oc project eviction-memory-monitor
```
- Add the privileged scc to the default service account:
```
 $ oc adm policy add-scc-to-user privileged -z default
```
- Create the configmap based on the 3 scripts used here: 
```
$ oc create configmap entrypoint --from-file=entrypoint.sh=entrypoint.sh
$ oc create configmap cgroupv1 --from-file=memory-available.sh=memory-available.sh
$ oc create configmap cgroupv2 --from-file=memory-available-cgroupv2.sh=memory-available-cgroupv2.sh
```
- Create the daemonset:
```
$ oc create -f eviction-memory-monitor.yaml
```

The entrypoint.sh script will run mtr using 600 test and then will run again over an infinite loop. You can adjust that modifying the entrypoint.sh file. To obtain the results just obtain the logs from each pod.

