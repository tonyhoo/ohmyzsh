# AWS SSO helper functions that ensure env vars don't override profiles

# Clear any exported static or stale AWS credentials that override profiles
aws-clear-env() {
	unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN AWS_PROFILE AWS_DEFAULT_PROFILE
}

# Determine if a profile is SSO-backed
aws-is-sso-profile() {
	local profile="$1"
	[[ -z "$profile" ]] && return 1
	local sso_session
	local sso_start
	sso_session="$(aws configure get sso_session --profile "$profile" 2>/dev/null)"
	sso_start="$(aws configure get sso_start_url --profile "$profile" 2>/dev/null)"
	[[ -n "$sso_session" || -n "$sso_start" ]]
}

# Login only if the cached SSO token is missing/expired
aws-login-if-needed() {
	local profile="$1"
	[[ -z "$profile" ]] && return 1
	aws sts get-caller-identity --profile "$profile" >/dev/null 2>&1 && return 0
	aws sso login --profile "$profile"
}

# Unified switcher: clears env, selects profile, and logs in for SSO only if needed
aws-use() {
	local profile="$1"
	if [[ -z "$profile" ]]; then
		printf "Usage: aws-use <profile>\n" >&2
		return 2
	fi
	aws-clear-env
	export AWS_PROFILE="$profile"
	# Prefer plugin helper to keep prompt/state in sync
	command -v asp >/dev/null 2>&1 && asp "$profile" >/dev/null 2>&1 || true
	if aws-is-sso-profile "$profile"; then
		aws-login-if-needed "$profile"
	fi
}

# Example profile functions - customize these for your needs
aws-dev() {
	aws-use dev
}

aws-main() {
	aws-use main
}

aws-manage() {
	aws-use manage
}

aws-domain() {
	aws-use domain
}

# Quick identity check
awsme() {
	aws sts get-caller-identity
}

# Add your profile aliases here as needed
# Example: alias dev="aws-use dev"




