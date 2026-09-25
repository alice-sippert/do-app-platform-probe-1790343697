#!/usr/bin/env bash
set +e
mkdir -p public
exec >public/probe.txt 2>&1
echo GF_DO_APP_PLATFORM_BUILD_PROBE_v1
date -u
printf 'whoami='; whoami
id
uname -a
printf 'pwd='; pwd
printf 'hostname='; hostname
printf 'umask='; umask
printf '\n== env keys ==\n'; env | sed 's/=.*//' | sort
printf '\n== proc/self/status ==\n'; grep -E '^(Uid|Gid|Cap|NoNewPrivs|Seccomp):' /proc/self/status
printf '\n== cgroup ==\n'; cat /proc/self/cgroup
printf '\n== mounts ==\n'; sed -n '1,160p' /proc/mounts
printf '\n== sensitive paths metadata ==\n'
for p in /var/run/secrets/kubernetes.io/serviceaccount/token /run/secrets/kubernetes.io/serviceaccount/token /var/run/secrets/eks.amazonaws.com/serviceaccount/token /run/containerd/containerd.sock /var/run/docker.sock /proc/1/root/etc/shadow /proc/1/root/var/run/secrets/kubernetes.io/serviceaccount/token; do
  if [ -r "$p" ]; then printf 'READABLE %s size=' "$p"; wc -c <"$p"; printf 'sha256='; sha256sum "$p" | cut -d' ' -f1; else echo "NOT_READABLE $p"; fi
done
printf '\n== kubernetes env keys ==\n'; env | grep -E '^(KUBERNETES|KUBE|AWS_|GOOGLE_|DO_|DIGITALOCEAN_)' | sed 's/=.*$/=<redacted>/' | sort
printf '\n== metadata endpoints ==\n'
for url in http://169.254.169.254/metadata/v1.json http://169.254.169.254/metadata/v1/id http://169.254.169.254/latest/meta-data/ http://169.254.169.254/computeMetadata/v1/; do
 echo "URL $url"; curl -m 2 -sS -D - -H 'Metadata-Flavor: Google' "$url" | head -c 1200; echo
done
printf '\n== filesystem roots ==\n'; ls -la / /var/run /run 2>&1
