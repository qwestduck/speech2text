% Copyright (c) 2012, Jianxia Xue, jxue@cs.olemiss.edu
% All rights reserved.
%
% Redistribution and use in source, with or without 
% modification, are permitted provided that the following conditions are 
% met:
%
%   * Redistributions of source code must retain the above copyright 
%     notice, this list of conditions and the following disclaimer.
%   * Redistributions in binary form must reproduce the above copyright 
%     notice, this list of conditions and the following disclaimer in 
%     the documentation and/or other materials provided with the distribution
%      
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.

classdef WordHmm < handle
    properties
        word; % the word to be modeled
        Nstates;      % N number of hidden states
        Mmixtures;     % M number of Gaussian mixtures per state
        A;      % State transition matrix, adding a null state, (N+1)x(N+1)
        %
        % The following observation pdf parameters follows the 
        % dimension arrangement of :
        %  first dimension corresponds to state
        %  second dimension corresponds to mixture
        %
        mu;   % Gaussian mixture means, KxMxN, where K is the feature dimension
        Sigma; % Gaussian mixture covariance matrix, KxKxMxN
        w;       % Gaussian mixture weights, MxN
        % numerical constants 
        MIN_VARIANCE;
    end
    methods
        function self = WordHmm(word, N, M)
            self.word = word;
            self.Nstates = N;
            self.Mmixtures = M;
            self.initA();
            self.MIN_VARIANCE = 1e-3;
        end
        
        function initA( self )
            N = self.Nstates;
            A = zeros(N+1);
            for i=1:N
                A(i,i) = 0.95;
                A(i, i+1) = 0.05;
            end
            A(N+1, N+1) = 1;
            self.A = A;
        end
        
        %
        % Initial estimation of the HMM observation parameters by
        %    1) uniformly segmenting the data and associating each successive
        %    segment with successive states (valid because our HMMs are
        %    left-right directional graphs)
        %
        %    2) using KMeans within each state, to separate all the
        %    features into M clusters, and compute the mean and covariance
        %    of the Mth mixture from the Mth feature cluster, the mixture
        %    weight is the percentage of the correponding cluster
        %    population to the entire state feature population
        %
        % @param[in] observation a cell array of whole word features
        %                   each cell element holds an instance of the same
        %                   word in the vocabulary, in the dimension of
        %                   KxT_i, where i is the cell index.
        % @result mu the mean matrix of KxMxN
        % @result Sigma the covariance matrix of KxKxMxN
        % @result w the mixture weight matrix of MxN
        %
        function initB(self, observation)
            % even distribution of states
            N = self.Nstates;
            M = self.Mmixtures;
            K = size(observation{1},1);
            
            observationPerState = cell(N, 1);
            mu = zeros(K, M, N);
            Sigma = zeros(K, K, M, N);
            w = zeros(M, N);
            
            % even duration segmenentation of state features
            for j=1:length(observation)
                    o = observation{j};
                    T = size(o, 2);
                    bounds = round((0:N) * T / N);
                    bounds(1) = 1;
                    for i=1:N
                        observationPerState{i} = [observationPerState{i}, o(:, bounds(i):bounds(i+1))];
                    end
            end
            % Kmeans initialization of mu, Sigma, and w per state
            for i = 1: N
                % split feature collections into M mixture clusters
                o = observationPerState{i};
                mixtureTags = kmeans(o', M);
                % for each cluster, compute the mean, Sigma, and w
                for j = 1: M
                    features = o(:, find(mixtureTags == j));
                    mu(:, j, i) = mean(features,2);
                    % keep a diagonal covariance to reduce the required
                    % number of feature frames
                    v = var(features, 0, 2);
                    for k=1:length(v)
                        Sigma(k,k,j, i) = v(k)+self.MIN_VARIANCE;
                    end
                    w(j, i) = size(features, 2) / size(o, 2);
                end
            end
            self.mu = mu;
            self.Sigma = Sigma;
            self.w = w;
        end
        
        function [loglikelihood] = estimate( self, observations )
            
            A_acc = zeros(size(self.A));
            mu_acc = zeros(size(self.mu));
            Sigma_acc = zeros(size(self.Sigma));
            w_acc = zeros(size(self.w));
            ll_acc = 0;
            
            for i=1:length(observations)
                observation = observations{i};
                [K, T] = size(observation);
                [loglikelihood, A, m, w] = self.emgm( observation );
                if (i==1)
                    A_acc = A;
                    mu_acc = m;
                    %Sigma_acc = S;
                    w_acc = w;
                    ll_acc = loglikelihood;
                else
                    delta = exp(loglikelihood - ll_acc);
                    scale = 1/(1+delta);
                    A_acc = (A_acc + delta * A) * scale;
                    mu_acc = (mu_acc + delta * m) * scale;
                    %Sigma_acc = (Sigma_acc + delta * S) * scale;
                    w_acc = (w_acc + delta * w) * scale;
                    ll_acc = (ll_acc + delta * loglikelihood) * scale;
                    %disp(ll_acc);
                end                
            end
            self.A = A_acc;
            self.mu = mu_acc;
            %self.Sigma = Sigma_acc;
            self.w = w_acc;
            loglikelihood = ll_acc;
        end
        
        % Viterbi decoding of an observation
        function [likelihood, statePath] = viterbi( self, observation )
            if (nargin < 3)
                B = self.observation_loglikelihood(observation);                
            end
            
            N = self.Nstates;
            M = self.Mmixtures;
            T = size(observation, 2);
            
            seq = zeros(N, T);
            V = log(zeros(N, T));
            
            A = log(self.A);
            w = log(self.w);
            
            V(1,1) = log(sum(exp(w(:,1) + B(:,1,1))));            
            
            for t=2:T
                for i=1:N
                    
                    Vupdate = V(:, t-1) + A(:, i);
                    fprintf('time frame %d hidden state %d \n', t, i);
                    [L, idx] = max(V(:, t-1) + A(:,i));
                    Seq(i,t) = idx;
                    V(i, t) = L + log(sum(exp(w(:,i) + B(:,1,1))));            
                end
            end
            
            % back-tracking
            statePath = zeros(1, T);
            [likelihood, idx] = max(V(:, T));
            statePath(T) = idx;
            for t=T-1 : -1: 1
                statePath(t) = seq(statePath(t+1), t+1);
            end
        end
        
        % Baum-Welch algorithm for hmm reestimation using soft state and
        % mixture alignment
        function [loglikelihood, A, mu, w] = emgm( self, observation )
            N = self.Nstates;
            M = self.Mmixtures;
            
            if (iscell(observation))
                observation = cell2mat(observation);
            end
            
            [K, T] = size(observation);
            
            % E-step
            logB = self.observation_loglikelihood( observation);
            
            B = exp(logB);
            
            [alpha, loglikelihood] = self.forward( observation, B);

            beta = self.backward( observation, B);
            
            gamma = self.forward_backward( alpha, beta, B );
            
            xi = alpha .* beta;
            
            % M-step
            
            % update A matrix
            A = zeros(N, N);
            for si = 1: N
                for sj = 1: N
                    t = squeeze(gamma(si, :, :));
                    A(si, sj) = sum( t(sj, :) ) / (sum( t(:)));
                end
            end
            
            % update means
            mu = zeros(K, M, N);
            for m = 1: M
                for s = 1: N
                    for t = 1: T
                        mu(:, m, s) = mu(:, m, s) + xi(m, s, t) * observation(:, t);
                    end
                    n = sum(squeeze(xi(m, s, :)));
                    mu(:, m, s) = mu(:, m, s) / n;
                end
            end
            
            % update covariance
%             Sigma = zeros(K, K, M, N); for m = 1: M
%             for s = 1: N
%                   for t = 1: T
%                         o = observations(:, t) - mu(:, m, s);
%                         for k=1:K
%                             Sigma(k,k, m, s) = Sigma(k, k, m, s) + xi(m,s, t) * (o(k)*o(k));
%                         end
%                     end
%                    n = sum(squeeze(xi(m, s, :))); Sigma(:,:, m, s) =
%                    Sigma(:, :, m, s) / n + self.MIN_VARIANCE;
%                 end
%             end
%             
            % update mixture weights
            w = zeros( M, N );
            for s = 1: N
                    p = reshape(xi(:, s, :), M, T);
                    n = sum(p(:));
                    w(:, s) = sum( p, 2 ) / n;
            end
        end
        
        function R = forward_backward( self, alpha, beta, B )
            
            N = self.Nstates;
            T = size(alpha, 3);
            
            R = zeros(N, N, T);
            
            A = self.A;
            w = self.w;
            
            for t=2:T
                for si = 1: N
                    for sj = 1: N
                        a = A(si, sj);
                        if ( a > 0 )
                            al = sum( alpha(:, si, t-1));
                            be = sum( w(:, sj) .* B(:, sj, t) .* beta(:, sj, t) );
                            R(si, sj, t) = al * a * be;
                        end
                    end
                end
            end
        end
        
        %
        % @return alpha the linear scale normalized alpha probabilities
        %   should be a MxNxT matrix, with each element (m, s, t) represents
        %   the forward probability of mixture m state s emitting
        %   observation at frame t given all the current and previous
        %   observations
        % @return likelihood the log scale forward probability per frame
        %   should be a Tx1 vector, with each element (t) represents
        %   the likelihood of the observations from the beginning till
        %   frame t generated from the current HMM model
        %
        function [alpha, likelihood] = forward( self, observations, B )
            if (nargin < 3)
                B =  self.observation_loglikelihood(observations);
                B = exp(B);
            end
            
            N = self.Nstates;
            M = self.Mmixtures;
            T = size(observations, 2);
            
            alpha = zeros(M, N, T);
            
            A = self.A;
            w = self.w;
            
            disp(w);
            disp(B);
            
            alpha_unscaled = w(:,1) .* B(:,1,1);
            total = sum(alpha_unscaled);
            likelihood = log(total);
            alpha(:, 1,1) = alpha_unscaled / total;
            
            for t=2:T
                alpha_unscaled = zeros(M, N);
                for s=1:N
                    unscaled = 0;
                    
                    %idx = find(A(:, s) > 0 );
                    %for ss=1:length(idx)
                    %    state = idx(ss);                        
                    for state = 1: N
                        alpha_prev = sum(alpha(:, state, t-1));
                        unscaled = unscaled + alpha_prev*A(state, s);
                    end
                    
                    alpha_unscaled(:,s) = unscaled * w(:,s) .* B(:, s, t);
                end
                
                total = sum(alpha_unscaled(:));
                likelihood = likelihood + log(total);
                alpha(:, :, t) = alpha_unscaled / total;
            end
            
        end
        
        % compute the normalized backward probabilities
        %
        % @param[in] observations the feature matrix in the dimention of
        %                   KxT, K as the dimension of feature space, and T
        %                   as the number of frames
        % @param[in] B, the observation probability matrix in the dimension
        %                   of MxNxT, with each element (m, s, t) represents the
        %                   linear scale probability of observation t
        %                   emitted from hidden state s mixture m
        %
        % @return beta the linear scale normalized beta probabilities
        %   should be a MxNxT matrix, with each element (m, s, t) represents
        %   the backward probability of mixture m state s at frame t emitting
        %   observations from frame t+1 till the last frame
        %
        function [beta] = backward( self, observations, B )
            if (nargin < 3)
                B =  self.observation_loglikelihood(observations);
                B = exp(B);
            end

            N = self.Nstates;
            M = self.Mmixtures;
            [T] = size(observations, 2);
            
            beta = zeros(M, N, T);
            
            trans = self.A;
            mixW = self.w;
            
            beta(:,:,T) = ones(M, N);
            
            for t=(T-1):-1:1
                beta_unscaled = zeros(M, N);
                for s=1:N
                    unscaled = 0;
                    
                    %idx = find( A(s, 1:N) > 0 );
                    %for ss=1:length(idx)
                    %    state = idx(ss);   
                    for state = 1: N
                        beta_next = beta(:, state, t+1);
                        b_next = B(:, state, t+1);
                        
                        unscaled = unscaled + trans(s, state) * sum( mixW(:, state) .* b_next .* beta_next );
                    end
                    
                    beta_unscaled(:, s) = unscaled * mixW(:,s);
                end
                
                total = sum(beta_unscaled(:));
                beta(:, :, t) = beta_unscaled / total;
            end
            
        end
        
        % 
        % return R a MxNxT matrix, with each element represents
        %  the log-likelihood of observation frame T from hidden state N mixture M
        %
        function R = observation_loglikelihood( self, X )
            m = self.mu;
            S = self.Sigma;
            
            M = self.Mmixtures;
            N = self.Nstates;
            
            [K, T] = size(X);
            R = zeros(M, N, T);
            
            for t = 1:T
                x = X(:, t);
                for s = 1:N
                    for mix=1:M
                        R(mix, s, t) = self.logGaussian( x, ...
                            m(:, mix, s), S(:, :, mix, s));
                    end
                end                
            end
        end
        
        function logp = logGaussian(self, x, mu, Sigma)
            K = length(x);
            
            
            %fprintf('minimum variance = %f\n', min(diag(Sigma)));
            %fprintf('determinant of Sigma = %f\n', det(Sigma));
            
            [Upper,p]= chol(Sigma);
            
            if p ~= 0
                error('ERROR: Sigma is not PD.');
            end
            Q = Upper'\(x-mu);
            q = Q' * Q;
            c = K*log(2*pi)+sum(log(diag(Upper)));   % normalization constant
            logp = -(c+q)/2;
            
        end
    end
end
