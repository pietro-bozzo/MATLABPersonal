function [beta,p,h,CI] = timeEffectGLS(Y,n)

% Y: observations
% n: number of time points

arguments
    Y (:,1) {mustBeNumeric}
    n (1,1) {mustBeNumeric}
end

% build predictors
X = [zeros(1,n-1);diag(ones(n-1,1))];
X = repmat(X,numel(Y)/n,1);

% add intercept
X = [ones(size(X,1),1),X];
n_time_steps = size(X,2);
n_subjects = size(X,1) / size(X,2);

% remove NaNs
X = X(~isnan(Y),:);
Y = Y(~isnan(Y));

% 1. OLS residuals
beta_ols = (X.'*X) \ (X.'*Y);
residuals = Y - X*beta_ols;

% 2. estimate rho and sigma^2 for covariance matrix
% rho
num = 0; den = 0;
for j = 1 : n_subjects
    u_t = residuals((j-1)*n_time_steps+2 : j*n_time_steps);
    u_tm1 = residuals((j-1)*n_time_steps+1 : j*n_time_steps-1);
    num = num + u_t.'*u_tm1;
    den = den + u_tm1.'*u_tm1;
end
rho_hat = num / den;

% sigma^2
sse = 0;
for j = 1 : n_subjects
    e = residuals((j-1)*n_time_steps+2 : j*n_time_steps) - rho_hat * residuals((j-1)*n_time_steps+1 : j*n_time_steps-1);
    sse = sse + e.'*e;
end
N_eff = n_subjects * (n_time_steps-1);
sigma_eps2_hat = sse / (N_eff-1);
sigma2_hat = sigma_eps2_hat / (1 - rho_hat^2);

% covariance matrix
blocks_hat = cell(1,n_subjects);
[blocks_hat{:}] = deal(sigma2_hat * toeplitz(rho_hat.^(0:n_time_steps-1)));
Sigma_hat = blkdiag(blocks_hat{:});

% GLS estimator
XtSinvX = X' * (Sigma_hat \ X);
beta = XtSinvX \ (X.'*(Sigma_hat\Y));

% 95% confidence intervals

V_beta = inv(XtSinvX);
se_beta = sqrt(diag(V_beta)); % standard errors
alpha = 0.05;
df = size(X,1) - size(X,2); % n - p degrees of freedom (n: #observations, p: #regression coefficients)
t_crit = tinv(1-alpha/2,df); % t-student 
% for large samples, norminv(1-alpha/2) is better as t-student CI are an approximation
CI = [beta - t_crit*se_beta,beta + t_crit*se_beta];

% test whether beta_j differs from beta1, using t-test statistics
tstats_equal = nan(n_time_steps-1,1);
p = nan(n_time_steps-1,1);
for j = 2 : n_time_steps
    diff_est = beta(j) - beta(1);
    var_diff = V_beta(j,j) + V_beta(1,1) - 2*V_beta(j,1);
    se_diff = sqrt(var_diff);
    tstats_equal(j-1) = diff_est / se_diff;
    p(j-1) = 2 * (1 - tcdf(abs(tstats_equal(j-1)), df));
end
% correct for multiple comparisons
h = holmBonferroni(p,alpha);