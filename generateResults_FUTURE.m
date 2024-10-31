addpath(PATHS.EEGCONNECTIVITYPIPELINE)
addpath(PATHS.BCT)
addpath(PATHS.FTPATH)
ft_defaults

T = bv_createSubjectResults('PLI_3s', false);
T.ageWeek = cellfun(@(x) str2double(x(1:2)), T.week);
T(T.ageWeek<24 ,:) = [];
T(cellfun(@length, T.trialinfo)<120,:) = [];
T(T.removed,:) = [];
T = bv_removeDoubleSubjects(T);
% T = bv_selectTrials(T, 'plispctrm', 480);

chars = {'strength', 'SWP', 'modularity'};
T = bv_calculateNetworkCharacteristics(T, 'plispctrm', chars);

allWs = cellfun(@(x) squeeze(nanmean(x,3)), T.plispctrm, 'un', 0);
allWs = cat(4,allWs{:});


msts = bv_createMSTs(squeeze(allWs(:,:,1:2,:)));
n_edges = squeeze(sum(sum(msts,1),2))/2;
LF = bv_calculateLeafFraction(msts);
n_leafs = LF.*n_edges;
BC_max = squeeze(max(gr_calculateBetweennessCentrality(msts, 'binary')));
TH = n_leafs ./ (2.*n_edges.*BC_max);
[~, ~, ecc, ~, diam] = gr_calculatePathlengthWs(msts, 'binary');

mkdir('R')
TR = table();
TR.pseudo = T.pseudo;
TR.ageWeek = T.ageWeek;
TR.network_strength = T.plispctrm_strength;
TR.network_SWP = T.plispctrm_SWP;
TR.network_Q = T.plispctrm_Q;
TR.scaled_network_strength = zscore(T.plispctrm_strength);
TR.scaled_network_SWP = zscore(T.plispctrm_SWP);
TR.scaled_network_Q = zscore(T.plispctrm_Q);
TR.mst_LF = LF';
TR.mst_BCmax = BC_max';
TR.mst_TH = TH';
TR.mst_ecc = ecc';
TR.mst_diam = diam';
TR.scaled_mst_LF = zscore(LF)';
TR.scaled_mst_BCmax = zscore(BC_max)';
TR.scaled_mst_TH = zscore(TH)';
TR.scaled_mst_ecc = zscore(ecc)';
TR.scaled_mst_diam = zscore(diam)';
TR.testdate = T.testdate;
TR.n_trials = cellfun(@length, T.trialinfo);

save([PATHS.RESULTS filesep 'results.mat'], 'TR')
writetable(TR, './R/rFutureUtrecht_Leuven_2.csv')
