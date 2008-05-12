package PDF::GetImages;
use strict;
use File::Which 'which';
use Carp;
require Exporter;
use vars qw(@EXPORT_OK @ISA $WHICH_CONVERT $WHICH_PDFIMAGES $VERSION $DEBUG);
@ISA = qw(Exporter);
@EXPORT_OK = qw(pdfimages);
$VERSION = sprintf "%d.%02d", q$Revision: 1.10 $ =~ /(\d+)/g;

$PDF::GetImages::FORCE_JPG=0;

$WHICH_CONVERT = which('convert');
$WHICH_PDFIMAGES = which('pdfimages')
   or croak( " is pdfimages (xpdf) installed? Cant get which() pdfimages");


sub debug {
   my $m = shift; 
   $m||=''; 
   $DEBUG or return 1; 
   print STDERR " # PDF::GetImages # $m\n"; 
   return 1; 
}


sub pdfimages {
	my ($_abs_pdf,$_dir_out) = @_;
   defined $_abs_pdf or croak('missing argument');

   require Cwd;
   my $cwd = Cwd::cwd();

   my $abs_pdf = Cwd::abs_path($_abs_pdf)
      or croak("can't resolve location of $_abs_pdf");
   
   -f $abs_pdf or carp("$abs_pdf not on disk.") and return [];

   $abs_pdf=~/(.+)\/([^\/]+)(\.pdf)$/i
      or carp("$abs_pdf not '.pdf'?")
      and return [];

   my ($abs_loc,$filename,$filename_only) = ($1,"$2$3",$2);
   
   my $_copied=0;
   if( $_dir_out ){
      my $dir_out = Cwd::abs_path($_dir_out) or croak("cant resolve $_dir_out");

      if ($dir_out ne $abs_loc){
          -d $dir_out or croak("Dir out arg is not a dir $dir_out");

         require File::Copy;
         File::Copy::copy($abs_pdf,"$dir_out/$filename") 
            or croak("you specified dir out $dir_out, but we cant copy $abs_pdf there, $!");
         $_copied=1;
         $abs_loc=$dir_out;
         $abs_pdf = "$dir_out/$filename";
         debug("switched to use pdf copy $abs_pdf");
      }
   }

	

	chdir($abs_loc) 
      or carp("pdfimages() cannot chdir into $abs_loc.") 
      and return [];	

   my @args=($WHICH_PDFIMAGES, $abs_pdf,$filename_only);
   debug("args [@args]");   
	system(@args) == 0
		or croak("system [@args] bad.. $?");	

   if($_copied){
      unlink $abs_pdf;
   }

	opendir(DIR, $abs_loc) or die($!);
	my @pagefiles = map { "$abs_loc/$_" } sort grep { /$filename_only.+\.p.m$/i } readdir DIR;
	closedir DIR;

   chdir ($cwd);
   #	chdir($cwd); # go back to same place we started ??

	unless(scalar @pagefiles){
		carp("pdfimages() no output from pdfimages for [$abs_pdf]? [$abs_loc]");
		return [];
	}



   if($PDF::GetImages::FORCE_JPG){
      debug("FORCE_JPG is on");
      @pagefiles = _convert_all_to_jpg(@pagefiles);
   }
	
	return \@pagefiles;
}

sub _convert_all_to_jpg {
   my @files = map { _convert_to_jpg($_) } @_;
   return @files;
}


sub _convert_to_jpg {
   my $_abs = shift;
   my $_out = $_abs;
   $_out=~s/\.\w{1,5}$/\.jpg/ 
      or warn("cant match etx on $_abs") and return;
   require File::Which;
   system($WHICH_CONVERT, $_abs, $_out) ==0 or  die($?);
   unlink $_abs;
   debug(" converted to $_out");
   return $_out;
}


1;

__END__

=pod

=head1 NAME

PDF::GetImages - get images from pdf document

=head1 SYNOPSIS

	use PDF::GetImages 'pdfimages';

	my $images = pdfimages('/abs/path/tofile.pdf');

=head1 DESCRIPTION

Get images out of a pdf document. 
This code makes use of pdfimages which is part
of xpdf. 
In case CAM::PDF scripts don't work for you, you may want to try using 
this to extract images from PDF documents.
See L<DEPENDENCIES AND REQUIREMENTS>

=head1 pdfimages()

argument is abs path to pdf doc
optional argument is a dir to which to send images extracted
returns abs paths to images extracted
images are extracted by default to same dir pdf is in

If this is not a pdf, the file does not exist, or no images 
are extracted, warns and returns empty array ref []

=head1 DEBUG

   $PDF::GetImages::DEBUG = 1;

=head1 FORCE_JPG

By default pdfimages will spit out pbm or ppm image format files which are huge and unruly.
If you want to make sure the images output are jpg..

   $PDF::GetImages::FORCE_JPG= 1 ;

You must have imagemagick convert installed for this to work.

=head1 DEPENDENCIES AND REQUIREMENTS

This module requires Unix family operating system to be installed. 
You must have xpdf package and Image Magick convert installed.
Presently we are using cli pdfgetimages. You must have xpdf installed on your system.

=head1 AUTHOR

Leo Charre leocharre at cpan dot org

=head1 COPYRIGHT

Copyright (c) 2008 Leo Charre. All rights reserved.

=head1 LICENSE

This package is free software; you can redistribute it and/or modify it under the same terms as Perl itself, i.e., under the terms of the "Artistic License" or the "GNU General Public License".

=head1 DISCLAIMER

This package is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the "GNU General Public License" for more details.

=head1 SEE ALSO

http://www.imagemagick.org/, 
xpdf, 
L<CAM::PDF>

=cut
