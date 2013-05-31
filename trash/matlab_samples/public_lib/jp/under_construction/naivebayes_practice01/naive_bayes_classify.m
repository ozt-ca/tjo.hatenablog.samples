% Naive Bayes Classifier
% 3. Classification
% Jeffrey Jedele, 2011

function [predicted_classes, posteriors] = naive_bayes_classify(vectors, priors, likelihoods, evidence)

    n_classes = size(priors, 1);
    n_vectors = size(vectors, 1);
    predicted_classes = zeros(n_vectors, 1);
    posteriors = zeros(n_vectors, n_classes);

    for i=1:n_vectors
        
        vector = find(vectors(i, :)' == 1);
        likelihood_frame = likelihoods(:, vector);
        post = prod(likelihood_frame,2) .* priors ./ prod(evidence(vector),1);

        [max_val, class] = max(post);
        predicted_classes(i) = class;
        posteriors(i,:) = post';

    endfor;

endfunction
