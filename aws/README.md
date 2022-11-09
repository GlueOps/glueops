
## Requirements:

--todo after verifying in GCP.

#### Notes:

- Copy `.env.tpl` in `../shared/.env.tpl` and create: `../shared/.env` and set all the variables. Please ignore anything that isn't relevant to the cloud you are deploying on.
- Source the `.env` file with `../shared/.env`
- Run: `task auth` and login to each service. We recommend using a dedicated test/dev account for each service (ex. GCP, Terraform Cloud)
- Run `task cluster_up`
- Run `task configs`
- Run `task bootstrap_admiral`
- Run `task shared:bootstrap_captain`
- Run `task shared:send_credentials_to_slack`
- Run `task clean`
- 