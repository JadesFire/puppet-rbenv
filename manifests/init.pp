# == Class: rbenv
#
# This module manages rbenv on Ubuntu. The default installation directory
# allows rbenv to available for all users and applications.
#
# === Variables
#
# [$repo_path]
#   This is the git repo used to install rbenv.
#   Default: 'https://github.com/rbenv/rbenv'
#   This variable is required.
#
# [$install_dir]
#   This is where rbenv will be installed to.
#   Default: '/usr/local/rbenv'
#   This variable is required.
#
# [$owner]
#   This defines who owns the rbenv install directory.
#   Default: 'root'
#   This variable is required.
#
# [$group]
#   This defines the group membership for rbenv.
#   Default: 'adm'
#   This variable is required.
#
# [$latest]
#   This defines whether the rbenv $install_dir is kept up-to-date.
#   Defaults: false
#   This variable is optional.
#
# [$version]
#   This checks out the specified version of rbenv to $install_dir.
#   Defaults: undef
#   This variable is optional and has no affect if latest is true.
#
# [$env]
#   This is used to set environment variables when compiling ruby.
#   Default: []
#   This variable is optional.
#
# === Requires
#
# This module requires the following modules:
#   'puppetlabs/stdlib' >= 4.1.0
#
# === Examples
#
# class { rbenv: }  #Uses the default parameters
#
# class { rbenv:  #Uses a user-defined installation path
#   install_dir => '/opt/rbenv',
# }
#
# More information on using Hiera to override parameters is available here:
#   http://docs.puppetlabs.com/hiera/1/puppet.html#automatic-parameter-lookup
#
# === Authors
#
# Justin Downing <justin@downing.us>
#
# === Copyright
#
# Copyright 2013 Justin Downing
#
class rbenv (
  $repo_path   = 'https://github.com/rbenv/rbenv',
  $install_dir = '/usr/local/rbenv',
  $owner       = 'root',
  $group       = $rbenv::params::group,
  $latest      = false,
  $version     = undef,
  $env         = [],
  $manage_deps = true,
) inherits rbenv::params {

  validate_array($env)

  if $manage_deps {
    include rbenv::deps
  }

  if $latest == true {
    vcsrepo { "${install_dir}":
      ensure   => 'latest',
      provider => 'git',
      source   => "${rbenv::repo_path}",
      owner    => "${owner}",
      group    => "${group}",
    }
  } elsif $version {
    vcsrepo { "${install_dir}":
      ensure   => 'latest',
      provider => 'git',
      source   => "${rbenv::repo_path}",
      revision => "${version}",
      owner    => "${owner}",
      group    => "${group}",
    }
  } else {
    vcsrepo { "${install_dir}":
      ensure   => 'present',
      provider => 'git',
      source   => "${rbenv::repo_path}",
      owner    => "${owner}",
      group    => "${group}",
    }
  }

  file { [
    $install_dir,
    "${install_dir}/plugins",
    "${install_dir}/shims",
    "${install_dir}/versions"
  ]:
    ensure  => directory,
    owner   => "${owner}",
    group   => "${group}",
    mode    => '0775',
    require => Vcsrepo["${install_dir}"],
  }

  vcsrepo { "${install_dir}/plugins/ruby-build":
    ensure   => 'latest',
    provider => 'git',
    source   => 'https://github.com/rbenv/ruby-build.git',
    owner    => "${owner}",
    group    => "${group}",
    require  => Vcsrepo["${install_dir}"],
  }

  file { '/etc/profile.d/rbenv.sh':
    ensure  => file,
    content => template('rbenv/rbenv.sh'),
    mode    => '0775'
  }
}
