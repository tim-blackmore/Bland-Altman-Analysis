%BA1999DEMO Demonstration of:
% Bland and Altman 1999
% Measuring agreement methods in comparison studies
% http://smm.sagepub.com/content/8/2/135.abstract

%   Copyright (C) 2016 Erik Huizinga, huizinga.erik@gmail.com
%
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% fresh environment
%TODO deze sectie verwijderen
clc
clear
close all

%% display demo text
disp 'Demonstration of Bland-Altman analysis'

%% load data
% add data folder to path
pth = fileparts(mfilename('fullpath'));
addpath(fullfile(pth,'ba1999data'))

% load Table 1 (article p. 137-8)
load bpdata % systolic blood pressure (mmHG) data

n = BPData(:,1); % subject number
J = BPData(:,2:4); % three successive measurements by expert J
R = BPData(:,5:7); % three successive measurements by expert R
S = BPData(:,8:10); % three successive measurements by machine S
JName = 'Systolic BP, Observer J (mmHg)';
SName = 'Systolic BP, Machine S (mmHg)';

%% 2 Limits of agreement (article page 136)
disp 'Section 2 Limits of agreement'

% This section only considers the first observations by J and S.
J1 = J(:,1);
S1 = S(:,1);

% calculate Bland-Altman statistics
s = ba(J1,S1);

% show results
muD = s.difference.mu; % mean difference (bias)
sD = s.difference.s; % standard deviation of difference
loaD = s.difference.loa; % limits of agreement
display(muD) % article: -16.29 mmHg
display(sD) % article: 19.61 mmHg
display(loaD) % article: [-54.7, 22.1] mmHg

% exclude subjects 78 and 80 (article page number 139)
fprintf '\nExcluding subjects 78 and 80 (outliers):\n'
iEx = [78,80];
lEx = (n==78) | (n==80); % alternative: logical indices
s = ba(J1,S1, 'Exclude',iEx);

% show results
muD = s.difference.mu;
loaD = s.difference.loa;
display(muD) % article: -14.9 mmHg
% Erratum: a small error, probably a typo, exist in the original article.
% Note the difference between the muD and the article's mean difference.
% However, because the limits of agreement are the same and, of course, the
% mean difference equals the mean of the limits of agreement, thus the
% calculation here appears to be correct.
display(loaD) % article: [-43.6, 15.0] mmHg

%% 2.1 Graphical presentation of agreement (article page 140)
disp 'Section 2.1 Graphical presentation of agreement'

% If any other figures exist, the numbers below might not be correct. This
% script was written with all other figures closed.
% Figure 1 corresponds to article figure 1, figure 2 corresponds to article
% figure 2.
f1_2 = figures(2);

% Perform Bland-Altman Analysis and create both the correlation and
% mean-difference graphs.
s = ba(f1_2, J1,S1, 'XName',JName, 'YName',SName, 'PlotDefault',true);

% show results
rSMuD = s.difference.rSMu;
% Article: 0.07 (p. 140), here -0.03, so an error exists either here or in
% the article.
display(rSMuD); % Spearman rank correlation between mean and difference

% Figure 3 is equal to figure 2, but has added limits of agreement. It
% corresponds to article figure 3.
f3 = figure;

% Create the mean-difference graph and plot basic statistics, i.e. bias and
% limits of agreement.
ba(f3, J1,S1, 'XName',JName, 'YName',SName, ...
    'PlotMeanDifference',true, 'PlotStatistics','basic')

% some text output
f = [f1_2;f3];
fn = sort([f.Number]);
disp(['See also figures [' num2str(fn) '].'])

%% 2.2 Precision of the estimated limits of agreement (article page 141)
disp 'Section 2.2 Precision of the estimated limits of agreement'

clf % Clear figure 3 and recreate it with additional confidence intervals
% (not shown in article).
s = ba(f3, J1,S1, 'XName',JName, 'YName',SName, ...
    'PlotMeanDifference',true, 'PlotStatistics','extended');

% show results
muDCI = s.difference.muCI;
loaDCI = s.difference.loaCI; % confidence interval of the loa
% article loaCI (p. 142):
% [-61.9, 14.9
%  -47.5, 29.3]
display(loaDCI)
% article muDCI (p. 142): [-20.5 -12.1]
display(muDCI)

% some text output
f = f3;
fn = f.Number;
disp(['See also figure ' num2str(fn) '.'])

%% 3 Relationship between difference and magnitude (article p. 142)
disp 'Section 3 Relationship between difference and magnitude'

% load Table 2 (article p. 143)
load pvdata % plasma volume in (%) data

n = PVData(:,1);
Nadler = PVData(:,2);
Hurley = PVData(:,3);
NName = 'Plasma volume (Nadler) (%)';
HName = 'Plasma volume (Hurley) (%)';

% create figures 4a and 4b in the article
f4 = figure;
ax(1) = subplot(1,2,1);
ax(2) = subplot(1,2,2);

% The following could be accomplished with one line of code, but the
% graphs in the article are constructed a bit differently, so here we
% create the graphs accordingly, but need to do it with two separate lines.
ba(ax(1), Hurley,Nadler, 'XName',HName, 'YName',NName, ...
    'PlotCorrelation',true)
ba(ax(2), Nadler,Hurley, 'XName',NName, 'YName',HName, ...
    'PlotMeanDifference',true)
% In one line of code it would have been:
% ba(ax, Hurley,Nadler, 'PlotAll',true)
% But figure 4b has the vertical axis flipped, so this does not work.
% Note that there is significant positive Spearman rank correlation
% between difference and mean.

% some text output
fn = f4.Number;
disp(['See also figure ' num2str(fn) '.'])

%% 3.1 Logarithmic transformation (article p. 143)
disp 'Section 3.1 Logarithmic transformation'

f5 = figure;
ax(1) = subplot(1,2,1);
ax(2) = subplot(1,2,2);

% perform BAA using log transformation
ba(ax(1), Hurley,Nadler, 'XName',HName, 'YName',NName, ...
    'PlotCorrelation',true, 'Transform',@log)
s = ba(ax(2), Nadler,Hurley, 'XName',NName, 'YName',HName, ...
    'PlotMeanDifference',true, ...
    'PlotStatistics','basic', ...
    'Transform',@log);

% show results
logMuD = s.difference.mu;
display(logMuD) % article: 0.099
logLoaD = s.difference.loa;
display(logLoaD) % article: [0.056, 0.141]
logLoaDCI = s.difference.loaCI;
lowerLogLoaDCI = logLoaDCI(:,1); % lower LOA CI
display(lowerLogLoaDCI) % article [0.049, 0.064]

% backtransformation of results
muD = exp(logMuD);
display(muD) % article: 1.11
loaD = exp(logLoaD);
display(loaD) % article: [1.06, 1.15]

f6 = figure;

% Create the mean-ratio graph
ba(f6, Nadler,Hurley, 'XName',NName, 'YName',HName, ...
    'PlotMeanRatio',true, 'PlotStatistics','basic');

% some text output
f = [f5;f6];
fn = sort([f.Number]);
disp(['See also figures [' num2str(fn) '].'])

%% 3.2 A regression approach for nonuniform differences (article p. 145)
disp 'Section 3.2 A regression approach for nonuniform differences'

% load Table 3 (article p. 146)
load fcdata
Trig = FCData(:,1);
Gerber = FCData(:,2);
TName = 'Fat (g/100 ml; Trig.)';
GName = 'Fat (g/100 ml; Gerber)';

% article Figure 7 (p. 147)
f7 = figure;
ax(1) = subplot(1,2,1);
ax(2) = subplot(1,2,2);

% Perform default BAA on the data.
ba(ax(1), ...
    Gerber,Trig, 'XName',GName, 'YName',TName, ...
    'PlotCorrelation',true)
ba(ax(2), ...
    Trig,Gerber, 'XName',TName, 'YName',GName, ...
    'PlotMeanDifference',true)

% article figure 8 (p. 148)
f8 = figure;

% Perform BAA, but now plot the simple linear regression line of the
% difference on the mean instead of a constant bias. The corresponding 95%
% limits of agreement are plotted as well. In the article, the residuals of
% this regression line are not assumed to be significantly associated with 
s = ba(f8, Trig,Gerber, 'XName',TName, 'YName',GName, ...
    'PlotMeanDifference',true, ...
    'PlotStatistics','regression', 'ConstantResidualVariance',true);

% show results
sPolyResidual = s.difference.sPolyResidual;
display(sPolyResidual) % article: 0.08033 (s_d on p. 148)

% some text output
f = [f7;f8];
fn = [f.Number];
disp(['See also figures [' num2str(fn) '].'])

%% 4 The importance of repeatability (article p. 148)
%TODO
% disp 'Section 4 The importance of repeatability'

%% 4.1 Estimating repeatability (article p. 149)
%TODO
% disp 'Section 4.1 Estimating repeatability'

%% 5 Measuring agreement using repeated measurements (article p. 150)
disp 'Section 5 Measuring agreement using repeated measurements'
%% 5.1 Equal number of replicates (article p. 150)
disp 'Section 5.1 Equal number of replicates'

s = ba(J,S)

%% 5.2 Unequal number of replicates (article p. 154)
disp 'Section 5.2 Unequal number of replicates'

%% 5.3 Replicated data in pairs (article p. 156)
disp 'Section 5.3 Replicated data in pairs'