package JS::jQuery::Loader::Source::URI;

use Moose;
extends qw/JS::jQuery::Loader::Source/;
use JS::jQuery::Loader::Carp;

use JS::jQuery::Loader::Location;
use JS::jQuery::Loader::Template;

has location => qw/is ro/, handles => [qw/recalculate uri/];
has template => qw/is ro required 1 lazy 1 isa JS::jQuery::Loader::Template/, default => sub { return JS::jQuery::Loader::Template->new };

sub BUILD {
    my $self = shift;
    my $given = shift;

    my $location = $given->{location};
    $self->{location} = do {

        croak "Wasn't given a URI" unless $given->{uri};

        JS::jQuery::Loader::Location->new(template => $self->template, uri => $given->{uri}, location => $location);

    }
    unless blessed $location;
}

1;
__END__

has pattern => qw/is rw/;
has uri => qw/is rw required 1 lazy 1/, default => sub {
    my $self = shift;
    return $self->recalculate;
};

sub BUILD {
    my $self = shift;
    my $given = shift;

    croak "Wasn't given a URI" unless $given->{uri};

    $self->uri($given->{uri});
}

sub recalculate {
    my $self = shift;

    my $uri = $self->template->process($self->pattern);
    return $self->{uri} = URI->new($uri);
}

around uri => sub {
    my $inner = shift;
    my $self = shift;

    return $self->$inner() unless @_;
    $self->pattern(@_);
    return $self->recalculate;
};

1;
