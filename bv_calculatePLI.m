function [ connectivity ] = bv_calculatePLI(cfg, data)
% bv_calculatePLI calculates the phase locking index (PLI) between channels
% based on fieldtrip data. Data can be input as arg2 or by giving subject
% folder name (cfg.currSubject = {}).
%
% Use as
%   [ connectivity ] = bv_calculatePLI(cfg)
% or
%   [ connectivity ] = bv_calculatePLI(cfg, data)
%
% inputs:
%   cfg -> input configuration structure
%   data -> fieldtrip eeg data variable
%
% outputs:
%   connectivity -> structure with the following fields:
%       .plispctrm  --> phase locking index adjacency matrices
%       .dimord     --> dimension explanation adjacency matrices
%       .sampleinfo --> EEG sampleinfo of trials
%       .trialinfo  --> EEG trigger information of trials
%       .time       --> fieldtrip time
%       .label      --> eeg channel labels
%       .freq       --> frequency labels
%       .freqRng    --> frequency ranges
%
% the following fields are required in the cfg variable
%   cfg.ntrials         = [ number or 'all']: number of trials to be used for
%                           the pli calculation. These are randomly picked out
%                           of all available trials. If 'all' all trials are
%                           used (default: 'all')
%   cfg.condition       = [ number or 'all']: trigger number of the condition
%                           to be used for this analysis. If 'all' all trials
%                           are used (default: 'all')
%   cfg.triallength     = [ number ]: length of trials in seconds
%   cfg.keeptrials      = 'yes/no': set to 'yes' if you want seperate adjacency
%                           matrices for all trials. Otherwise the adjacency
%                           matrices will be averaged into one (default: 'no')
%   cfg.freqRng         = { cell with [ doubles ] }. The ranges of the frequency
%                           bands you want to test. For example {[0 4], [4 8]}
%                           will test the frequency bands 0-4Hz and 4-8Hz.
%                           Default: {[0.2 2.9], [3 5.9], [6 8.9], [9 11.9], [12
%                           25], [25 45], [55 70]}
%   cfg.freqLabel       = { cell }: with the labels in strings of the frequency
%                           ranges in cfg.freqRng. Default: {'delta', 'theta',
%                           'alpha1', 'alpha2','beta', 'gamma1', 'gamma2'}
%
% the following fields are required for the config variable if no data
% variable is given:
%   cfg.inputName       = 'string': previous analysis with the cleaned data to
%                           be used for this function, as in subjectdata.PATHS.
%                           (inputName)
%   cfg.currSubject     = 'string': subject folder name to be analyzed
%   cfg.pathsFcn        = 'string': filename of m-file to be read with all
%                           necessary paths to run this function (default:
%                           'setPaths'). Take care to add your trialfun
%                           to your matlab path). For an example options
%                           fcn see setPaths.m
%   cfg.saveData        = 'yes/no': specifies whether data needs to be
%                           saved to personal folder (default: 'no')
%
% the following fields need to be set if the data is saved
%   cfg.outputName      = 'string': name for output file. Output will
%                           be called (currSubject)_(cfg.outputName).mat
%                           path will be added to subjectdata.PATHS as
%                           subjectdata.PATHS.(outputName)
%   cfg.overwrite       = 'yes/no': set to 'yes' if data is allowed to be
%                           overwritten (default: 'no')
%
% the following fields are optional
%   cfg.preprocOptions   = [ struct ]: options to be added for the reading in of
%                           RAW EEG data. It is generally recommended that you
%                           re-use the options used earlier in your analysis (in
%                           the EEG-connectivity-pipeline, you would generally
%                           re-use the same options as in the rereferencing
%                           step) (default: [])
%   cfg.quiet           = 'yes/no': set to 'yes' to prevent additional
%                           details in command window (default: false)
%
% 2015-2021, Bauke van der Velde
% See also BV_SAVEDATA BV_CHECK4DATA FT_REDEFINETRIAL FT_ARTIFACT_JUMP

%%%%%% general check for inputs %%%%%%
ntrials         = ft_getopt(cfg, 'ntrials','all');
condition       = ft_getopt(cfg, 'condition', 'all');
currSubject     = ft_getopt(cfg, 'currSubject');
inputName       = ft_getopt(cfg, 'inputName');
saveData        = ft_getopt(cfg, 'saveData', 'no');
outputName      = ft_getopt(cfg, 'outputName');
pathsFcn        = ft_getopt(cfg, 'pathsFcn', 'setPaths');
triallength     = ft_getopt(cfg, 'triallength');
keeptrials      = ft_getopt(cfg, 'keeptrials', 'no');
quiet           = ft_getopt(cfg, 'quiet');
preprocOptions  = ft_getopt(cfg, 'preprocOptions', []);
overwrite       = ft_getopt(cfg, 'overwrite', 'no');
freqLabel       = ft_getopt(cfg, 'freqLabel',  ...
    {'delta', 'theta', 'alpha1', 'alpha2','beta', 'gamma1', 'gamma2'});
freqRng         = ft_getopt(cfg, 'freqRng', ...
    {[0.2 2.9], [3 5.9], [6 8.9], [9 11.9], [12 25], [25 45], [55 70]});

if strcmpi(quiet, 'yes')
    quiet = true;
else
    quiet = false;
end

% load in data if no input data is given
if nargin < 2
    if ~quiet; disp(currSubject); end
    eval(pathsFcn)
    
    subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
    
    if ~quiet
        [subjectdata, check, data] = bv_check4data(subjectFolderPath, inputName);
        if ~check
            error('%s: input data not found', currSubject)
        end
    else
        evalc('[subjectdata, check, data] = bv_check4data(subjectFolderPath, inputName);');
        if ~check
            error('%s: input data not found', currSubject)
        end
    end
    
    if strcmpi(overwrite, 'no')
        if isfield(subjectdata.PATHS, upper(outputName))
            if exist(subjectdata.PATHS.(upper(outputName)), 'file')
                if ~quiet; fprintf('\t !!!%s already found, not overwriting ... \n', upper(outputName)); end
                connectivity = [];
                return
            end
        end
    end
    
    subjectdata.cfgs.(outputName) = cfg;
elseif isfield(cfg, 'currSubject')
    
    eval(pathsFcn)
    
    subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
    
    if ~quiet
        [subjectdata, check] = bv_check4data(subjectFolderPath);
        if ~check
            error('%s: input data not found', currSubject)
        end
    else
        evalc('[subjectdata, check] = bv_check4data(subjectFolderPath);');
        if ~check
            error('%s: input data not found', currSubject)
        end
    end
    
end

if ~quiet; fprintf('\t loading in original data ...'); end
cfg = preprocOptions;
cfg.currSubject = currSubject;
cfg.saveData = 'no';
cfg.trialfun = '';
evalc('origdata = bv_preprocResample(cfg);');
if ~quiet; fprintf('done! \n'); end

for iFreq = 1:length(freqLabel)
    currFreq = freqLabel{iFreq};
    currFreqRng = freqRng{iFreq};
    if ~quiet; fprintf('\t ******* filtering for %s ... ******* \n' , currFreq); end
    cfg = [];
    cfg.lpfilter = 'yes';
    cfg.lpfreq = currFreqRng(2);
    cfg.lpinstabilityfix = 'reduce';
    cfg.hpfilter = 'yes';
    cfg.hpfreq = currFreqRng(1);
    cfg.hpinstabilityfix = 'reduce';
    evalc('origdata_filt = ft_preprocessing(cfg, origdata);');
    
    if ~quiet; fprintf('\t cut out clean data according to input file ... \n'); end
    trl = [data.sampleinfo, zeros(size(data.sampleinfo,1),1), data.trialinfo];
    cfg = [];
    cfg.trl = trl;
    evalc('origdata_filt = ft_redefinetrial(cfg, origdata_filt);');
    
    % cut, if needed data into trials
    if ~isempty(triallength)
        cfg = [];
        cfg.saveData = 'no';
        cfg.triallength = triallength;
        cfg.ntrials = ntrials;
        if ~quiet
            [dataCut, finished] = bv_cutAppendedIntoTrials(cfg, origdata_filt);
        else
            evalc('[dataCut, finished] = bv_cutAppendedIntoTrials(cfg, origdata_filt);');
        end
        
        if ~finished
            connectivity = [];
            return;
        end
    else
        dataCut = origdata_filt;
    end
    
    if not(strcmpi(condition, 'all'))
        cfg = [];
        cfg.trials = find(ismember(dataCut.trialinfo, condition));
        evalc('dataCut = ft_selectdata(cfg, dataCut);');
    end
    
    if ~quiet; fprintf('\t calculating PLI ... '); end
    PLIs = PLI(dataCut.trial,1);
    PLIs = cat(3,PLIs{:});
    
    if strcmpi(keeptrials, 'yes')
        connectivity.plispctrm(:,:,:, iFreq) = PLIs;
        connectivity.dimord = 'chan_chan_trl_freq';
        connectivity.sampleinfo = dataCut.sampleinfo;
        connectivity.time = dataCut.time;
    else
        connectivity.plispctrm(:,:,iFreq) = mean(PLIs,3);
        connectivity.dimord = 'chan_chan_freq';
    end
    
    if ~quiet; fprintf('done!\n'); end
end

connectivity.freq = freqLabel;
connectivity.freqRng = freqRng;
connectivity.label = dataCut.label;
connectivity.trialinfo = dataCut.trialinfo;

%         % find removed channels and add a row of nans
%         cfg = [];
%         cfg.layout = 'biosemi32.lay';
%         cfg.skipcomnt = 'yes';
%         cfg.skipscale = 'yes';
%         evalc('layout = ft_prepare_layout(cfg);');
%         rmChannels = layout.label(not(ismember(layout.label, connectivity.label)));
%         if not(isempty(rmChannels))
%             connectivity = addRemovedChannels(connectivity, rmChannels);
%         end

%%%%%% save data %%%%%%
if strcmpi(saveData, 'yes')
    
    outputFilename = [subjectdata.subjectName '_' outputName '.mat'];
    fieldname = upper(outputName);
    subjectdata.PATHS.(fieldname) = [subjectdata.PATHS.SUBJECTDIR filesep ...
        outputFilename];
    
    if ~quiet
        fprintf('\t saving %s ... ', outputFilename);
        save(subjectdata.PATHS.(fieldname), 'connectivity')
        fprintf('done! \n')
        fprintf('\t saving subjectdata variable to Subject.mat ... ')
        save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'], 'subjectdata')
        fprintf('done! \n')
        %         if isfield(PATHS, 'SUMMARY')
        %             bv_updateSubjectSummary([PATHS.SUMMARY filesep 'SubjectSummary'], subjectdata)
        %         end
    else
        save(subjectdata.PATHS.(fieldname), 'connectivity')
        save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'], 'subjectdata')
    end
    
end

%%%%%% extra functions %%%%%%
function connectivity = addRemovedChannels(connectivity, trueRmChannels)

connectivity.label = cat(1,connectivity.label, trueRmChannels);

fnames = fieldnames(connectivity);
fname2use = fnames{not(cellfun(@isempty, strfind(fnames, 'spctrm')))};

currSpctrm = connectivity.(fname2use);
startRow = (size(currSpctrm,1) + 1);
endRow = (size(currSpctrm,1)) + length(trueRmChannels);
currSpctrm(1:size(currSpctrm,1), startRow:endRow, :) = NaN;
currSpctrm(startRow:endRow, 1:size(currSpctrm,2), :) = NaN;

cfg = [];
cfg.channel  = connectivity.label;
cfg.layout   = 'EEG1010';
cfg.feedback = 'no';
cfg.skipcomnt   = 'yes';
cfg.skipscale   = 'yes';
evalc('lay = ft_prepare_layout(cfg);');

[~, indxSort] = ismember(lay.label, connectivity.label);
indxSort = indxSort(any(indxSort,2));

currSpctrm = currSpctrm(indxSort, indxSort,:,:);
connectivity.label = connectivity.label(indxSort);
connectivity.(fname2use) = currSpctrm;