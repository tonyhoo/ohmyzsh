# Custom Oh-My-Zsh Configuration

This directory contains personal customizations for Oh-My-Zsh.

## Custom Scripts
- `amazon.zsh`: Amazon-specific aliases, functions and utilities
- `aws_swf.zsh`: Helper functions for AWS Simple Workflow Service
- `oncall.zsh`: Scripts for oncall work

## Custom Theme
- `ec2-robbyrussell.zsh-theme`: Modified robbyrussell theme with EC2 indicator

## Custom Plugins
- `dump_repo`: Plugin for dumping repository information
- `ssh-nirvana`: Enhanced SSH functionality

## Third-Party Plugins
The following third-party plugins need to be installed separately:

### zsh-autosuggestions
```
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

### zsh-syntax-highlighting
```
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### zsh-completions
```
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
```

## Powerlevel10k Theme (Optional)
If you want to use the Powerlevel10k theme:
```
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

Then add `ZSH_THEME="powerlevel10k/powerlevel10k"` to your ~/.zshrc.