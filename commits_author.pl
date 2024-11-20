use strict;
use warnings;


# Print statistics for one "author"
sub print_stats {
    my $author = shift;
    my $more_ref = shift;
    my $less_ref = shift; 
    my $file_ref = shift; 
    my $commits_ref = shift; 
    my $first_ref = shift; 
    my $last_ref = shift;

    my %more = %$more_ref;
    my %less = %$less_ref; 
    my %file = %$file_ref; 
    my %commits = %$commits_ref; 
    my %first = %$first_ref; 
    my %last = %$last_ref;

    print "\t$author:\n";
        
    if ($more{"total"} > 0) {
        my $more_author = 0;
        if (defined $more{$author}) { $more_author = $more{$author}; }
        printf "\t  insertions:    %d\t(%.0f%%)\n", $more_author, ($more_author / $more{"total"} * 100);
    }

    if ($less{"total"} > 0) {
        my $less_author = 0;
        if (defined $less{$author}) { $less_author = $less{$author}; }
        printf "\t  deletions:     %d\t(%.0f%%)\n", $less_author, ($less_author / $less{"total"} * 100);
    }

    if ($file{"total"} > 0) {
        my $file_author = 0;
        if (defined $file{$author}) { $file_author = $file{$author}; }
        printf "\t  files:         %d\t(%.0f%%)\n", $file_author, ($file_author / $file{"total"} * 100);
    }

    if ($commits{"total"} > 0) {
        my $commits_author = 0;
        if (defined $commits{$author}) { $commits_author = $commits{$author}; }
        printf "\t  commits:       %d\t(%.0f%%)\n", $commits_author, ($commits_author / $commits{"total"} * 100);
    }

    if (defined $first{$author}) {
        my $more_author = 0;
        if (defined $more{$author}) { $more_author = $more{$author}; }
        my $less_author = 0;
        if (defined $less{$author}) { $less_author = $less{$author}; }
            
        if (($more{"total"} + $less{"total"}) * 100 > 0) {
            printf "\t  lines changed: %d\t(%.0f%%)\n", $more_author + $less_author, (($more_author + $less_author) / ($more{"total"} + $less{"total"}) * 100);
        } else {
            printf "\t  lines changed: %d\t(0%%)\n", ($more_author + $less_author);
        }

        printf "\t  first commit:  %s\n", $first{$author};
        printf "\t  last commit:   %s\n", $last{$author};
    }

    print "\n";
}

sub git_stats {
    my $git_log = `git -c log.showSignature=false log --branches --remotes --tags --decorate --numstat --use-mailmap --pretty="format:commit %H%nAuthor: %aN <%aE>%nDate:   %ad%n%n%w(0,4,4)%B%n"`;

    # Statistics
    my %commits;
    my %more;
    my %less;
    my %file;
    my %first;
    my %last;

    # Process the git log
    my $author;
    my $line_count = 0;
    foreach my $line (split("\n", $git_log)) {
        $line_count++;

        if ($line =~ /^Author:/) {
            $author = substr($line, 8); # Remove "Author: "
            $commits{$author} += 1;
            $commits{"total"} += 1;
        }
        elsif ($line =~ /^Date:/) {
            my $date = substr($line, 6); # Remove "Date: "
            $last{$author} = $date if !$first{$author};
            $first{$author} = $date;
        }
        elsif ($line =~ /^[0-9]/) {
            my ($insertions, $deletions, $filename) = split(/\s+/, $line);

            # Update statistics 
            $more{$author} += $insertions;
            $less{$author} += $deletions;
            $file{$author} += 1;

            $more{"total"} += $insertions;
            $less{"total"} += $deletions;
            $file{"total"} += 1;
        }
    }

    # Print stats per "author"
    foreach my $author (keys %commits) {
        next if $author eq "total"; 
        print_stats($author, \%more, \%less, \%file, \%commits, \%first, \%last);
    }

    # Print total stats
    print_stats("total", \%more, \%less, \%file, \%commits, \%first, \%last);
}


# ----- 
git_stats();
