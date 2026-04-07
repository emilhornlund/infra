# Home Assistant

## Configuration

Create a `configuration.yaml` inside `home-assistant-config-volume`

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.20.0.0/16
```
