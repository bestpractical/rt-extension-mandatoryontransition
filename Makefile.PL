use inc::Module::Install;


RTx 'RT-Extension-MandatoryOnTransition';
all_from 'lib/RT/Extension/MandatoryOnTransition.pm';
readme_from 'lib/RT/Extension/MandatoryOnTransition.pm';
license  'gplv2';

requires_rt('4.0.0');

sign;
WriteAll;
