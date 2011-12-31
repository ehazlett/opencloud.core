class git {
  define clone($repo, $revision='master', $dest, $user=undef) {
    $repo_name = inline_template("<%= repo.split('/')[-1] %>")
    if $user {
      $cmd = "sudo -u ${user} git clone ${repo} ${dest}"
    } else {
      $cmd = "git clone ${repo} ${dest}"
    }   
    exec { "git_clone_${repo_name}":
      path    => "/usr/bin",
      cwd     => "/tmp",
      command => "${cmd}",
      require => Package["git-core"],
      creates => "${dest}",
      notify  => Exec["git_checkout_${repo_name}"],
    }   
    exec { "git_checkout_${repo_name}":
      path        => "/usr/bin",
      cwd         => "${dest}",
      command     => "git checkout ${revision}",
      refreshonly => true,
    }   
  }
}
