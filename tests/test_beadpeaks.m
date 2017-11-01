function test_suite = test_beadpeaks
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

%%%%%%%%%%%%
% Note: test_colormodel tests the one and many bead cast; we just need to test two and special cases

function [CM, settings] = setupRedPeakCM()

stem0312 = '../TASBEFlowAnalytics-Tutorial/example_controls/2012-03-12_';

beadfile = [stem0312 'Beads_P3.fcs'];
blankfile = [stem0312 'blank_P3.fcs'];

% Create one channel / colorfile pair for each color
channels = {}; colorfiles = {};
channels{1} = Channel('PE-Tx-Red-YG-A', 561, 610, 20);
channels{1} = setPrintName(channels{1}, 'mKate');
channels{1} = setLineSpec(channels{1}, 'r');
colorfiles{1} = [stem0312 'mkate_P3.fcs'];

% Multi-color controls are used for converting other colors into MEFL units
% Any channel without a control mapping it to MEFL will be left in arbirary units.
colorpairfiles = {};

CM = ColorModel(beadfile, blankfile, channels, colorfiles, colorpairfiles);
CM=set_bead_plot(CM, 2); % 2 = detailed plots; 1 = minimal plot; 0 = no plot

CM=set_bead_model(CM,'SpheroTech RCP-30-5A'); % Entry from BeadCatalog.xls matching your beads
CM=set_bead_batch(CM,'Lot AA01, AA02, AA03, AA04, AB01, AB02, AC01, GAA01-R'); % Entry from BeadCatalog.xls containing your lot
CM=set_bead_channel(CM,'PE-TR');

CM=set_ERF_channel_name(CM, 'PE-Tx-Red-YG-A');

settings = TASBESettings();
settings = setSetting(settings, 'path', '/tmp/plots');


function test_twopeaks

[CM, settings] = setupRedPeakCM();
% Ignore all bead data below 10^[bead_min] as being too "smeared" with noise
CM=set_bead_min(CM, 2.7);
CM=set_bead_peak_threshold(CM, 600);
% Execute and save the model
CM=resolve(CM, settings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check results in CM:
CMS = struct(CM);
UT = struct(CMS.unit_translation);
assertElementsAlmostEqual(UT.k_MEFL,        64.5559,  'relative', 1e-2);
assertElementsAlmostEqual(UT.first_peak,    7);
assertElementsAlmostEqual(UT.fit_error,     0.00,   'absolute', 0.002);
assertElementsAlmostEqual(UT.peak_sets{1},  [855.4849 2.4685e+03], 'relative', 1e-2);


function test_toomanypeaks

[CM, settings] = setupRedPeakCM();
 % set threshold and min too low so that it should sweep up lots of noise, get too many peaks
CM=set_bead_min(CM, 1);
CM=set_bead_peak_threshold(CM, 300);
% Execute and save the model
CM=resolve(CM, settings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check results in CM:
CMS = struct(CM);
UT = struct(CMS.unit_translation);
assertElementsAlmostEqual(UT.k_MEFL,        11.2510,  'relative', 1e-2);
assertElementsAlmostEqual(UT.first_peak,    2);
assertElementsAlmostEqual(UT.fit_error,     0.4658,   'absolute', 0.002);
expected_peaks = 1e3 .* [0.0104    0.0114    0.0123    0.0138    0.0175    0.0372    0.1095    0.2280    0.8523 1.3515    2.4685    3.8884];
assertElementsAlmostEqual(UT.peak_sets{1},  expected_peaks, 'absolute', 1);


function test_nopeaks

[CM, settings] = setupRedPeakCM();
CM=set_bead_peak_threshold(CM, 1e7); % set too high to see anything
% Execute and save the model
CM=resolve(CM, settings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check results in CM:
CMS = struct(CM);
UT = struct(CMS.unit_translation);
assertElementsAlmostEqual(UT.k_MEFL,        1);
assertElementsAlmostEqual(UT.first_peak,    NaN);
assertTrue(isinf(UT.fit_error));
assertTrue(isempty(UT.peak_sets{1}));
