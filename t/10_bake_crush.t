use strict;
use warnings;

use Test::More;
use Devel::Cookie qw[crush_cookie bake_cookie];

my @cookie_list = (
    {
        string => 'foo=bar; path=/',
        name => 'foo',
        fields => {
            'value' => 'bar',
            'path' => '/',
        },
    },
    {
        string => 'whv=MtW_XszVxqHnN6rHsX0d; expires=Sun, 10-Jan-2016 18:19:29 GMT; domain=.wikihow.com; path=',
        name => 'whv',
        fields => {
            'value' => 'MtW_XszVxqHnN6rHsX0d',
            'expires' => '1452449969',
            'domain' => '.wikihow.com',
            'path' => '',
        },
        expires => 'Sun, 10-Jan-2016 18:19:29 GMT',
    },
    {
        string => 'name=Gonzo; path=/tmp/foo; path=/tmp/bar',
        name => 'name',
        fields => {
            'value' => 'Gonzo',
            'path' => '/tmp/foo',
        },
        result => 'name=Gonzo; path=/tmp/foo',
    },
);

exit main();

sub main {
    test_crush_cookie();
    test_bake_cookie();

    done_testing();
    return 0;
}

sub test_crush_cookie {
    for my $cookie (@cookie_list) {
        my $crushed = crush_cookie($cookie->{string});
        for my $key (keys %$crushed) {
            my $k = $key eq $cookie->{name} ? 'value' : $key;
            my $v = $key eq 'expires' ? $cookie->{expires} : $cookie->{fields}{$k};
            is($crushed->{$key}, $v, $key);
        }
    }
}

sub test_bake_cookie {
    for my $cookie (@cookie_list) {
        my $c = _sort_cookie(bake_cookie($cookie->{name}, $cookie->{fields}));
        my $result = $cookie->{result} // _sort_cookie($cookie->{string});
        is($c, $result, $cookie->{name});
    }
}

sub _sort_cookie {
    my ($cookie) = @_;

    my $name;
    my $value;
    my %data;
    my $first = 1;
    for my $pair (split(/;[ \t]*/, $cookie)) {
        my ($k, $v) = split('=', $pair);
        if ($first) {
            $name = $k;
            $value = $v;
            $first = 0;
            next;
        }
        $data{$k} = $v;
    }

    $cookie = sprintf("%s=%s", $name, $value);
    for my $k (sort keys %data) {
        $cookie .= sprintf("; %s=%s", $k, $data{$k});
    }

    return $cookie;
}