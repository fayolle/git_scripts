use strict;
use warnings;

my @git_log = `git -c log.showSignature=false log --branches --remotes --use-mailmap --numstat --reverse --pretty=fuller --no-color --date=format:%A  | grep "^CommitDate:"`;

my %commits; 
my $total;
for(@git_log) {
    chomp;
    my $line = $_;
    if(/^CommitDate: (.*)/) {
        $commits{"$1"}++;
        $total++;
    }
}

my @days = ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');
my @days_short = ('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun');

print "Commits per weekday:\n";
print "\tDay\tSum\tPer\n";
for my $d (0 .. 6) {
    my $commits_d = 0; 
    my $s = '|';
    if (defined $commits{$days[$d]}) { $commits_d = $commits{$days[$d]}; }
    if ($total > 0) {
        my $percent = int(($commits_d / $total) * 100 / 1.25); 
        for (my $i = 0; $i < $percent; ++$i) {
            $s .= "*";
        }        
    }
    printf "\t%s\t%d\t%.1f%%\t%s\n", $days_short[$d], $commits_d, $commits_d * 100/ $total, $s;
}
