#!/usr/bin/perl -w
# Copyright (C) 2015  Dean Serenevy
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, version 3, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
use strict; use warnings; use 5.020;

use Getopt::Long qw/:config bundling/;
use Hash::Util qw/ lock_keys /;
our $VERSION = '0.1.0';# Created: 2015-12-07

our %OPT = ( strip_backslash => 0 );
our @OPT_SPEC =
qw/ help|h version noact|no-act|dry-run DEBUG
    strip_backslash|strip-backslash|strip-bs
  /;
sub USAGE { <<"__USAGE__" };
usage: $_[0] [options]

OPTIONS

 --strip-backslash   exclude leading backslash from compose key commands
__USAGE__

use Text::Balanced qw/extract_multiple gen_delimited_pat/;
use Encode;

my %CHAR_MAP = (
    ' '  => 'space',
    '!'  => 'exclam',
    '"'  => 'quotedbl',
    '#'  => 'numbersign',
    '$'  => 'dollar',
    '%'  => 'percent',
    '&'  => 'ampersand',
    "'"  => 'apostrophe',
    '('  => 'parenleft',
    ')'  => 'parenright',
    '*'  => 'asterisk',
    '+'  => 'plus',
    ','  => 'comma',
    '-'  => 'minus',
    '.'  => 'period',
    '/'  => 'slash',
    ':'  => 'colon',
    ';'  => 'semicolon',
    '<'  => 'less',
    '='  => 'equal',
    '>'  => 'greater',
    '?'  => 'question',
    '@'  => 'at',
    '['  => 'bracketleft',
    '\\' => 'backslash',
    ']'  => 'bracketright',
    '^'  => 'asciicircum',
    '_'  => 'underscore',
    '`'  => 'grave',
    '{'  => 'braceleft',
    '|'  => 'bar',
    '}'  => 'braceright',
    '~'  => 'asciitilde',
);

get_options( \%OPT, @OPT_SPEC );
MAIN(\%OPT, @ARGV);


sub PARSE_ERROR {
    my ($msg, @tok) = @_;
    die "Parse error on line $. $msg at '".join("",@tok)."'\n";
}

sub MAIN {
    my ($opt, $file) = @_;
    open my $F, "<:encoding(UTF-8)", $file or die "Error reading $file: $!";

    my @TOKENS = ( qr/\(/, qr/\)/, qr/;/, qr/\?(?:\\.|.)/, gen_delimited_pat('"') );

    say "# We make no attempt to avoid conflicts, but you may wish to uncomment:";
    say "# include \"%L\"\n";

    my $past_head;
  LINE:
    while (defined(my $line = <$F>)) {
        next unless ($past_head ||= $line =~ s/\(trans\b//);
        my @tok = extract_multiple($line, \@TOKENS);
        while (@tok) {
            my $tok = shift @tok;
            if ($tok =~ /^\s+$/) {
                next;
            }
            elsif ($tok eq ';') {
                next LINE;
            }
            elsif ($tok eq '(') {
                my ($cmd, $val);

                PARSE_ERROR "expected quoted command", @tok unless $tok[0] =~ /^"(.+)"$/;
                $cmd = $1; shift @tok;
                PARSE_ERROR "expected whitespace",     @tok unless $tok[0] =~ /^\s+$/;
                shift @tok;

                if ($tok[0] =~ /^\?\\?(.)$/) {
                    $val = sprintf '"%s"  U%04X', $1, ord($1);
                    shift @tok;
                } elsif ($tok[0] =~ /^".+"$/) {
                    $val = $tok[0];
                    shift @tok;
                } else {
                    PARSE_ERROR "expected replacement", @tok;
                }

                shift @tok while $tok[0] =~ /^\s+$/;
                PARSE_ERROR "expected close paren",    @tok unless $tok[0] eq ')';
                shift @tok;

                $cmd =~ s/\\(.)/$1/g;
                $cmd =~ s/^\\// if $OPT{strip_backslash};

                my @cmd = ("<Multi_key>");
                push @cmd, "<".($CHAR_MAP{$_} // $_).">" for split //, $cmd;
                say encode("UTF-8", "@cmd : $val   # $cmd");
            }
            elsif ($tok eq ')') {
                $past_head = 0;
                next LINE;
            }
            else {
                PARSE_ERROR "unknown token '$tok'", @tok;
            }
        }
    }
}


sub get_options {
    my $OPT = shift;
    GetOptions $OPT, @_ or usage(1);
    usage() if $$OPT{help} || $$OPT{version};
    lock_keys(%$OPT, keys %$OPT, map /^(\w+)/, @_);
}

sub usage {
    my $status = (@_ && $_[0] =~ /^\d+$/) ? shift(@_) : 0+@_;
    print @_, "\n" if @_;
    require File::Spec; my $exe = (File::Spec->splitpath($0))[2];
    $OPT{$_} = $OPT{$_} ? "enabled" : "disabled" for map /^(\w+).*!/, @OPT_SPEC;
    print $OPT{version} ? "$exe version $VERSION\n" : USAGE($exe);
    exit $status;
}
