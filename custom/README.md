# Custom Oh My Zsh Configuration

This directory contains custom configurations for Oh My Zsh that can be shared across devices.

## Contents

### AWS Utilities (`aws.zsh`)
- **aws-clear-env**: Clears AWS environment variables
- **aws-is-sso-profile**: Checks if a profile uses SSO
- **aws-login-if-needed**: Logs in to SSO only when necessary
- **aws-use**: Unified profile switcher with automatic SSO login
- **awsme**: Quick identity check

### Custom Theme (`themes/ec2-robbyrussell.zsh-theme`)
- Modified Robby Russell theme with EC2 indicator
- Shows `[EC2]` prefix in prompt
- Maintains git status information

### Custom Plugins
- **zsh-syntax-highlighting**: Command syntax highlighting
- **zsh-completions**: Additional completion definitions
- **zsh-autosuggestions**: Fish-like autosuggestions

## Setup Instructions

1. Clone this repository to `~/.oh-my-zsh`
2. Ensure your `~/.zshrc` has:
   ```zsh
   export ZSH="$HOME/.oh-my-zsh"
   ZSH_THEME="ec2-robbyrussell"
   plugins=(git aws brew colored-man-pages sudo z zsh-autosuggestions zsh-completions zsh-syntax-highlighting)
   source $ZSH/oh-my-zsh.sh
   ```

## Customization

### AWS Profiles
Edit `custom/aws.zsh` to add your specific AWS profile functions:
```zsh
aws-dev() {
    aws-use dev
}
alias dev="aws-use dev"
```

### Theme
Modify `custom/themes/ec2-robbyrussell.zsh-theme` to change the prompt appearance.

## Notes
- This configuration is designed to be generic and shareable
- Remove any personal information before sharing
- Test on new devices to ensure compatibility