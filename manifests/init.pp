class puppet-ircd-hybrid ($sid, $desc, $net_name, $net_desc, $admin_name,
                          $admin_desc, $admin_email, $rsa_key, $rsa_pub,
                          $cert, $oper_name = 'god',
                          $oper_pwd = '$5$x5zof8qe.Yc7/bPp$5zIg1Le2Lsgd4CvOjaD20pr5PmcfD7ha/9b2.TaUyG4'
    ) {

    file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6':
        ensure => 'file',
        source => 'puppet:///modules/puppet-ircd-hybrid/RPM-GPG-KEY-EPEL-6',
        group => '0',
        mode => '644',
        owner   => '0',
    }

    yumrepo { 'epel':
        ensure => 'present',
        descr => 'Extra Packages for Enterprise Linux 6 - $basearch',
        enabled => '1',
        failovermethod => 'priority',
        gpgcheck => '1',
        gpgkey => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6',
        mirrorlist => 'https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch',
        require => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6'],
    }

    package { 'ircd-hybrid':
        ensure => 'installed',
		allow_virtual => false,
    }

    file { '/etc/ircd/ircd.conf':
        path => '/etc/ircd/ircd.conf',
        owner => '0',
        group => '0',
        mode => '0644',
        require => Package['ircd-hybrid'],
        content => template('puppet-ircd-hybrid/ircd.conf.erb'),
        notify => Service['ircd'],
    }

    file { '/etc/ircd/rsa.key':
        path => '/etc/ircd/rsa.key',
        owner => 'ircd',
        group => 'ircd',
        mode => '0600',
        require => Package['ircd-hybrid'],
        source => $rsa_key,
        notify => Service['ircd'],
    }

    file { '/etc/ircd/rsa.pub':
        path => '/etc/ircd/rsa.pub',
        owner => 'ircd',
        group => 'ircd',
        mode => '0644',
        require => Package['ircd-hybrid'],
        source => $rsa_pub,
        notify => Service['ircd'],
    }

    file { '/etc/ircd/cert.pem':
        path => '/etc/ircd/cert.pem',
        owner => 'ircd',
        group => 'ircd',
        mode => '0644',
        require => Package['ircd-hybrid'],
        source => $cert,
        notify => Service['ircd'],
    }

	service { 'ircd':
		ensure => 'running',
		enable => true,
        require => Package['ircd-hybrid'],
	}

}
