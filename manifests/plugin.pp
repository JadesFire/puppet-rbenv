# == Define: rbenv::plugin
#
# === Variables
#
# [$install_dir]
#   This is set when you declare the rbenv class. There is no
#   need to overrite it when calling the rbenv::gem define.
#   Default: $rbenv::install_dir
#   This variable is required.
#
# [$latest]
#   This defines whether the plugin is kept up-to-date.
#   Defaults: false
#   This vaiable is optional.
#
# [$env]
#   This is used to set environment variables when installing plugins.
#   Default: []
#   This variable is optional.
#
# === Requires
#
# You will need to install the git package on the host system.
#
# === Examples
#
# rbenv::plugin { 'jamis/rbenv-gemset': }
#
# === Authors
#
# Justin Downing <justin@downing.us>
#
define rbenv::plugin(
  $install_dir = $rbenv::install_dir,
  $latest      = false,
  $env         = $rbenv::env,
) {
  include rbenv

  Exec { environment => $env }

  if $latest == true {
    vcsrepo { "${install_dir}/plugins/${name}":
      ensure   => 'present',
      provider => 'git',
      source   => "https://github.com/${name}.git",
      revision => 'latest',
      user     => "${rbenv::owner}",
      group    => "${rbenv::group}",
    }
  } else {
    vcsrepo { "${install_dir}/plugins/${name}":
      ensure   => 'present',
      provider => 'git',
      source   => "https://github.com/${name}.git",
      user     => "${rbenv::owner}",
      group    => "${rbenv::group}",
    }
  }
}
