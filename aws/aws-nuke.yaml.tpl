regions:
- us-west-2
- global

account-blocklist:
- "$ROOT_ACCOUNT_ID" # root account

accounts:
  $TARGET_ACCOUNT_ID:
    presets:
      - common
  
  
presets:
  common:
    filters:
      IAMRole:
      - type: regex
        value: '.*OrganizationAccountAccessRole.*'
      IAMRolePolicyAttachment:
      - type: regex
        value: '.*OrganizationAccountAccessRole.*'
      OpsWorksUserProfile:
      - type: regex
        value: '.*OrganizationAccountAccessRole.*'

#Make sure your export the terraform-svc account credentials and then the commands below assume roles.
# Admiral
#./aws-nuke-v2.19.0-linux-amd64 -c aws-nuke.yaml --assume-role-arn arn:aws:iam::539362929792:role/OrganizationAccountAccessRole --no-dry-run --force

# Captain
#./aws-nuke-v2.19.0-linux-amd64 -c aws-nuke.yaml --assume-role-arn arn:aws:iam::723876146658:role/OrganizationAccountAccessRole --no-dry-run --force
