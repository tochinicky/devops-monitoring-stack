# Monitoring Stack with Terraform and Ansible

This repository contains the infrastructure and configuration for a comprehensive monitoring setup using:

- Terraform for infrastructure provisioning
- Ansible for configuration management
- Prometheus for metrics collection
- Alertmanager for alerting
- Grafana for visualization
- Node.js application for DORA metrics

## Project Structure

```
.
├── terraform/              # Terraform configurations
│   ├── main.tf            # Main infrastructure configuration
│   ├── variables.tf       # Variable definitions
│   ├── outputs.tf         # Output definitions
│   └── .terraform.lock.hcl # Provider version lock file
├── monitoring_stack/      # Ansible playbooks and roles
│   ├── ansible.cfg        # Ansible configuration
│   ├── inventory.ini      # Inventory file
│   ├── playbook.yml       # Main playbook
│   ├── group_vars/        # Group variables
│   └── roles/
│       └── monitoring_stack/
│           ├── tasks/     # Ansible tasks
│           ├── handlers/  # Task handlers
│           ├── templates/ # Configuration templates
│           ├── files/     # Static files
│           └── vars/      # Role variables
└── node-app/             # Node.js application
    ├── app.js           # Main application code
    ├── ecosystem.config.js # PM2 configuration
    ├── package.json     # Node.js dependencies
    ├── jest.config.js   # Jest configuration
    ├── eslint.config.js # ESLint configuration
    ├── .editorconfig    # Editor configuration
    ├── __tests__/       # Test files
    └── .github/         # GitHub workflows
```

## Prerequisites

- Terraform >= 1.0.0
- Ansible >= 2.9.0
- Node.js >= 20.x
- Azure CLI (for Azure cloud)
- SSH access to target servers

## Setup Instructions

1. Configure Azure credentials:

   ```bash
   az login
   ```

2. Initialize Terraform:

   ```bash
   cd terraform
   terraform init
   ```

3. Apply Terraform configuration:

   ```bash
   terraform apply
   ```

4. Set up sensitive variables:

   ```bash
   cd monitoring_stack
   cp group_vars/all.yml.template group_vars/all.yml
   # Edit group_vars/all.yml with your sensitive data
   ```

5. Run Ansible playbook:
   ```bash
   ansible-playbook playbook.yml
   ```

## Configuration

### Terraform Variables

- `resource_group_name`: Azure resource group name
- `location`: Azure region
- `vm_size`: Size of the VM
- `admin_username`: Admin username for VMs
- `ssh_public_key`: SSH public key for VM access

### Ansible Variables

The following sensitive variables should be configured in `monitoring_stack/group_vars/all.yml`:

- `slack_webhook_url`: Slack webhook URL for alerts
- `github_token`: GitHub token for DORA metrics
- `github_organization`: GitHub organization name
- `github_repository`: GitHub repository name
- `website_url`: URL to monitor
- Component checksums for verification

> **Note**: Never commit the actual `all.yml` file with sensitive data to version control. Use `all.yml.template` as a reference and create your own `all.yml` file locally.

## Monitoring Components

1. **Prometheus**

   - Collects metrics from various sources
   - Stores time-series data
   - Provides query language (PromQL)

2. **Alertmanager**

   - Handles alerts from Prometheus
   - Routes alerts to different channels (Slack, email)
   - Manages alert grouping and inhibition

3. **Grafana**

   - Creates dashboards for metrics visualization
   - Supports multiple data sources
   - Provides alerting capabilities

4. **Node.js Application**
   - Simulates DORA metrics
   - Exposes metrics in Prometheus format
   - Provides web interface for testing

## Contributing

1. Create a feature branch
2. Make your changes
3. Submit a pull request

## License

MIT License
