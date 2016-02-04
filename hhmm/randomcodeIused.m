load('runs.mat')
logps = zeros(size(runs));
for i = 1:size(runs,1)
    for j = 1:size(runs,1)
        if isstruct(runs{i,j})
            logps(i,j) = mean(runs{i,j}.test_log_p);
        end
    end
end


colormap(hot)
imagesc(logps);set(gca,'XTick',1:4,'XTickLabel',['2';'3';'4';'5'],'YTick',1:4,'YTickLabel',['2';'3';'4';'5'])
caxis([min(logps(logps~=0))*1.2,max(logps(logps~=0))*.8]);
xlabel('Breadth')
ylabel('Depth')
title('Effect of Tree Size on Loglikelihood of Test Data')


logps = zeros(size(runs));
for i = 1:size(runs,1)
    for j = 1:size(runs,1)
        if isstruct(runs{i,j})
            logps(i,j) = mean(log(runs{i,j}.shuffled_test_p));
        end
    end
end


colormap(hot)
imagesc(logps);set(gca,'XTick',1:4,'XTickLabel',['2';'3';'4';'5'],'YTick',1:4,'YTickLabel',['2';'3';'4';'5'])
caxis([min(logps(logps~=0))*1.2,max(logps(logps~=0))*.8]);
xlabel('Breadth')
ylabel('Depth')
title('Effect of Tree Size on Loglikelihood of Scrambled Data')


alphabet = [' abcdefghijklmnopqrstuvwxyz'];

test = cell(12);
for i = 1:12
    test{i} = find(Bnew(i,:)>.08);
    labels{i} = upper(alphabet(test{i}));
end

colormap(hot)
imagesc(Anew);set(gca,'XTick',1:12,'XTickLabel',labels,'YTick',1:12,'YTickLabel',labels)
%rotateXLabels(gca,45)
title('HMM Transition Probabilities')


currentmodel = runs{3,1};

B_mat = [];
for child_idx = 1:2
    for gchild_idx = 1:2
        for ggchild_idx = 1:2
            for gggchild_idx = 1:2
                B_mat = [B_mat currentmodel.theta.subs{child_idx}.subs{gchild_idx}.subs{ggchild_idx}.subs{gggchild_idx}.B];
            end
        end
    end
end

B_mat = [];
for child_idx = 1:2
    for gchild_idx = 1:2
            B_mat = [B_mat currentmodel.theta.subs{child_idx}.subs{gchild_idx}.B];
    end
end

       
            






