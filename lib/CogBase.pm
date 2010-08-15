package CogBase;
use CogBase::Base -base;

use 5.008003;
our $VERSION = '0.11';

1;

=encoding utf-8

=head1 NAME

CogBase - The Universally Unique Data Store

=head1 SYNOPSIS

    > cogbase --help

=head1 STATUS

This is an early release. CogBase is still being architected heavily.
Please don't walk away..

RUN!!!

=head1 DESCRIPTION

This module installs a command line utility called C<cogbase> for
interfacing with a cogbase.

=head1 WHAT IS COGBASE?

CogBase is database of sorts. It is best to describe it by listing its
properties:

    * CogBase is a defined way to store and access data.
    * CogBase is not tied to an implementation.
    * A CogBase stores data as Nodes
    * Every node has a UUID. Like: HCP4TKU4MJI7IS2DZTFFLXKB7M
    * Every node id has an eternally unique short id. Like HCP4
    * Nodes have revisions.
    * Revisions are immutable. Once saved they never change.
    * Each revision has a revision number 1-n. Like 01.
    * Revision numbers are usually written with a leading 0.
    * HCP4 is the tracking id. It refers to the latest revision.
    * HCP407 is a reference to the 7th revision of HCP4.
    * Every node has a Type.
    * Every type has a description, called a Schema.
    * Schemas are saved as nodes in the cogbase.
    * Schema nodes are of type Schema.
    * You may not save a node of type Foo, without first saving a Schema node describing type Foo.
    * Nodes are a mapping of string keys to typed values.
    * Values can be plain text or pointers to other node ids.
    * Values can be defined as optional or required, and scalar or list of the given type.
    * CogBase can be fully accessed through a REST interface.
    * ... more later ...

=head1 AUTHOR

Ingy döt Net <ingy@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2010. Ingy döt Net.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
