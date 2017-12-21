#!/usr/bin/perl 

use 5.20.0;

use strict;
use warnings;

use Dash::Docset::Generator;
use Text::MultiMarkdown qw/ markdown /;
use Path::Tiny;
use Web::Query::LibXML;
use List::Util qw/ pairs /;

use experimental qw/ smartmatch /;

my $docset = Dash::Docset::Generator->new( 
    name => "JSON Schema Validation",
    platform_family => 'json-schema-validation',
    output_dir => './dest',
    homepage => 'http://json-schema.org/latest/json-schema-validation.html',
);

my $index = new_doc( path('src/json-schema-validation.html')->slurp );

$index->find('head style')->each(sub{
        #  path('style.css')->spew($_->html);
        $docset->add_css( 'style.css' );
        $_->detach;
});

my %files = ( 'index.html' => $index );

$index->find('h1')->each(sub{
    return unless $_->attr('id') =~ /([67])\.\d+\.\d+/;
    my $type = $1 == 6 ? 'Keyword' : 'Type';
    my $anchor = $_->find('a');
    my $keyword = $anchor->next->text =~ s/^\s+|\s+$//gr;
    $anchor->attr( 'docset-type' => $type );
    $anchor->attr( 'docset-name' => $keyword );
});

$docset->add_doc( $_->[0], $_->[1] ) for pairs %files;

$docset->generate;

sub new_doc {
    my $inner = shift;
    wq( "<html><head/><body>$inner</body></html>" );
}

