clc;clear;close all;
% The workbook for clustering is collated from the source data
workbook = 'Clu_EV_BEV.xlsx';
[~, ~, data_a] = xlsread('Clu_EV_BEV', 'EV');  % EV penetration
[~, ~, data_b] = xlsread('Clu_EV_BEV', 'BEV'); % BEV proportion

% Countries and info
countries = data_a(2:end, 1);
info_a = cell2mat(data_a(2:end, 7)).*100;
info_b = cell2mat(data_b(2:end, 7)).*100;
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

% Here choose best_k = 3 according to the Elbow Method
% best_k = input('Please enter the best k value based on the elbow method: ');
best_k = 3;

%% Get labels using K-means algorithm
rng(42);

% Get labels
[labels, centers] = kmeans(normalized_data, best_k);

labels_total = {labels, info_c};

color1 = [1 0 0;1 0 0;0 1 0;0 1 0;0 0 1;0 0 1];
% Plot results
figure(2)
gscatter(info(:, 1), info(:, 2), labels_total,color1,'.+.+.+',15,'off');
xtickformat('percentage');xlim([0,100]);
ytickformat('percentage');ylim([0,100]);
hold on;

% Country name
for i = 1:length(countries)
    if i == 56 %Slovakia
        text(info(i,1)-1, info(i, 2)-1, countries{i}, 'FontSize', 14,'FontName','Arial');
    elseif i == 48 || i == 22 %Estonia
        text(info(i,1), info(i, 2)+1, countries{i}, 'FontSize', 14,'FontName','Arial');
    elseif i == 3 || i == 23 || i == 39 || i == 37
        text(info(i,1), info(i, 2)-1, countries{i}, 'FontSize', 14,'FontName','Arial');
    elseif i == 4
        text(info(i,1), info(i, 2)+1, countries{i}, 'FontSize', 14,'FontName','Arial');
    elseif i == 13
        text(info(i,1), info(i, 2)+1, countries{i}, 'FontSize', 14,'FontName','Arial');
    elseif i == 42|| i == 54
        text(info(i,1)+.5, info(i, 2), countries{i}, 'FontSize', 14,'FontName','Arial');
        elseif i ==55
        text(info(i,1), info(i, 2)+1.2, countries{i}, 'FontSize', 14,'FontName','Arial');
        
    else
        text(info(i,1), info(i, 2), countries{i}, 'FontSize', 14,'FontName','Arial');
    end
end

xlabel('EV sales ratio');
ylabel('proportion of BEV in EV');
annotation('textbox',[.72,.075,.1,.1],'String',{'\color[rgb]{1,0,0}\bullet+ Cluster 1  \color[rgb]{0,1,0}\bullet+ Cluster 2  \color[rgb]{0,0,1}\bullet+ Cluster 3','\color[rgb]{0,0,0}\bullet for CN provinces  + for EU countries'},'FitBoxToText','on','FontName','Times New Roman','FontSize',14);
subtitle('EV penetration and BEV proportion');
set(gca,'FontName','Arial','fontsize',14);
set(gca,'looseInset',[0 0 0.03 0.05]);