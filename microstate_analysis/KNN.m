function [test_Predicted_labels] = KNN(Xtrain,Ltrain,Xtest, K)
%% This is the matlab implemenatation for K nearest neighbors
% Input Arguments: 
% Xtrain : training data set
% Ltrain : Labels of training samples
% Xtest : test data set
% K : number of nearest neighbors 
% Output Arguments :
% TestLabel : Predicted labels of the output data set
% default value of K if not given by user is 8.
if(nargin < 3)
error('Incorrect number of inputs.');
end
if(nargin < 4)
   K = 8; 
end
[N , ~] = size(Xtrain);
[Ntest,~] = size(Xtest);
distance = zeros(N,Ntest);
%descendingDistances = zeros(N,Nt);
%Ltest = repmat(Xtest(1,:),N,1);

% calculating the euclidean distance of the test samples from training
% samples
for i = 1: Ntest
     for j = 1: N 
distance(j,i) = norm(Xtest(i,:)-Xtrain(j,:));
     end
end

% ascendingdistances stores all the distances of the test samples
% from the all training samples in cloumns
% Index will have indices of the corresponding training sample
[~,Index]= sort(distance,'ascend');

% consider only top K nearest neighbors to predict the label for test
% sample
Ltest = zeros(K,Ntest);
for i = 1:Ntest
    for j=1:K
    Ltest(j,i) = Ltrain(Index(j,i));
    end
end

test_Predicted_labels = mode(Ltest);
test_Predicted_labels = test_Predicted_labels';

end