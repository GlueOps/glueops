[profile admiral]
role_arn = arn:aws:iam::$ADMIRAL_ACCOUNT_ID:role/OrganizationAccountAccessRole
credential_source = Environment

[profile captain]
role_arn = arn:aws:iam::$CAPTAIN_ACCOUNT_ID:role/OrganizationAccountAccessRole
credential_source = Environment
