# CPU Thermal Management

The server runs CPU-intensive workloads such as Agent Orchestrator builds, static analysis, and test suites. On the Intel NUC host, Intel Turbo Boost caused short workloads to drive CPU core temperatures to approximately 100 °C even when Docker CPU limits and build parallelism were constrained.

Turbo Boost is therefore disabled at the host level. This keeps CPU-intensive workloads at substantially lower and more stable temperatures while still allowing containers to use multiple cores in parallel.

## Inspecting Turbo Boost

The host uses the `intel_pstate` CPU frequency driver.

Check the current Turbo Boost state with:

```bash
cat /sys/devices/system/cpu/intel_pstate/no_turbo
```

Expected value:

```text
1
```

A value of:

- `1` means Turbo Boost is disabled.
- `0` means Turbo Boost is enabled.

## Persistent Configuration

Turbo Boost is disabled automatically at boot using a systemd service.

Create:

```text
/etc/systemd/system/disable-turbo.service
```

with:

```ini
[Unit]
Description=Disable Intel CPU turbo boost
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now disable-turbo.service
```

Verify the setting:

```bash
cat /sys/devices/system/cpu/intel_pstate/no_turbo
```

Verify the service:

```bash
systemctl status disable-turbo.service
```

The Turbo Boost setting is host-wide and therefore applies to all Docker containers and other workloads running on the server.

## Re-enabling Turbo Boost

To temporarily re-enable Turbo Boost:

```bash
echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
```

To permanently restore the default behavior:

```bash
sudo systemctl disable --now disable-turbo.service
sudo rm /etc/systemd/system/disable-turbo.service
sudo systemctl daemon-reload

echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
```

## Agent Orchestrator Build Parallelism

Turbo Boost control is combined with explicit build-parallelism limits for CPU-intensive Agent Orchestrator workloads.

For `rpg-sdl`, the orchestrator uses:

```yaml
environment:
  RPG_BUILD_JOBS: "6"
```

The container is allocated six CPUs:

```yaml
cpuset: "0-5"
cpus: 6.0
```

Matching `RPG_BUILD_JOBS` to the available CPU capacity allows the validation pipeline to use the allocated CPUs without unnecessary worker oversubscription.

Build parallelism and Docker CPU allocation should be tuned together. Increasing `RPG_BUILD_JOBS` beyond the CPU capacity available to the container is unlikely to improve throughput and may increase scheduler overhead.

## Observed Result

With Turbo Boost enabled, CPU-intensive validation workloads repeatedly caused core temperatures close to 100 °C.

With Turbo Boost disabled:

- Two build jobs kept temperatures around the high-50s to low-60s °C.
- Six build jobs kept temperatures around the low-to-mid 60s °C.
- Six build jobs provided a better performance/temperature balance and match the container's six-CPU allocation.

The current operating point is therefore:

```text
Intel Turbo Boost: disabled
Docker CPU allocation: 6 CPUs
RPG_BUILD_JOBS: 6
```
