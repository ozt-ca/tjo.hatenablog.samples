% Naive Bayes Classifier
% 2. Training
% Jeffrey Jedele, 2011

function [likelihood_matrix, priors, evidences] = naive_bayes_train(training_vectors, training_classes, n_classes, k)

    likelihood_matrix = zeros(n_classes, size(training_vectors,2));
    priors = zeros(n_classes, 1);
    evidences = zeros(size(training_vectors,2), 1);

    for class=1:n_classes
        fm = training_vectors(find(training_classes == class), :);

        % calc and store likelihoods
        likelihoods = (sum(fm,1) .+ k) ./ (size(fm,1) + k * size(training_vectors,2)); % laplacan smoothing
        likelihood_matrix(class, :) = likelihoods;

        % calc and store priors
        priors(class) = (size(fm,1) + k) / (size(training_vectors,1) + k*n_classes); % laplactian smoothing
    endfor;

    % calc evidences
    evidences = ( (sum(training_vectors,1).+k) ./ (size(training_vectors,1)+k*2) )'; % laplacian smoothing

endfunction
