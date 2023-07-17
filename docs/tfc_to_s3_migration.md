# Instructions for Migrating Terraform Backend from Terraform Cloud to Amazon S3

These step-by-step instructions will guide you through the process of migrating your Terraform backend from Terraform Cloud to Amazon S3. This migration needs to be performed for each environment (dev, test, prod, and tools) in your setup. The migration will allow you to transition from using Terraform Cloud for state storage and management to using an S3 bucket and DynamoDB table as the backend for your Terraform state.

Please note that you will need the following prerequisites before proceeding with the migration:

- Terraform CLI installed on your local machine.
- AWS CLI configured with the necessary credentials obtained from the AWS Login Application at [https://login.nimbus.cloud.gov.bc.ca](https://login.nimbus.cloud.gov.bc.ca/) .
- Obtain the Terraform Cloud team token for your project-set from Paramater Store in one of the AWS accounts.

Now, let's begin with the migration process for each environment:

## 1. Set Environment Variables

Obtain the AWS credentials, including the session token, from the AWS Login Application at [https://login.nimbus.cloud.gov.bc.ca](https://login.nimbus.cloud.gov.bc.ca/) and set them in your terminal

```shell

export AWS_ACCESS_KEY_ID=<access-key-id>
export AWS_SECRET_ACCESS_KEY=<secret-access-key>
export AWS_SESSION_TOKEN=<session-token>
export AWS_DEFAULT_REGION=<region-name>
```

Obtain the Terraform Cloud team token for your project-set from Paramater Store in one of the AWS accounts and set it in your terminal.

```shell

terraform login
```

Enter the terraform team token when prompted

## 2. Run terraform init

Open your terminal, navigate to the directory containing your Terraform configuration files, and run the following command:

```shell

terraform init
```

## 3. Use Existing or Create New S3 Bucket and DynamoDB Table

**Option 1: Use Existing Resources (Recommended):**  

- For each environment, use the existing S3 bucket and DynamoDB table by providing the respective names:
- S3 bucket name: `terraform-remote-state-<license-plate>-<environment>`
- DynamoDB table name: `terraform-remote-state-lock-<license-plate>`
- Proceed to Step 4 to update the backend configuration with these existing resource names.

**Option 2: Create New Resources:**  

- If you prefer to create new resources for each environment, follow the instructions below using AWS CLI commands:
- Create the S3 bucket:

  ```shell

  aws s3api create-bucket --bucket custom-statefile-bucket-name --region <region-name>
  ```

Replace `custom-statefile-bucket-name` with a custom name for the S3 bucket, and `<region-name>` with the desired AWS region.

- Create the DynamoDB table:

  ```shell

  aws dynamodb create-table \
    --table-name custom-state-lock-table-name \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --region <region-name>
  ```

Replace `custom-state-lock-table-name` with a custom name for the DynamoDB table, and `<region-name>` with the desired AWS region.

## 4. Update the Backend Configuration

**Terraform Cloud Backend Configuration (Old):**

```hcl

terraform {
  backend "remote" {
    organization = "<organization-name>"
    workspaces {
      name = "<workspace-name>"
    }
  }
}
```

**S3 Backend Configuration (New):**

```hcl

terraform {
  backend "s3" {
    bucket         = "<custom-statefile-bucket-name>"  # Replace with either generated or custom bucket name
    key            = "<path-to-state-file>"           # Path and name of the state file within the bucket
    region         = "<region-name>"                   # AWS region where the bucket is located
    dynamodb_table = "<custom-state-lock-table-name>"  # Replace with either generated or custom DynamoDB table name
    encrypt        = true                              # Enable encryption for the state file
  }
}
```

Replace `<custom-statefile-bucket-name>` with the name of the existing or newly created S3 bucket. `<path-to-state-file>` is the path and name of the state file within the bucket. `<region-name>` refers to the AWS region where the bucket is located. `<custom-state-lock-table-name>` is the name of the existing or newly created DynamoDB table.

## 5. Run terraform init -migrate-state


Open your terminal, navigate to the directory containing your Terraform configuration files, and run the following command:

```shell

terraform init -migrate-state
```

Review the output to ensure that the migration completed successfully without any errors. Once the migration is complete, Terraform will create a new state file in the S3 bucket.

## 6. Run terraform plan

Run the following command to perform a plan and verify that there are "no changes":

```shell

terraform plan
```

The plan output should indicate that there are "no changes" to be made, confirming that the migration to the new backend was successful.

## 7. Save and Commit

Save the changes to your Terraform configuration file and commit the changes to your version control system (if applicable).

Repeat steps 1 to 7 for each environment (dev, test, prod, and tools) in your setup.

That's it! You have successfully migrated the Terraform backend from Terraform Cloud to Amazon S3 for each environment. Going forward, Terraform will use the new S3 backend for state management. Remember to update your documentation and inform other team members about the backend migration for each environment.
