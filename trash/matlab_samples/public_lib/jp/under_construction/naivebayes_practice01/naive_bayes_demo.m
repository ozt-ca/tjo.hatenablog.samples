% Naive Bayes Classifier
% 1. Startup and evaluation
% Jeffrey Jedele, 2011

function naive_bayes_demo()

    % load data
    load training_vectors.matrix;
    load training_classes.matrix;

    % laplacian smoothing factor to cope with 0-likelihoods
    number_of_classes = 13;

    % training
    trainingset_vectors = training_vectors(1:70,:);
    trainingset_classes = training_classes(1:70,:);
    testset_vectors = training_vectors(71:90,:);
    testset_classes = training_classes(71:90,:);
    crossvalset_vectors = training_vectors(91:100,:);
    crossvalset_classes = training_classes(91:100,:);

    % cross validation to determine good k
    likelihoods = zeros(number_of_classes, size(training_vectors, 2));
    priors = zeros(number_of_classes, 1);
    evidence = zeros(size(training_vectors,2), 1);
    accuracy = 0.0;
    k = 0.0;
    k_values = [0.01, 0.03, 0.1, 0.3, 1, 3, 10, 30];
    for i=1:length(k_values)
        % train with k
        [c_likelihoods, c_priors, c_evidence] = naive_bayes_train(trainingset_vectors, trainingset_classes, number_of_classes, k_values(i));
        % classify cross-val set
        [crossval_predicted_classes, crossval_posteriors] = naive_bayes_classify(crossvalset_vectors, c_priors, c_likelihoods, c_evidence);
        % check if k is better
        c_accuracy = sum(crossval_predicted_classes == crossvalset_classes)/length(crossvalset_classes)*100.0;
        if c_accuracy>accuracy
            accuracy = c_accuracy;
            k = k_values(i);
            likelihoods = c_likelihoods;
            priors = c_priors;
            evidence = c_evidence;
        endif;
    endfor;
    printf("Selected k=%2.2f with cross-validation accuracy=%2.2f%%.\n",k, accuracy);

    % trainingset accuray
    [trainingset_predicted_classes, trainingset_posteriors] = naive_bayes_classify(trainingset_vectors, priors, likelihoods, evidence);
    accuracy = sum(trainingset_predicted_classes == trainingset_classes)/length(trainingset_classes)*100.0;
    printf("Accuracy on training-set=%2.2f%%\n", accuracy);

    % test
    [test_predicted_classes, test_posteriors] = naive_bayes_classify(testset_vectors, priors, likelihoods, evidence);
    accuracy = sum(test_predicted_classes == testset_classes)/length(testset_classes)*100.0;
    printf("Accuracy on test-set=%2.2f%%\n", accuracy);

    % predict examples
    example_vectors = zeros(2, 72);
    example_vectors(1, [21,71,7,48,2,1]) = [1,1,1,1,1,1]; % 'i want to pay my bill'
    example_vectors(2, [42,38,8,37,31,2,34,24]) = [1,1,1,1,1,1,1,1]; % 'i'm having a problem with my phone connection'
    [examples_predicted_classes, examples_posteriors] = naive_bayes_classify(example_vectors, priors, likelihoods, evidence);
    printf("Prediction for 'i want to pay my bill': %d\n", examples_predicted_classes(1));
    printf("Prediction for 'i'm having a problem with my phone connection': %d\n", examples_predicted_classes(2));

endfunction
