clc;clear;close all;
% The workbook for clustering is collated from the source data
workbook = 'Clu_C2_C4_Pene.xlsx';
[~, ~, data_a] = xlsread('Clu_C2_C4_Pene', 'C2'); % C2 EV penetration
[~, ~, data_b] = xlsread('Clu_C2_C4_Pene', 'C4'); % C4 EV penetration

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

max_k = 10;
num_runs = 10;
num_seeds = 10;
silhouette_scores = zeros(max_k, num_runs, num_seeds);
% Here use Silhouette Scores to evaluate the clustering

for seed = 1:num_seeds
    rng(seed);
    
    for run = 1:num_runs
        for k = 2:max_k
            
            data = [normalized_info_a, normalized_info_b];
            labels = kmeans(data, k, 'Start', 'plus');
            
            % Calculating Silhouette
            silh = silhouette(data, labels);
            
            % Average
            silhouette_scores(k, run, seed) = mean(silh);
        end
    end
end

mean_silhouette_scores = mean(silhouette_scores, 2);

% Select the K with the largest Silhouette Scores
mean_silhouette_scores_over_seeds = mean(mean_silhouette_scores, 3);
[~, best_k] = max(mean_silhouette_scores_over_seeds);

% Get labels
data = [normalized_info_a, normalized_info_b];
best_labels = kmeans(data, 3, 'Start', 'plus');

labels_total = {best_labels, info_c};
% Plot results
figure(1)
color2 = [.58 0 .83;.58 0 .83;.125 .7 .67;.125 .7 .67;1 0.5 0;1 0.5 0];
t=tiledlayout(1,2,'TileSpacing','none','Padding','tight');nexttile(2)
gscatter(info(:, 1), info(:, 2), labels_total,color2,'.+.+.+',15,'off');
hold on;

% Country name
for i = 1:length(countries)
   if i == 19%GD
text(info(i,1)-4.5, info(i, 2), countries{i}, 'FontSize', 14,'FontName','Arial');
    elseif i == 52%CZ
        text(info(i,1), info(i, 2)+.3, countries{i}, 'FontSize', 14,'FontName','Arial');
    else
        text(info(i,1), info(i, 2), countries{i}, 'FontSize', 14,'FontName','Arial');

    end
end

xlabel('C2 EV Penetration');
ytickformat("percentage");xtickformat("percentage");
axis equal;
xlim([0 100]);ylim([0 100]);hold on;x = 0:1:100;y_1 = x;plot(x,y_1,'k');
ylabel('C4 EV Penetration');
annotation('textbox',[.73,.075,.1,.1],'String',{'\color[rgb]{.125 .7 .67}\bullet+ Cluster 1  \color[rgb]{.58 0 .83}\bullet+ Cluster 2  \color[rgb]{1 0.5 0}\bullet+ Cluster 3','\color[rgb]{0,0,0}\bullet for CN provinces  + for EU countries'},'FitBoxToText','on','FontName','Times New Roman','FontSize',14);
subtitle('C2 and C4 EV penetration');
set(gca,'FontName','Arial','fontsize',14);
set(gca,'looseInset',[0 0 0.03 0.05]);