# dotfiles

This repository manages the dotfiles.

## Reset Mac

See [this article](https://support.apple.com/en-us/102664)

## New Machine

When setting up a new machine, run this command in Terminal:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/anniehedgpeth/dotfiles/refs/heads/main/setup.sh)"
```

This will:

- Install brew
- Install gh and authenticate
- Clone this repository to `~/dotfiles`

Restart your terminal after you run this in order for it to know brew is there.

## Initial Setup

Once this repository is cloned with the above process, navigate to `~/dotfiles`
and run `./update.sh`, which:

- Ensures all Apple updates are completed
- Installs all brew packages
- Creates symlinks for dotfiles to their normal locations
- Sets up AI

## XCode

After initial setup, XCode needs to be updated from the App Store and started.

After it is started, run this command to ensure Swift tools are available on
the terminal:

```sh
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

```

## Update

From here to ensure everything is proper, run `update`. It's meant to be run
as many times as you want.

## Secrets

Copy `.env.template` to `~/.env` and add the appropriate values.

## Other AppStore Apps

Install these apps from the App Store:

- ZSA Keybindings
- Apple Developer

## Manual Configuration

First, set up accounts on the computer:

1. Open Passwords, from which you will get credentials.
2. Open Safari and log into the accounts in their associated profiles.
3. Add internet accounts (work, home, family).
4. Open Slack and add accounts to it.

Then, open and configure these apps:

- Safari -> Settings -> Tabs -> Tab layout: Compact
- Messages -> Settings -> iMessage -> Enable Messages in iCloud checked
- Photos -> Settings -> iCloud -> iCloud Photos -> Optimize Mac Storage selected
- Music -> Settings -> General -> Automatic Downloads checked
- Music -> Settings -> General -> Download Dolby Atmos
- Music -> Settings -> General -> Show: -> Star Ratings checked
- Music -> Settings -> Playback -> Lossless Audio -> Enable Lossless Audio checked
- Podcasts -> Settings -> Automatically Download set to off
- Calendar -> Settings -> Advanced -> Turn on time zone support checked
- Calendar -> Settings -> Advanced -> Show week numbers checked
- Mail -> Settings -> Junk Mail -> Junk Mail Behaviors -> Enabled junk mail
  filtering checked
- Mail -> Settings -> Viewing -> Summarize Message Previews unchecked
- Mail -> Settings -> Viewing -> Move discarded messages into: -> Archive

Finally, open System Settings and configure the mac:

- General -> Date & Time -> 24-hour time checked
- General -> Date & Time -> Show 24-hour time on Lock Screen checked
- Appearance -> Appearance -> Dark
- Control Center -> Control Center Modules -> Focus -> Always Show
- Control Center -> Control Center Modules -> Sounds -> Always Show
- Screen Saver -> (you choose)
- Trackpad -> Tracking Speed -> 8/10
- Printers & Scanners -> Add Printer, Scanner or Fax... (follow prompts)

### XCode Key Bindings

- Copy contents from `https://gist.githubusercontent.com/hoishing/2b024e625024e5b409f0bb5941688375/raw/78e39d535d201af024221f28ffcb02b0a1903249/VSCode.idekeybindings`
- Paste into `~/Library/Developer/Xcode/UserData/KeyBindings/VSCode.idekeybindings`
- In Xcode Settings -> Key Bindings, select VSCode

## Testing

- Build `app` with `just i`
- Open XCode and run the `app`
