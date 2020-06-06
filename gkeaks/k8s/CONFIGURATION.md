# Application configuration options

Template for optional configurations are specified in `marketplace.auto.tfvars.template`.
Copy that file in new marketplace.auto.tfvars and populate vaules required for terraform apply
**Required**

- domain: The domain name (e.g. akenza.io)
- infrastructure_workspace_name: The corresponding Terraform Cloud infrastructure workspace name.
- tls-cert: A valid SSL certificate for *.domain
- tls-key: The key for the SSL certificate.
- google_recaptcha_site_key: Retrieve a Google recaptcha site key for your domain (select v2 - "I am not a robot checkbox").    
- google_recaptcha_secret_key: Retrieve a Google recaptcha secret key for your domain