%import data for the treasury yield curve
clc
clear

%import data for the treasury yield curve

yieldData= readtable('yieldAndVolatility2000.csv')

%par vector contains, respectively, beta0, beta1, beta2, and tau

startPar=[1,1,1,1]


%Alias the error function with observed data and parameters.

errorNelsonSiegelYield=@(par) sum((yieldData.y-(par(1)+(par(2)+par(3)).* ...
    (1-exp(-yieldData.m./par(4)))./(yieldData.m./par(4))-par(3).* ...
    exp(-yieldData.m./par(4)))).^2);
errorNelsonSiegelVol=@(par) sum((yieldData.vol-(par(1)+(par(2)+par(3)).* ...
    (1-exp(-yieldData.m./par(4)))./(yieldData.m./par(4))-par(3).* ...
    exp(-yieldData.m./par(4)))).^2);



%Run optimization
[parMinYield,errorMin] = fminsearch(errorNelsonSiegelYield,startPar)
[parMinVol,errorMin]   = fminsearch(errorNelsonSiegelVol,startPar)


%Alias new function fittedYield that takes as input some maturity m and 
%returns fitted yields at the estimated parameters

fittedFunctionYield= @(m) (parMinYield(1)+(parMinYield(2)+parMinYield(3)).* ...
    (1-exp(-m./parMinYield(4)))./(m./parMinYield(4))-parMinYield(3)* ...
    exp(-m./parMinYield(4)))

fittedFunctionVol  = @(m) (parMinVol(1)+(parMinVol(2)+parMinVol(3)).* ...
    (1-exp(-m./parMinVol(4)))./(m/parMinVol(4))-parMinVol(3).* ...
    exp(-m./parMinVol(4)))

yieldData.nelsonSiegelYield= fittedFunctionYield(yieldData.m)
yieldData.nelsonSiegelVol= fittedFunctionVol(yieldData.m)

subplot(2,1,1)
plot(yieldData.m,yieldData.y,'*',yieldData.m,yieldData.nelsonSiegelYield);
legend('Observed Yields','Nelson Siegel Fitted Yields')
subplot(2,1,2)
plot(yieldData.m,yieldData.vol,'*',yieldData.m,yieldData.nelsonSiegelVol);
legend('Observed Vols','Nelson Siegel Fitted Vols')