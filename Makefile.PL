use lib inc; #__assertexe__#
use Devel::AssertEXE qw(convert pdfimages xpdf); #__assertexe__#
use Devel::AssertOS qw(Unix);

use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'PDF::GetImages',
    VERSION_FROM      => 'lib/PDF/GetImages.pm', # finds $VERSION
    PREREQ_PM         => {
                'File::Path' => 0,
					 'File::Copy' => 0,
					 'File::Which' => 0,
					 'Carp' => 0,

		          'Image::Magick' => 0,		

					 },
   # EXE_FILES               => [qw(bin/pdf2ocr bin/ocr bin/pdfgetext bin/pdf2ocrturntotext)],
);
