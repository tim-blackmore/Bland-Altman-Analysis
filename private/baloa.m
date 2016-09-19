function varargout = baloa( ...
    x, xName, y, yName, a, ...
    doPlotMD, axMD, ...
    doPlotMR, axMR, ...
    doPlotMSD, axMSD, ...
    doPlotC, axC, ...
    doPlotBasicStats, doPlotExtendedStats, ...
    doPlotRegStats, doConstantRegression, ...
    doPlotLS, ...
    doRepeated)
%% preparation
if doPlotMD || doPlotC || doPlotMR || doPlotMSD
    % if doMDPlot, f(1) = axMD.Parent; end
    % if doCPlot, f(2) = axC.Parent; end
    ax = [axMD;axMR;axMSD;axC];
    f = get(ax,'Parent');
    if iscell(f), f = vertcat(f{:}); end
    f = unique(f);
    % f can be the handle to one or more figures
else
    f = [];
end

% check and prepare for repeated measurements
[x,y,n,repType] = prepRep(x,y,doRepeated);

%% calculations
% significance statistics
p = 1-a/2;
z = Ninv(p); % inverse normal distribution at p = 1-alpha/2
t = Tinv(p,n-1); % inverse t-distribution at p

% difference statistics
[muXY,d,varXW,varYW,loaDCI,loaD,muD,muDCI,eLoaD,eMuD,sD, ...
    polyMuXYD,msePolyMuXYD,sResPolyMuXYD,polyLLoaD,polyULoaD] = ...
    statMuS(x,y,'difference',n,z,t,doConstantRegression,repType);

% mean-difference correlation statistics
[rSMuD,pRSMuD] = corr(muXY,d,'type','Spearman'); %TODO make independent of stats toolbox?

% ratio statistics
if doPlotMR % only calculated when mean-ratio graph is requested
    [~,R,~,~,loaRCI,loaR,muR,muRCI,eLoaR,eMuR,sR, ...
        polyMuXYR,msePolyMuXYR,sResPolyMuXYR,polyLLoaR,polyULoaR] = ...
        statMuS(x,y,'ratio',n,z,t,doConstantRegression,repType);
    
    % mean-ratio correlation statistics
    [rSMuR,pRSMuR] = corr(muXY,R,'type','Spearman'); %TODO make independent of stats toolbox?
end

% standard deviation statistics
if doPlotMSD % only calculated when mean-standard deviation graph is requested
    [muX,muY,sX,sY] = statMuS(x,y,'SD');
    
    % mean-standard deviation correlation statistics
    [rSMuR,pRSMuR] = corr(muXY,R,'type','Spearman'); %TODO make independent of stats toolbox?
end

% correlation statistics and linear regression %TODO linreg for muXY and d
[pRhoXY,rhoXY,polyXY,msePXY] = statC(x,y,z,doConstantRegression);

%% graphics
% correlation plot
if doPlotC
    plotC(axC,x,y,doPlotBasicStats,pRhoXY,rhoXY,doPlotLS,polyXY, ...
        msePXY,n,xName,yName)
end

% mean-difference plot
if doPlotMD
    % plotMD(axMD,muXY,d,doRatio,doPlotBasicStats,loaCI,pRSMuD,rSMuD,loa,a,z,muD,muDCI,doPlotExtStats,eLoa,eMuD,doPlotLS,n,xName,yName)
    plotM(axMD,muXY,d,'difference','d',0,doPlotBasicStats,loaDCI, ...
        pRSMuD,rSMuD,loaD,a,z,muD,muDCI,doPlotExtendedStats,eLoaD,eMuD, ...
        doPlotLS,'-',n,xName,yName, ...
        doPlotRegStats,polyMuXYD,msePolyMuXYD,polyLLoaD,polyULoaD,doConstantRegression)
end

% mean-ratio plot
if doPlotMR
    plotM(axMR,muXY,R,'ratio','R',1,doPlotBasicStats,loaRCI,pRSMuR, ...
        rSMuR,loaR,a,z,muR,muRCI,doPlotExtendedStats,eLoaR,eMuR,doPlotLS, ...
        '/',n,xName,yName, ...
        doPlotRegStats,polyMuXYR,msePolyMuXYR,polyLLoaR,polyULoaR,doConstantRegression)
end

% mean-standard deviation plot
if doPlotMSD
    plotM(axMSD,muXY, error ,'std','SD',NaN,doPlotBasicStats,loaRCI,pRSMuR, ...
        rSMuR,loaR,a,z,muR,muRCI,doPlotExtendedStats,eLoaR,eMuR,doPlotLS, ...
        '/',n,xName,yName, ...
        doPlotRegStats,polyMuXYR,msePolyMuXYR,polyLLoaR,polyULoaR,doConstantRegression)
end

%% set data cursor update function for figure(s)
for f = f(:).'
    dc = datacursormode(f);
    dc.UpdateFcn = @dcUpdateFcn;
    dc.SnapToDataVertex = 'off';
    dc.Enable = 'on';
end

%% output
% difference outputs
out.difference.mu = muD;
out.difference.muCI = muDCI;
out.difference.loa = loaD;
out.difference.loaCI = loaDCI;
out.difference.s = sD;
out.difference.rSMu = rSMuD;
out.difference.pRSMu = pRSMuD;
out.difference.polyMu = polyMuXYD;
out.difference.msePolyMu = msePolyMuXYD;
out.difference.sPolyResidual = sResPolyMuXYD;

% ratio outputs
if doPlotMR
    out.ratio.mu = muR;
    out.ratio.muCI = muRCI;
    out.ratio.loa = loaR;
    out.ratio.loaCI = loaRCI;
    out.ratio.s = sR;
    out.ratio.rSMu = rSMuR;
    out.ratio.pRSMu = pRSMuR;
    out.ratio.polyMu = polyMuXYR;
    out.ratio.msePolyMu = msePolyMuXYR;
    out.ratio.sPolyResidual = sResPolyMuXYR;
end

% general outputs
out.x.varWithin = mean(varXW);
out.y.varWithin = mean(varYW);

% final output
varargout = {{out}};
end