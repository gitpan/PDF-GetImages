use Test::Simple 'no_plan';

use File::Which;

ok( File::Which::which('pdfimages'), 'File::Which::which() can find path to pdfimages')
   or warn("cannot install PDF::GetImages")
   and warn("pdfimages not found via File::Which::which(), is xpdf installed?");


