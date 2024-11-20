use strict;
use warnings;

my @git_log = `git -c log.showSignature=false log --branches --remotes --tags --numstat --use-mailmap --pretty=fuller --no-color --date=short --decorate=full`;

my %commit; 
my $total = 0;
for (@git_log) {
    chomp;
    my $line = $_;
    if($line =~ /^CommitDate:([ \t]*)(.*)/) {
        my $date = $2;
        if($date =~ /^(\d\d\d\d)-(\d\d)/) {
            my $period = "$1/$2";
            $commit{$period}++;
            $total++;
        }
    }
}

print "Commits per month:\n";
print "\tMonth\tSum\n";
for my $y (sort keys %commit) {
    my $s = '|';
    my $count = 0; 
    if (defined ($commit{$y})) { $count = $commit{$y}; }
    if ($total > 0) {
        my $percent = int(($count / $total) * 100 / 1.25);
        for (my $i = 0; $i < $percent; ++$i) {
            $s .= "*";
        }
    }
    
    printf "\t%s\t%d\t%s\n", $y, $commit{$y}, $s;
}
