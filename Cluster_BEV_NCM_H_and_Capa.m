clc;clear;close all;
% The workbook for clustering is collated from the source data
workbook = 'Clu_NCM-H_Capa.xlsx';
[~, ~, data_a] = xlsread('Clu_NCM-H_Capa', 'TYBA'); % NCM-H ratio
[~, ~, data_b] = xlsread('Clu_NCM-H_Capa', 'CPBA'); % BEV single-vehicle capacity

% Countries and info
countries = data_a(2:end, 1);
info_a = cell2mat(data_a(2:end, 7)).*100;
info_b = cell2mat(data_b(2:end, 7));
info_c = cell2mat(data_b(2:end, 8));
info = [info_a, info_b];

% Info normalization
normalized_info_a = (info_a - mean(info_a)) ./ std(info_a);
normalized_info_b = (info_b - mean(info_b)) ./ std(info_b);

normalized_data = [normalized_info_a, normalized_info_b];

%% Find best_k
rng(42); % Random seed
max_k = 6; % Maximum number of clusters

% SSE initialization
sse = zeros(max_k, 1);

for k = 1:max_k
    best_distance = Inf;
    
    for i = 1:1000

        initial_centers = datasample(normalized_data, k, 'Replace', false);
        
        % Applying K-means
        [~, ~, sumd,DisMat] = kmeans(normalized_data, k, 'Start', initial_centers);
        
        % SSE calculating
        total_distance = sum(sumd.^2);
        
        if total_distance < best_distance
            best_distance = total_distance;
        end
    end
    
    % Save SSE
    sse(k) = best_distance;
end

% Plot the Elbow
figure(1)
plot(1:max_k, sse, 'bo-');
xlabel('Number of Clusters (k)');
ylabel('Sum of Squared Errors (SSE)');
title('Elbow Method for Optimal k');

% Choosing k = 3 here results in low SSE and clearer clustering interpretation
%best_k = input('Please enter the best k value based on the elbow method: ');
best_k = 3;

%% Get labels using K-means algorithm
rng(42);

% Get labels
[labels, centers] = kmeans(normalized_data, best_k);

labels_total = {labels, info_c};
% Plot results
figure(2)
color3 = [1 .82 0;1 .82 0;0 0.75 1;.13 .55 .13;.13 .55 .13];
gscatter(info(:, 1), info(:, 2), labels_total,color3,'.++.+',15,'off');
hold on;

% Country name
for i = 1:length(countries)
    if i == 47 %GR
        text(info(i,1), info(i, 2)+.5, countries{i}, 'FontSize', 14,'FontName','Arial');
    elseif i == 7%JL
        text(info(i,1)-1.6, info(i, 2), countries{i}, 'FontSize', 14,'FontName','Arial');
    elseif i == 27%SN
        text(info(i,1)-2, info(i, 2)+.1, countries{i}, 'FontSize', 14,'FontName','Arial');
    elseif i == 6%LN
        text(info(i,1)-1.6, info(i, 2), countries{i}, 'FontSize', 14,'FontName','Arial');
    elseif i == 4%SX
        text(info(i,1)-2, info(i, 2), countries{i}, 'FontSize', 14,'FontName','Arial');
    elseif i == 5%IM
        text(info(i,1)-1.6, info(i, 2), countries{i}, 'FontSize', 14,'FontName','Arial');
    elseif i == 28%GS
        text(info(i,1)-2, info(i, 2), countries{i}, 'FontSize', 14,'FontName','Arial');
    else
    text(info(i,1), info(i, 2), countries{i}, 'FontSize', 14,'FontName','Arial');
    end
end

xlabel('NCM-H ratio');
ylabel('BEV Capacity');xtickformat("percentage");
annotation('textbox',[.72,.075,.1,.1],'String',{'\color[rgb]{0 0.75 1}\bullet+ Cluster 1  \color[rgb]{.13 .55 .13}\bullet+ Cluster 2  \color[rgb]{1 .82 0}\bullet+ Cluster 3','\color[rgb]{0,0,0}\bullet for CN provinces  + for EU countries'},'FitBoxToText','on','FontName','Arial','FontSize',14);
title('c','FontName','Arial','FontSize',30,'FontWeight','bold',  'Position',[-18 80]);xlim([0 100]);
subtitle('Battery chemistry and Capacity');
set(gca,'FontName','Arial','fontsize',14);
set(gca,'looseInset',[0 0 0.03 0.05]);