#!/usr/bin/perl
use strict;
use Image::Magick;
use File::Glob ':glob';

if (scalar(@ARGV) != 4) { 
  die "perl $0 <home team> <away team> <background> <bottom row string>";
}

my $font = "Helvetica-Bold";
my $logo_width_perc = 0.25;
my $bottom_label_perc = 0.15;

my $home = $ARGV[0];
my $away = $ARGV[1];
my $bg = $ARGV[2];
my $bottom_text = $ARGV[3];
my $x;

my @home_imgs = bsd_glob("img/".$home.".*", GLOB_NOCASE);
if (scalar(@home_imgs) != 1) {
  die "Couldn't find one exact image for $home in img/";
}

my $home_img=Image::Magick->new();
$x=$home_img->ReadImage($home_imgs[0]);
warn "$x" if "$x";

my @away_imgs = bsd_glob("img/".$away.".*", GLOB_NOCASE);
if (scalar(@away_imgs) != 1) {
  die "Couldn't find one exact image for $away in img/";
}

my $away_img=Image::Magick->new();
$x=$away_img->ReadImage($away_imgs[0]);
warn "$x" if "$x";

my @bg_imgs = bsd_glob("img/".$bg.".*", GLOB_NOCASE);
if (scalar(@bg_imgs) != 1) {
  die "couldn't find one exact image for $bg in img/";
}

my $bg_img=Image::Magick->new();
$x=$bg_img->ReadImage($bg_imgs[0]);
warn "$x" if "$x";

my $home_img_scale = ($logo_width_perc*$bg_img->Get('columns'))/$home_img->Get('columns'); 
$home_img->Scale("".(100.0*$home_img_scale)."%");
my $away_img_scale = ($logo_width_perc*$bg_img->Get('columns'))/$away_img->Get('columns'); 
$away_img->Scale("".(100.0*$away_img_scale)."%");

my $home_x = 1*$bg_img->Get('columns')/4-$home_img->Get('columns')/2; 
my $home_y = (1.0-$bottom_label_perc)*$bg_img->Get('rows')/2-$home_img->Get('rows')/2; 
$bg_img->Composite(image=>$home_img,compose=>'over',geometry=>'+'.$home_x.'+'.$home_y);
my $away_x = 3*$bg_img->Get('columns')/4-$away_img->Get('columns')/2; 
my $away_y = (1.0-$bottom_label_perc)*$bg_img->Get('rows')/2-$away_img->Get('rows')/2; 
$bg_img->Composite(image=>$away_img,compose=>'over',geometry=>'+'.$away_x.'+'.$away_y);

my $bottom_label_img = Image::Magick->new;
$bottom_label_img->Set(size=>$bg_img->Get('columns').'x'.($bottom_label_perc*$bg_img->Get('columns')));
$bottom_label_img->ReadImage('xc:black');

my $text = $home." vs ".$away."\n".$bottom_text;
$x = $bottom_label_img->Annotate(pointsize=>40, fill=>'#fde100', text=>$text, gravity=>"center", font=>$font, "interline-spacing"=>20.0);
warn "$x" if "$x";
$bg_img->Composite(image=>$bottom_label_img,compose=>'over',geometry=>'+0+'.($bg_img->Get('rows')-$bottom_label_img->Get('rows')));

$bg_img->Clamp();

my $out_fname = $home."_".$away.".jpg";
$out_fname =~ s/\s+/_/g;
$bg_img->Write($out_fname);
$bg_img->Write('win:');