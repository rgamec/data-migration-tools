#!/usr/bin/perl -w
# Webscraping tool to retrieve all questions from j-archive.com
use strict;
use DBI;

require LWP::UserAgent;
require HTTP::Cookies;

# Configuring the LWP object
my $ua = LWP::UserAgent->new;
$ua->timeout(10); 
$ua->env_proxy;
$ua->agent('Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13 GTB7.1');

# Enter your own database auth here
my $dbh = DBI->connect("DBI:mysql:database=jeopardy_archive;host=localhost",
                         "username", "password",
                         {'RaiseError' => 1});

print "Jeopardy Questions Archive Downloader\n";

my $arguments = $#ARGV + 1;
if ($arguments != 1){
	print "Usage: jeopardy.pl [ID]\n";
	exit;
}

# For each of the 4563 shows currently known, run retrieve_game()
my $loopcount = 1;
for (my $loopcount = 1; $loopcount < 4563; $loopcount++)
{
	print "Fetching game $loopcount\n";
	&retrieve_game($loopcount);
}

# Routine for extracting a single show's questions and answers
sub retrieve_game
{
	my ($game_id) = @_;
	my @categories;
	my $game_page = $ua->get("http://www.j-archive.com/showgame.php?game_id=$game_id");

	print "Attempting to retrieve game with ID $game_id\n";

	if ($game_page->is_success) {
		my $game_page_source = $game_page->decoded_content; 
	    #print $game_page->decoded_content;  
	    # Perform a regex search on the resulting page.

	    if ($game_page_source =~ m|<div id="game_title"><h1>(.*?)</h1>|g) {

	    		my $game_data_header = $1;
	    		print "Game retrieved successfully: $game_data_header\n";

	    		# Retrieving official game ID and game date
	    		my $gamedate = "";
	    		my $official_game_ID = "";
	    		while ($game_data_header =~ m|Show \#(.*?) - (.*?)$|gs) {
	    			$official_game_ID = $1;
	    			$gamedate = $2;
	    			my %mon2num = qw(
					    january 1  february 2  march 3  april 4  may 5  june 6
					    july 7  august 8  september 9  october 10 november 11 december 12
					);
	    			while ($gamedate =~ m|(.*?), (.*?) (\d+?), (\d+?)$|gs){
	    				my $game_year = $4;
	    				my $game_month = sprintf("%02d", $mon2num{lc $2});
	    				my $game_day = sprintf("%02d", $3);
	    				$gamedate = "$game_year-$game_month-$game_day";
	    			}

	    		}

	    		#Retrieving category names
	    		print "Categories: ";
	    		my $count = 0;
	    		while ($game_page_source =~ m|<td class="category_name">(.*?)</td>|gs) {
	    			my $category_title = $1;
	    			$category_title =~ s|&amp;|&|gs;
	    			print "$category_title, ";
	    			$categories[$count] = $category_title;
	    			$count++;
	    		}
	    		print "\n";


	    		# Retrieving actual questions from the first round
	    		while ($game_page_source =~ m|<div onmouseover="toggle\('clue_J_(\d+)_\d+', 'clue_J_\d+_\d+_stuck', '&lt;em class=&quot;correct_response&quot;&gt;(.*?)&lt;/em(.*?) onmouseout="toggle\('clue_J_\d+_\d+', 'clue_J_\d+_\d+_stuck', '(.*?)'\)" onclick="togglestick\('clue_J_\d+_\d+_stuck'\)">|gs) {

	    			my $question = $4;
	    			my $answer = $2;
	    			my $category = $1;

	    			$question =~ s|&quot;|"|gs;
	    			$question =~ s|\\'|'|gs;
	    			$question =~ s|&amp;|&|gs;

	    			$answer =~ s|&quot;|"|gs;
	    			$answer =~ s|\\'|'|gs;
	    			$answer =~ s|&amp;|&|gs;
	    			$answer =~ s|&lt;i&gt;||gs;
	    			$answer =~ s|&lt;\/i&gt;||gs;

	    			print "Question: $question\n";
	    			print "Answer: $answer\n";
	    			#print "Category: $category\n";
	    			print "Game ID: $game_id\n";
	    			print "Archive ID: $official_game_ID\n";
	    			print "Game date: $gamedate\n";
	    			print "Category: $categories[$category-1]\n\n";

	    			# Insert into database
	    			$dbh->do("INSERT INTO jeopardy_questions VALUES (?, ?, ?, ?, ?, ?, ?)", undef, undef, $question, $answer, $categories[$category-1], $game_id, $official_game_ID, $gamedate);
	    		}

	    		# Retrieving actual questions from the second round
	    		while ($game_page_source =~ m|<div onmouseover="toggle\('clue_DJ_(\d+)_\d+', 'clue_DJ_\d+_\d+_stuck', '&lt;em class=&quot;correct_response&quot;&gt;(.*?)&lt;/em(.*?) onmouseout="toggle\('clue_DJ_\d+_\d+', 'clue_DJ_\d+_\d+_stuck', '(.*?)'\)" onclick="togglestick\('clue_DJ_\d+_\d+_stuck'\)">|gs) {
	    			my $question = $4;
	    			my $answer = $2;
	    			my $category = $1;

	    			$question =~ s|&quot;|"|gs;
	    			$question =~ s|\\'|'|gs;
	    			$question =~ s|&amp;|&|gs;

	    			$answer =~ s|&quot;|"|gs;
	    			$answer =~ s|\\'|'|gs;
	    			$answer =~ s|&amp;|&|gs;
	    			$answer =~ s|&lt;i&gt;||gs;
	    			$answer =~ s|&lt;\/i&gt;||gs;


	    			print "Question: $question\n";
	    			print "Answer: $answer\n";
	    			#print "Category: $category\n";
	    			print "Game ID: $game_id\n";
	    			print "Archive ID: $official_game_ID\n";
	    			print "Game date: $gamedate\n";
	    			print "Category: $categories[$category+5]\n\n";

	    			# Insert into database
	    			$dbh->do("INSERT INTO jeopardy_questions VALUES (?, ?, ?, ?, ?, ?, ?)", undef, undef,$question, $answer, $categories[$category+5], $game_id, $official_game_ID, $gamedate);
	    		}

	    		# Let's fetch final round question too...
	    		 while ($game_page_source =~ m|correct_response\\&quot;&gt;(.*?)&lt;/em&gt;'\)" onmouseout="toggle\('clue_FJ', 'clue_FJ_stuck', '(.*?)'\)" onclick="togglestick\('clue_FJ_stuck'\)">|gs) {
	    			my $question = $2;
	    			my $answer = $1;

	    			$question =~ s|&quot;|"|gs;
	    			$question =~ s|\\'|'|gs;
	    			$question =~ s|&amp;|&|gs;

	    			$answer =~ s|&quot;|"|gs;
	    			$answer =~ s|\\'|'|gs;
	    			$answer =~ s|&amp;|&|gs;
	    			$answer =~ s|&lt;i&gt;||gs;
	    			$answer =~ s|&lt;\/i&gt;||gs;

	    			print "Final Question: $question\n";
	    			print "Answer: $answer\n";
	    			#print "Category: $category\n";
	    			print "Game ID: $game_id\n";
	    			print "Archive ID: $official_game_ID\n";
	    			print "Game date: $gamedate\n";
	    			print "Category: $categories[12]\n\n";

	    			# Insert into database
	    			$dbh->do("INSERT INTO jeopardy_questions VALUES (?, ?, ?, ?, ?, ?, ?)", undef, undef, $question, $answer, $categories[12], $game_id, $official_game_ID, $gamedate);
	    		}


	    } else {
	    		print "No valid game data found at this URL.\n";
	    }

	} else {

	    print "Page could not be retrieved.\n";
	    die $game_page->status_line;

	}
}

$dbh->disconnect();
