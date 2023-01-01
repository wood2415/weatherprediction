function [trainedModel, validationRMSE] = tmaxRMrqGPR(trainingData)
% [trainedModel, validationRMSE] = trainRegressionModel(trainingData)
% Returns a trained regression model and its RMSE. This code recreates the
% model trained in Regression Learner app. Use the generated code to
% automate training the same model with new data, or to learn how to
% programmatically train models.
%
%  Input:
%      trainingData: A table containing the same predictor and response
%       columns as those imported into the app.
%
%  Output:
%      trainedModel: A struct containing the trained regression model. The
%       struct contains various fields with information about the trained
%       model.
%
%      trainedModel.predictFcn: A function to make predictions on new data.
%
%      validationRMSE: A double containing the RMSE. In the app, the Models
%       pane displays the RMSE for each model.
%
% Use the code to train the model with new data. To retrain your model,
% call the function from the command line with your original data or new
% data as the input argument trainingData.
%
% For example, to retrain a regression model trained with the original data
% set T, enter:
%   [trainedModel, validationRMSE] = trainRegressionModel(T)
%
% To make predictions with the returned 'trainedModel' on new data T2, use
%   yfit = trainedModel.predictFcn(T2)
%
% T2 must be a table containing at least the same predictor columns as used
% during training. For details, enter:
%   trainedModel.HowToPredict

% Auto-generated by MATLAB on 30-Jun-2022 17:44:38


% Extract predictors and response
% This code processes the data into the right shape for training the
% model.
inputTable = trainingData;
predictorNames = {'TAVG', 'TMAX', 'TMIN', 'TAVG_1', 'TMAX_1', 'TMIN_1', 'TAVG_3', 'TMAX_3', 'TMIN_3', 'TAVG_4', 'TMAX_4', 'TMIN_4', 'TAVG_5', 'TMAX_5', 'TMIN_5', 'TAVG_6', 'TMAX_6', 'TMIN_6', 'TAVG_7', 'TMAX_7', 'TMIN_7'};
predictors = inputTable(:, predictorNames);
response = inputTable.TMAX_2;
isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];

% Train a regression model
% This code specifies all the model options and trains the model.
regressionGP = fitrgp(...
    predictors, ...
    response, ...
    'BasisFunction', 'constant', ...
    'KernelFunction', 'rationalquadratic', ...
    'Standardize', true);

% Create the result struct with predict function
predictorExtractionFcn = @(t) t(:, predictorNames);
gpPredictFcn = @(x) predict(regressionGP, x);
trainedModel.predictFcn = @(x) gpPredictFcn(predictorExtractionFcn(x));

% Add additional fields to the result struct
trainedModel.RequiredVariables = {'TAVG', 'TAVG_1', 'TAVG_3', 'TAVG_4', 'TAVG_5', 'TAVG_6', 'TAVG_7', 'TMAX', 'TMAX_1', 'TMAX_3', 'TMAX_4', 'TMAX_5', 'TMAX_6', 'TMAX_7', 'TMIN', 'TMIN_1', 'TMIN_3', 'TMIN_4', 'TMIN_5', 'TMIN_6', 'TMIN_7'};
trainedModel.RegressionGP = regressionGP;
trainedModel.About = 'This struct is a trained model exported from Regression Learner R2021b.';
trainedModel.HowToPredict = sprintf('To make predictions on a new table, T, use: \n  yfit = c.predictFcn(T) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''trainedModel''. \n \nThe table, T, must contain the variables returned by: \n  c.RequiredVariables \nVariable formats (e.g. matrix/vector, datatype) must match the original training data. \nAdditional variables are ignored. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appregression_exportmodeltoworkspace'')">How to predict using an exported model</a>.');

% Extract predictors and response
% This code processes the data into the right shape for training the
% model.
inputTable = trainingData;
predictorNames = {'TAVG', 'TMAX', 'TMIN', 'TAVG_1', 'TMAX_1', 'TMIN_1', 'TAVG_3', 'TMAX_3', 'TMIN_3', 'TAVG_4', 'TMAX_4', 'TMIN_4', 'TAVG_5', 'TMAX_5', 'TMIN_5', 'TAVG_6', 'TMAX_6', 'TMIN_6', 'TAVG_7', 'TMAX_7', 'TMIN_7'};
predictors = inputTable(:, predictorNames);
response = inputTable.TMAX_2;
isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];

% Perform cross-validation
partitionedModel = crossval(trainedModel.RegressionGP, 'KFold', 5);

% Compute validation predictions
validationPredictions = kfoldPredict(partitionedModel);

% Compute validation RMSE
validationRMSE = sqrt(kfoldLoss(partitionedModel, 'LossFun', 'mse'));
