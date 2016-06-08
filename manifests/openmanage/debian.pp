#
# == Class: dell::openmanage::debian
#
# Install openmanage tools on Debian
#
class dell::openmanage::debian inherits dell::params {

  include ::apt

  if (!defined(Class['dell'])) {
    fail 'You need to declare class dell'
  }

  # key of:
  # http://linux.dell.com/repo/community/deb/OMSA_7.0/ (same for 7.1)
  # necessary for 6.5
  $key_omsa7 = $dell::omsa_version ? {
    'OMSA_6.5' => 'present',
    'OMSA_7.0' => 'present',
    'OMSA_7.1' => 'present',
    'latest'   => 'present',
    ''         => 'present',
    default    => 'absent',
  }

  # key of:
  # http://linux.dell.com/repo/community/deb/OMSA_6.5/
  $key_omsa6 = $dell::omsa_version ? {
    'OMSA_6.5' => 'present',
    default    => 'absent',
  }

  $omsa_pkg_name = $::lsbdistcodename ? {
    'lenny'   => 'dellomsa',
    'squeeze' => [ 'srvadmin-base', 'srvadmin-storageservices' ],
    default   => [
      'srvadmin-base',
      'srvadmin-storageservices',
      'srvadmin-omcommon' ],
  }

  case $::lsbdistcodename {
    'lenny': {
      apt::source{'dell':
        location    => 'ftp://ftp.sara.nl/pub/sara-omsa',
        release     => 'dell6',
        repos       => 'sara',
        include_src => false,
      }
    }
    default: {
        apt::source { 'dell_omsa':
          comment  => 'Dell OpenManage Ubuntu & Debian Repositories',
          location => 'http://linux.dell.com/repo/community/debian',
          release  => $::lsbdistcodename,
          repos    => 'openmanage',
          key      => {
            'id'     => $dell::params::key,
            'source' => $dell::params::key_source,
            'server' => $dell::params::key_server,
          },
          include => {
            'src'  => false,
            'deb'  => true,
          },
        }
      }
    }

  package { $omsa_pkg_name:
    ensure => present,
    before => Service['dataeng'],
  }

 }
