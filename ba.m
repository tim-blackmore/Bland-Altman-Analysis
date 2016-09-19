function varargout = ba(varargin)
%BA Bland-Altman Analysis of agreement between measurement methods.
%   Bland-Altman Analysis is a statistical method published by J. Martin
%   Bland and Douglas G. Altman in the 1980s and further developed later
%   on. It is used to determine the agreement between two measurement
%   methods that measure the same quantity. It is a popular method in
%   biostatistics and chemistry.
%
%   Syntax
%   s = BA(x,y) performs Bland-Altman Analysis (BAA) on x and y, which are
%   data from two measurement methods for the same quantity respectively. x
%   and y can be of various classes and shapes:
%    - If x and y are vectors, regular BAA is performed. Every element in x
%      corresponds to the element in y at the same index. These pairs are
%      individual observations on individual subjects.
%    - If x and y are matrices, BAA for repeated measurements is performed.
%      This means multiple measurements have been acquired per subject. The
%      number of elements in x and y must be equal. Every row of x and y
%      corresponds to the subjects, every column to the repeated
%      observations.
%   For more information about BAA for repeated measurements, see section
%   Bland-Altman Analysis for repeated measurements below. The calculations
%   are done at a significance level of alpha = 0.05. Output s is a
%   structure containing multiple fields with descriptive statistics about
%   the agreement of x and y. For more details on the fields in s see
%   section Output below.
%
%   s = BA(x,y,alpha) specifies the significance level to calculate the
%   limits of agreement and confidence intervals with. alpha must be a
%   scalar in the interval [0,1]. If alpha is not specified a value of 0.05
%   is used by default to calculate 95% limits of agreement and confidence
%   intervals.
%
%   s = BA(__,Name,Value) specifies additional options using one or more
%   Name-Value pair arguments, in addition to any of the input arguments in
%   the previous syntaxes. For example, you can specify to create the
%   mean-difference plot using the 'PlotMeanDifference' Name-Value pair
%   argument.
%
%   BA(__) can be used to plot the data without returning an output
%   argument.
%
%   __ = BA(f,__) specifies the figure(s) f in which to create the plots
%   specified with the corresponding Name-Value pairs. The number of
%   figures in f must equal one or the number of specified plots.
%
%   __ = BA(ax,__) specifies the (array of) axes in which to create the
%   plots specified with the corresponding Name-Value pairs. The number of
%   axes in ax must equal the number of specified plots.
%
%   Examples
%   See and run the ba1999demo.m script for examples of the syntax of BA
%   used with data from the 1999 article by Bland and Altman. Calling BA
%   without input arguments also runs the demonstration script.
%
%   Name-Value Pair Arguments
%   Specify optional comma-separated pairs of Name,Value arguments to
%   access various options. Name is the argument name and Value is the
%   corresponding value. Name must appear inside single quotes (' '). You
%   can specify several name and value pair arguments in any order as
%   Name1,Value1,...,NameN,ValueN.
%   Example: 'XName','X','YName','Y'
%
%   'XName': Name of x variable
%   inputname of input argument x (default) | string
%   Name of x variable, specified as a string. 'XName' is used in the plot
%   titles.
%   Example: 'XName','X' sets the first measurement's name to 'X'.
%
%   'YName': Name of y variable
%   inputname of input argument y (default) | string
%   Name of y variable, specified as a string. 'YName' is used in the plot
%   titles.
%   Example: 'YName','Y' sets the second measurement's name to 'Y'.
%
%   'Exclude': Subjects to exclude
%   [] (default) | logical indices | numeric indices
%   Subjects to exclude, specified as logical or numeric indices into x and
%   y. The specified rows are removed from x and y before any calculations
%   are done or graphs are created.
%   Example: 'Exclude',[1, 3, 4] excludes rows 1, 3 and 4 from x and y.
%   Example: 'Exclude',[0 0 1 0 1 1 0 0 1] excludes the true rows from
%   x and y. Note the logical vector needn't be a column vector.
%
%   'Transform': Function to transform data with
%   @(x) x (default) | function handle
%   Function to transform data with before further analysis, specified as a
%   function handle of one variable. By default, no transformation is
%   performed. The function handle should accept a vector input. Bland and
%   Altman suggest in their 1999 article (see p. 144) only the logarithmic
%   transformation should be used, i.e. specify 'Transform',@log. Other
%   transforms are not easily relatable to the actual measurements, hence
%   their recommendation.
%   Example: 'Transform',@log transforms x to log(x) and y to log(y).
%
%   'PlotMeanDifference': Create mean-difference graph
%   false (default) | true
%   Create the mean-difference graph if the specified value is true. The
%   mean-difference graph is a scatter plot of the difference between
%   observations versus their mean. Specifying the 'PlotDefault' Name-Value
%   pair argument as true creates the mean-difference plot, regardless of
%   the 'PlotMeanDifference' value.
%
%   'PlotMeanRatio': Create mean-ratio graph
%   false (default) | true
%   Creat the mean-ratio graph if the specified value is true. The
%   mean-ratio graph is a scatter plot of the ratio between observations
%   versus their mean.
%
%   'PlotCorrelation': Create correlation graph
%   false (default) | true
%   Create the correlation graph if the specified value is true. The
%   correlation graph is a scatter plot of x and y. Specifying the
%   'PlotAll' Name-Value pair argument as true creates the correlation
%   plot, regardless of the 'PlotCorrelation' value.
%
%   'PlotDefault': Create default plots
%   false (default) | true
%   Create mean-difference and correlation plots if the specified value is
%   true. Setting 'PlotDefault' to true overrides any value given to the
%   'PlotMeanDifference' and 'PlotCorrelation' Name-Value pair arguments.
%   However, setting 'PlotDefault' to false does not override the
%   individual plot Name-Value pair arguments.
%
%   'PlotStatistics': Add statistics to the created plots
%   'none' (default) | 'basic' | 'extended'
%   Add statistics to the created plots, specified as 'none', 'basic',
%   'extended' or 'regression'. 'none' specifies no statistics to be added
%   to the graphs. 'basic' specifies a basic set of statistics to add.
%   'extended' adds a more extended set of statistics. 'regression' adds
%   regression lines to the graphs.The following statistics are added to
%   the plots. The basic set adds labelled lines for the limits of
%   agreement to the mean-statistic graphs. It also adds the Spearman rank
%   correlation coefficient to the legend of these graphs. Furthermore, the
%   Pearson correlation coefficient is added to the legend of the
%   correlation plot. The extended set adds the statistics of the basic
%   set. Additionally, the confidence intervals of the bias and limits of
%   agreement are plotted as error bars in the mean-statistic graphs. The
%   extended set does not add statistics other than the basic set to the
%   correlation plot. The regression statistics comprise of the extended
%   set, except that the bias and limits of agreement lines are no longer
%   constant with respect to the mean. The variable on the vertical axis is
%   regressed on the mean, resulting in the possibility of non-constant
%   lines. If no plots are created, the 'PlotStatistics' value is ignored.
%   
%   'ConstantResidualVariance': Assume constant residual variance
%   false (default) | true
%   Assume constant residual variance in the simple linear regression
%   performed if the 'PlotStatistics','regression' Name-Value pair argument
%   is specified. This mean the upper and lower limits of agreement lines
%   will have the same slope as the bias line. This assumption holds if the
%   slope of the upper and lower limits of agreement do not differ
%   significantly from the slope of the bias regression line.
%
%   Output
%   The only output argument s is optional. It is a scalar structure
%   containing multiple fields with descriptive statistics about the
%   agreement of x and y. The number of fields in s varies depending on the
%   input arguments. By default s contains three fields, being difference,
%   x and y. Additional fields in s are ratio and correlation. They exist
%   depending on the requested graphs. If the mean-ratio graph is requested
%   using the 'PlotMeanRatio' Name-Value pair argument, then s is returned
%   with the ratio field. If the correlation plot is requested using the
%   'PlotCorrelation' or 'PlotDefault' Name-Value pair arguments, then s is
%   returned with the correlation field. Note that the difference field is
%   returned regardless of the 'PlotMeanDifference' Name-Value pair
%   argument.
%
%   Fields difference and ratio are described together below, after which
%   fields x and y are described together too. Lastly, field correlation is
%   described.
%
%   The difference and ratio fields are structures themselves, containing
%   the statistics about the differences and ratios (resp.) between
%   observations in x and y. The fields in difference and ratio are
%   described below (the word statistic refers to either difference or
%   ratio):
%
%   mu: the mean statistic between x and y, also called the bias.
%   Example: s.difference.mu is the mean difference.
%
%   muCI: the 95% (default, depending on alpha) confidence interval of
%   the mean statistic.
%   Example: s.ratio.muCI is the confidence interval of the mean ratio.
%
%   loa: the 95% (default, depending on alpha) limits of agreement, a 2
%   element vector. The first element is the lower limit of agreement, the
%   second is the upper.
%   Example: s.difference.loa(1) is the lower limit of agreement of the
%   differences.
%
%   loaCI: the 95% (default, depending on alpha) confidence interval of the
%   limits of agreement, a 2x2 matrix. The first column corresponds to
%   lower limit of agreement, the second to the upper limit. The first and
%   second row correspond to the lower and upper confidence interval bound
%   respectively.
%   Ecample: s.ratio.loaCI(:,2) is the confidence interval of the upper
%   limit of agreement of the ratios.
%
%   s: the standard deviation of the statistic.
%   Example: s.difference.s is the standard deviation of the differences.
%
%   rSMu: the Spearman rank correlation between mean and statistic.
%   Example: s.ratio.rSMu is the Spearman rank correlation between mean and
%   the ratios.
%
%   pRSMu: the p-value of the Spearman rank correlation for testing the
%   hypothesis of no correlation against the alternative that there is a
%   nonzero correlation. %TODO also output rhoXY,pRhoXY
%   Example: s.difference.pRSMu is the p-value of the Spearman rank
%   correlation between mean and difference, to test the hypothesis of no
%   correlation against the alternative of nonzero correlation.
%
%   polyMu: the polynomial coefficients of the simple linear regression of
%   the statistic on the mean. The first element of polyMu is the slope,
%   the second the intercept.
%   Example: s.ratio.polyMu(2) is the intercept of the simple linear
%   regression line of the ratio on the mean.
%
%   msePolyMu: the mean squared error (MSE) of the simple linear regression
%   of the statistic on the mean.
%   Example: s.difference.msePolyMu is the MSE of the simple linear
%   regression of the difference on the mean.
%
%   The x y fields of structure s contain statistics about inputs x and y,
%   that are calculated in BAA. The fields in x and y are structure
%   themselves and have the following fields (the word input referring to x
%   or y):
%
%   varWithin: the within-subject variance of the input. varWithin equals
%   zero for regular BAA, but can be non-zero in BAA for repeated
%   measurements.
%   Example: s.x.varWithin is the within-subject variance of input x.
%
%   If the correlation field exists in s, it contains the following fields:
%
%   rho: the Pearson correlation coefficient of the inputs.
%
%   p: the p-value of the Pearson correlation coefficient of the inputs.
%
%   poly: the polynomial coefficients of the simple linear regression of y
%   on x. The first element in poly is the slope, the second the intercept.
%
%   polyMSE: the mean squared error (MSE) of the simple linear regression
%   of y on x.
%
%   Bland-Altman Analysis for repeated measurements
%   When performing regular limits of agreement (LOA) estimation through
%   Bland-Altman Analysis (BAA) a number of implicit assumptions exists.
%   One of these assumptions is that the individual observation pairs are
%   independent. This is the case when every observed pair comes from a
%   different subject. However, when multiple measurements are taken on the
%   same individual, this assumption does not hold. The measurements on the
%   same individual might depend on each other. For example, a subject's
%   blood pressure is measured every minute using a sphygmomanometer. The
%   observations of every minute will be quite correlated with the previous
%   minute, i.e. the cross-covariance is high at the first (few) lag(s).
%   Another more general example: consider 10 observations of a physical
%   quantity. When these 10 observations are obtained from 10 different
%   subjects (assuming these subjects are a representative sample of the
%   population), the assumptions of regular BAA will have been met.
%   However, if these 10 observations would come from one subject only, the
%   calculations of (mean) difference (or ratio) will depend strongly on
%   the within-subject variance of this particular subject. This is less
%   informative about the performance of the two measurement methods and
%   how they compare in general. Instead, this analysis tells us about the
%   performance of the methods on this subject, which usually is not of
%   interest in method comparison studies.
%
%   About
%   This MATLAB function is an implementation of the methods in the 1999
%   article by Bland and Altman:
%   Bland & Altman 1999 - Measuring agreement methods in comparison studies
%   http://smm.sagepub.com/content/8/2/135.abstract
%
%   You might not have access to this article. Access it through your
%   institution's library or buy it.
%
%   The article comprises of 5 methodological sections (sections 2-6). The
%   current version of this MATLAB file (8 september 2016) implements the
%   first methodological section. More sections will be added in the
%   future.
%
%   The demonstration script `ba1999demo.m` is an implementation of the
%   calculations done by Bland and Altman in the article. Their article
%   contains a number of example data sets, which they use in their
%   methods. The demonstration script illustrates the same results and the
%   syntax used to obtain them.
%
%   See also BA1999DEMO

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

%% inputs
% demo if no input arguments
if ~nargin, ba1999demo, return, end

in = varargin;

% check if first input is (an array of) handles
if all(isgraphics(in{1}))
    h = in{1};
    in = in(2:end);
    ixname = 2;
    iyname = 3;
else
    h = [];
    ixname = 1;
    iyname = 2;
end

% prepare parser
p = inputParser;
p.addRequired('x',@validateXY)
p.addRequired('y',@validateXY)
p.addOptional('a',.05,@isnumeric)
p.addParameter('XName',inputname(ixname),@ischar)
p.addParameter('YName',inputname(iyname),@ischar)
p.addParameter('PlotDefault',false,@validatelogical)
p.addParameter('PlotMeanDifference',false,@validatelogical)
p.addParameter('PlotMeanRatio',false,@validatelogical)
p.addParameter('PlotMeanSD',false,@validatelogical)
p.addParameter('PlotCorrelation',false,@validatelogical)
p.addParameter('Exclude',[],@validatelogical)
p.addParameter('PlotStatistics','none',@ischar)
p.addParameter('ConstantResidualVariance',false,@validatelogical)
p.addParameter('Transform',@(x) x,@(f) isa(f,'function_handle')|ischar(f))

% parse inputs
parse(p,in{:})
s2v(p.Results); %#ok<*NODEF>

%% validate and preprocess inputs
% x and y: measurements of two methods
% parseXY validates and reshapes x and y for further analysis. It also
% checks for repeated measurements analysis.
[xok,yok,doRepeated] = parseXY(x,y);

% alpha: significance level
if ~isscalar(a) && a<0 && a>1
    error 'alpha must be a scalar in the interval [0,1].'
end

% xName and yName
if ~iscellstr(XName), XName = cellstr(XName); end
if ~iscellstr(YName), YName = cellstr(YName); end
xName = strjoin(XName,', ');
yName = strjoin(YName,', ');

% validate plot arguments
[doPlotMD,axMD,doPlotMR,axMR,doPlotMSD,axMSD,doPlotC,axC] = ...
    validatePlotArgs( ...
    PlotDefault, ...
    PlotMeanDifference, PlotMeanRatio, PlotMeanSD, PlotCorrelation, ...
    h ...
    );

% exclude samples
lex = false(size(xok,1),1);
lex(Exclude) = true;
xok(lex,:) = [];
yok(lex,:) = [];

% statistics set to plot
[doPlotBasicStats,doPlotExtendedStats, ...
    doPlotRegStats,doConstantRegression] = ...
    parseStatArgs(PlotStatistics,ConstantResidualVariance);

% transformation function
transFun = Transform;
if ischar(transFun), transFun = str2func(transFun); end
switch lower(char(transFun)) % detect supported transformations
    case 'log'
        if any(strcmpi(p.UsingDefaults,'XName'))
            xName = ['Log ' xName];
        end
        if any(strcmpi(p.UsingDefaults,'YName'))
            yName = ['Log ' yName];
        end
        xok = transFun(xok);
        yok = transFun(yok);
    otherwise % no transformation
end

%% Bland-Altman analysis
out = baloa( ...
    xok, xName, yok, yName, a, ...
    doPlotMD, axMD, ...
    doPlotMR, axMR, ...
    doPlotMSD, axMSD, ...
    doPlotC, axC, ...
    doPlotBasicStats, doPlotExtendedStats, ...
    doPlotRegStats, doConstantRegression, ...
    doRepeated);

%% output
if nargout, varargout = out; end
end