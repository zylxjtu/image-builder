# Copyright 2020 The Kubernetes Authors.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# From https://github.com/kubernetes-sigs/sig-windows-tools/blob/master/kubeadm/scripts/PrepareNode.ps1
# Does not support kubeadm KUBELET_KUBEADM_ARGS which is used by Cluster API to pass extra user args
# Need to keey sync with StartKubelet.ps1
$FileContent = Get-Content -Path "$env:SYSTEMDRIVE/var/lib/kubelet/kubeadm-flags.env"
$kubeAdmArgs = $FileContent.TrimStart('KUBELET_KUBEADM_ARGS=').Trim('"')

$args = "--cert-dir=$env:SYSTEMDRIVE/var/lib/kubelet/pki",
        "--config=$env:SYSTEMDRIVE/var/lib/kubelet/config.yaml",
        "--bootstrap-kubeconfig=$env:SYSTEMDRIVE/etc/kubernetes/bootstrap-kubelet.conf",
        "--kubeconfig=$env:SYSTEMDRIVE/etc/kubernetes/kubelet.conf",
        "--hostname-override=$(hostname)",
        "--pod-infra-container-image=`"{{ pause_image }}`"",
        "--enable-debugging-handlers",
        "--cgroups-per-qos=false",
        "--enforce-node-allocatable=`"`"",
        "--resolv-conf=`"`"",
        "--windows-service"

$KubeletArgListStr = ($args -join " ") + " $kubeAdmArgs"
$KubeletArgListStr = $KubeletArgListStr.Replace("`"", "\`"")
# Used by sc.exe to create the service 
$KubeletCommandLine =  "`"" + "\`"" + "$env:SYSTEMDRIVE\k\kube-log-runner.exe" + "\`" " + "--log-file=/var/log/kubelet/kubelet.log " + "$env:SYSTEMDRIVE\k\kubelet.exe " + $KubeletArgListStr + "`""

#Write-Output $kubeletCommandLine
sc.exe create kubelet binPath= $KubeletCommandLine start= auto depend= containerd