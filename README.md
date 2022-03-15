# Serverless Architecture
![Serverless Architecture](./images/serverless-architecture.png)

# startup-sample-project-aws-serverless
Lambda serverless app meant to accelerate teams onboarding to the BC Gov SEA AWS space.

## Setup
- Fork this repo
- Enable github actions
#### Github Secrets
you'll need to add two github secrets:
  - `LICENCEPLATE` is the 6 character licence plate associated with your project set e.g. `abc123`
  - `TFC_TEAM_TOKEN` is the token used to access the terraform cloud runner.

#### Pipeline
The github actions will trigger on a pull request creation and merge.
- Creating a pull request will run a `terraform plan` and outline everything that will be deployed into your AWS accounts, but will not create anything.
- Merging into `main` will run a `terraform apply` and your AWS assets will be deployed into your `dev` and `sandbox` accounts.
>NOTE: make sure you are creating pull requests/ merging within your fork

Hello World!
