# Monitoring and Logging Stack

This repository contains an Ansible playbook for setting up a comprehensive monitoring and logging solution on Azure VMs (though it can be adapted to other environments). The solution includes a Prometheus-based monitoring stack and an Elasticsearch-Fluentd-Kibana (EFK) stack for log aggregation and analysis.

## Overview

### Monitoring Capabilities (Prometheus Stack)
- **Prometheus**: Time-series database for metrics collection and storage
- **Alertmanager**: Handles alerts from Prometheus and routes notifications
- **Node Exporter**: Collects hardware and OS metrics
- **Blackbox Exporter**: Probes endpoints over HTTP, HTTPS, DNS, TCP, and ICMP
- **DORA Metrics**: Collects DevOps Research and Assessment performance metrics
- **Nginx**: Reverse proxy for secure access to monitoring UIs

### Logging Capabilities (EFK Stack)
- **Elasticsearch**: Distributed search and analytics engine for storing logs
- **Fluentd**: Unified logging layer for collecting, filtering, and forwarding logs
- **Kibana**: Visualization platform for exploring and dashboarding logs

### Integration Benefits
- Unified observability platform combining metrics and logs
- Correlation between system metrics and log events
- Comprehensive dashboards for system health and application performance
- Centralized alerting and notification system

## Prerequisites and Requirements

### System Requirements
- Ubuntu 20.04 LTS or newer (recommended)
- Minimum 4GB RAM (8GB+ recommended)
- 2 vCPUs or more
- 40GB disk space (SSD recommended)

### Software Requirements
- Ansible 2.9+
- Python 3.6+
- SSH access to target servers
- Sudo privileges on target servers

### Network Requirements
- Outbound internet access for package installation
- Inbound access to ports:
  - 80/443 (Nginx)
  - 9090 (Prometheus, if directly accessed)
  - 9093 (Alertmanager, if directly accessed)
  - 9100 (Node Exporter, if directly accessed)
  - 5601 (Kibana, if directly accessed)
  - 9200/9300 (Elasticsearch, if directly accessed)

## Installation and Setup

### Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/monitoring-stack.git
   cd monitoring-stack
   ```

2. Copy and customize the inventory file:
   ```bash
   cp inventory.sample.ini inventory.ini
   # Edit inventory.ini with your server details and configuration preferences
   ```

3. Run the playbook:
   ```bash
   ansible-playbook -i inventory.ini playbook.yml
   ```

### Detailed Setup

The installation process will:

1. Install and configure Prometheus and related exporters
2. Set up Alertmanager with notification channels
3. Install Elasticsearch for log storage
4. Configure Fluentd (td-agent) to collect system and application logs
5. Set up Kibana for log visualization and exploration
6. Configure Nginx as a reverse proxy with SSL/TLS

After installation, the following endpoints will be available:
- Prometheus: https://your-server/prometheus/
- Alertmanager: https://your-server/alertmanager/
- Grafana (if installed): https://your-server/grafana/
- Kibana: https://your-server/kibana/

## Configuration Options

### Monitoring Stack Configuration

Key variables that can be customized in your inventory file:

```ini
[monitoring_servers]
mon-server ansible_host=10.0.0.1

[monitoring_servers:vars]
prometheus_retention_time=15d
prometheus_scrape_interval=15s
alertmanager_slack_webhook=https://hooks.slack.com/services/XXX/YYY/ZZZ
alertmanager_email_to=alerts@example.com
alertmanager_email_from=prometheus@example.com
```

See `roles/monitoring_stack/vars/main.yml` for all available options.

### Logging Stack Configuration

Key variables for the EFK stack:

```ini
[monitoring_servers:vars]
elasticsearch_heap_size=2g
elasticsearch_cluster_name=monitoring-cluster
kibana_server_name=logs.example.com
fluentd_flush_interval=10s
fluentd_buffer_chunk_limit=8m
```

See `roles/efk_stack/vars/main.yml` for all available options.

### Integration Configuration

To correlate metrics and logs, additional variables can be set:

```ini
[monitoring_servers:vars]
# Enable cross-linking between Prometheus and Kibana
enable_metric_log_linking=true
# Configure log timestamps to match metrics timestamps
fluentd_time_format="%Y-%m-%dT%H:%M:%S%z"
```

## Security Considerations

### Authentication

- **Basic Authentication**: Enabled by default for Nginx (protects all UIs)
- **Elasticsearch Security**: Password protection and TLS encryption
- **Prometheus Authentication**: Basic authentication when accessed through Nginx

### Encryption

- **TLS/SSL**: Nginx is configured with SSL by default (self-signed certificate, can be replaced)
- **Internal Communications**: Can be configured to use TLS between components

### Network Security

- Only Nginx ports (80/443) need to be exposed externally
- Internal components communicate on the local network
- Firewall rules should be configured to restrict access to required ports only

### Hardening Tips

1. Use custom certificates instead of self-signed ones
2. Implement IP-based restrictions in Nginx
3. Use strong passwords for all authentication mechanisms
4. Regularly update all components to patch security vulnerabilities

## Usage Examples

### Monitoring System Health

1. Access Prometheus UI at https://your-server/prometheus/
2. Use predefined dashboards or create custom queries
3. Example query for CPU usage:
   ```
   100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
   ```

### Setting Up Alerts

1. Edit `roles/monitoring_stack/templates/prometheus/alert_rules.yml.j2`
2. Add new alert rules, for example:
   ```yaml
   - alert: HighCPUUsage
     expr: 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 85
     for: 5m
     labels:
       severity: warning
     annotations:
       summary: "High CPU usage on {{ $labels.instance }}"
       description: "CPU usage is above 85% for 5 minutes"
   ```
3. Run the playbook to apply changes

### Viewing and Analyzing Logs

1. Access Kibana at https://your-server/kibana/
2. Create an index pattern (typically `fluentd-*`)
3. Use Discover tab to search logs with queries like:
   ```
   host.keyword:"web-server-1" AND message:"error"
   ```
4. Create visualizations and dashboards for common log patterns

### Correlating Metrics and Logs

1. From Prometheus alerts, click on server links to view related logs
2. In Kibana, use the timeline to correlate log events with metric spikes
3. Create a dashboard that shows both metrics and log frequency

## Troubleshooting

Common issues and solutions:

- **Services not starting**: Check systemd status (`systemctl status [service]`)
- **Missing data in Prometheus**: Verify target status in Prometheus UI
- **Logs not appearing in Kibana**: Check Fluentd configuration and restart service
- **Elasticsearch performance issues**: Adjust JVM heap size in configuration

For more help, check the logs of individual components at:
- Prometheus: `/var/log/prometheus/prometheus.log`
- Elasticsearch: `/var/log/elasticsearch/elasticsearch.log`
- Fluentd: `/var/log/td-agent/td-agent.log`
- Kibana: `/var/log/kibana/kibana.log`
- Nginx: `/var/log/nginx/error.log`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

