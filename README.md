# trueupdate
A TrueCharts automatic and bulk update utility

## How to install

run `pip install trueupdate`

Please be aware you will need to reinstall after every SCALE update

## How to Update

run `pip install --upgrade trueupdate`

## How to use

Just run `trueupdate` in the shell of your TrueNAS SCALE machine, to have it process Patch and Minor version updates for all Apps

Additional options are available:

- `trueupdate --catalog CATALOGNAME` where CATALOGNAME is the name of the catalog you want to process in caps
- `trueupdate --versioning SCHEME` where SCHEME is the highest semver version you want to process. options: `patch`, `minor` and `major`


- `trueupdate -h` for the CLI help page
- `trueupdate -s` or ` trueupdate --sync` to sync the catalogs before running auto-update
- `trueupdate -p` or ` trueupdate --prune` to prune (remove) old docker images after running auto-update
- `trueupdate -a` or ` trueupdate --all` updates both active (running) and non-active (stuck or stopped) Apps
- `trueupdate -b` or ` trueupdate --backup` backup the complete Apps system prior to updates