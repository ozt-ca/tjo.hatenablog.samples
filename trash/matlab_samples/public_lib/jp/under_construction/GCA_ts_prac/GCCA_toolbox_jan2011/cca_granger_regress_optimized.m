function [ret] = cca_granger_regress_optimized(X,nlags,STATFLAG)

nobs = size(X,2);
nvar = size(X,1);
if(nvar>nobs) error('error in cca_granger_regress: nvar>nobs, check input matrix'); end
if nargin == 2, STATFLAG = 1; end

% remove sample means if present (no constant terms in this regression)
m = mean(X');
if(abs(sum(m)) > 0.0001)
    mall = repmat(m',1,nobs);
    X = X-mall;
end

% construct lag matrices
lags = -999*ones(nvar,nobs-nlags,nlags);
for jj=1:nvar
    for ii=1:nlags
        lags(jj,:,nlags-ii+1) = X(jj,ii:nobs-nlags+ii-1);
    end
end

%  unrestricted regression (no constant term)
regressors = zeros(nobs-nlags,nvar*nlags);
for ii=1:nvar,
    s1 = (ii-1)*nlags+1;
    regressors(:,s1:s1+nlags-1) = squeeze(lags(ii,:,:));
end

xdep=X(:,nlags+1:end)';
%beta=gcca_cuda_granger_regress_mex(single(xdep),single(regressors),single(nlags));
%beta=beta(1:nvar*nlags,:);
beta=regressors\xdep;
xpred=regressors*beta;
u=xdep-xpred;
RSS1=sum(u.^2);
C=zeros(size(u,2),1);
for ii=1:size(u,2)
    C(ii)=cov(u(1:nobs-nlags,ii),1);
end
covu=cov(u);


caus_cel=cell(1,nvar);
for ii=1:nvar
    caus_inx = setdiff(1:nvar,ii);
    for jj=1:length(caus_inx)
        eq_inx(jj,:) = setdiff(1:nvar,caus_inx(jj));
    end
    caus_cel{ii}=eq_inx;
end

possibles=combinator(nvar,nvar-1,'c');
RSS0=zeros(nvar,nvar);
S=zeros(nvar,nvar);
revinc=nvar;

for pp=1:size(possibles,1)
    inc=1;
    for ii=1:nvar
        if(ismember(possibles(pp,:),caus_cel{ii},'rows'))
            toinc(inc)=ii;
            inc=inc+1;
        end
    end
    toinc=unique(toinc);
    
    for kk=1:nvar-1
        s1 = (kk-1)*nlags+1;
        regressors_r(:,s1:s1+nlags-1) = squeeze(lags(possibles(pp,kk),:,:));
    end
    
    xdep_r=X(toinc,nlags+1:end)';
    %bet_tmp=gcca_cuda_granger_regress_mex(single(xdep_r),single(regressors_r),single(nlags))';
    %beta_r=bet_tmp(:,1:(nvar*nlags)-nlags);
    %temp_r=xdep_r-regressors_r*beta_r';
    beta_r=regressors_r\xdep_r;
    temp_r=xdep_r-regressors_r*beta_r;
    cov_vals=zeros(size(temp_r,2),1);
    for ii=1:size(temp_r,2)
        cov_vals(ii)=cov(temp_r(1:nobs-nlags,ii),1);
    end
    D=setdiff(1:nvar,revinc);
    S(D,revinc)=cov_vals;
    RSS0(D,revinc)=sum(temp_r.^2);
    revinc=revinc-1;
    %disp(['iteration ' num2str(pp) ' of ' num2str(size(possibles,1))]);
end

% calc Granger values
gc = ones(nvar).*NaN;
doi = ones(nvar).*NaN;
%   do Granger f-tests if required
if STATFLAG > 0,
    prb = ones(nvar).*NaN;
    ftest = zeros(nvar);
    n2 = (nobs-nlags)-(nvar*nlags);
    for ii=1:nvar-1
        for jj=ii+1:nvar
            ftest(ii,jj) = ((RSS0(ii,jj)-RSS1(ii))/nlags)/(RSS1(ii)/n2);    % causality jj->ii
            prb(ii,jj) = 1 - cca_cdff(ftest(ii,jj),nlags,n2);
            ftest(jj,ii) = ((RSS0(jj,ii)-RSS1(jj))/nlags)/(RSS1(jj)/n2);    % causality ii->jj
            prb(jj,ii) = 1 - cca_cdff(ftest(jj,ii),nlags,n2);
            gc(ii,jj) = log(S(ii,jj)/C(ii));
            gc(jj,ii) = log(S(jj,ii)/C(jj));
            doi(ii,jj) = gc(ii,jj) - gc(jj,ii);
            doi(jj,ii) = gc(jj,ii) - gc(ii,jj);
        end
    end
else
    ftest = -1;
    prb = -1;
    for ii=1:nvar-1,
        for jj=ii+1:nvar,
            gc(ii,jj) = log(S(ii,jj)/C(ii));
            gc(jj,ii) = log(S(jj,ii)/C(jj));
            doi(ii,jj) = gc(ii,jj) - gc(jj,ii);
            doi(jj,ii) = gc(jj,ii) - gc(ii,jj);
        end
    end
end

%   do r-squared and check whiteness, consistency
if STATFLAG == 2,
    df_error = (nobs-nlags)-(nvar*nlags);
    df_total = (nobs-nlags);
    for ii = 1:nvar
        xvec = X(ii,nlags+1:end);
        rss2 = xvec*xvec';
        rss(ii) = 1 - (RSS1(ii) ./ rss2);
        rss_adj(ii) = 1 - ((RSS1(ii)/df_error) / (rss2/df_total) );
        waut(ii) = cca_whiteness(X,u(:,ii));
    end
    cons = cca_consistency(X,xpred);
else
    rss = -1;
    rss_adj = -1;
    waut = -1;
    cons = -1;
end

%   organize output structure
ret.gc = gc;
ret.fs = ftest;
ret.prb = prb;
ret.covu = covu;
%ret.covr = covr;%%%implement later
ret.rss = rss;
ret.rss_adj = rss_adj;
ret.waut = waut;
ret.cons = cons;
ret.doi = doi;
ret.type = 'td_normal';

% This file is part of GCCAtoolbox.  It is Copyright (C) Anil Seth, 2004-09
%
% GCCAtoolbox is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% GCCAtoolbox is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with GCCAtoolbox.  If not, see <http://www.gnu.org/licenses/>.

      