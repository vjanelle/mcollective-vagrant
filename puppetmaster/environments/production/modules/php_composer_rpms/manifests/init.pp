class php_composer_rpms {
    $packages = [
        'rpmdevtools',
        'rpm-build',
        'php-jsonlint',
        'php-JsonSchema',
        'php-symfony2-Console',
        'php-symfony2-Finder',
        'php-symfony2-Process',
        'php-phpunit-PHPUnit',
    ]
    @package { $packages:
        ensure => installed,
    }
    Package<| |>
}
