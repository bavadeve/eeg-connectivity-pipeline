% Emptions options file for the EEG connectivity pipeline. Should be placed in
% the root folder of your analysis for the pipeline to function.

%% General options
% general options for the whole experiment
OPTIONS.saveData                = ''; % 'string': ('yes' or 'no') to determine whether data is saved
OPTIONS.triallength             = []; % [ number ]: triallength used for analysis
OPTIONS.artifacttrllength       = []; % [ number ]: triallength used for artifact detection
OPTIONS.pathsScript             = 'setPaths'; % 'string': pathScript name ('setPaths')
OPTIONS.subjectString           = ''; % 'string': unique search string for raw eeg files which will find all files when used as dir ( ['*' sDirString '*'] )
OPTIONS.dataType                = ''; % 'string': ('edf', 'bdf, 'eeg', 'mat') to determine which datatype will be used for the analyses
OPTIONS.maxbadchans             = []; % [ number ]: max number of 'bad' channels that can be removed an interpolated

%% Create subject folders
OPTIONS.CREATEFOLDERS.pathsFcn      = OPTIONS.pathsScript;
OPTIONS.CREATEFOLDERS.rawdelim      = ''; % delimiter found in raw eeg files
OPTIONS.CREATEFOLDERS.rawlabel      = {}; % { cell } with the labels of the seperate elements of eeg file name (with delimiters in between)
OPTIONS.CREATEFOLDERS.sfoldername   = {}; % { cell } with how your subject folders should be labeled (use labeling elements contained in OPTIONS.CREATEFOLDERS.rawlabel)
OPTIONS.CREATEFOLDERS.overwrite     = ''; % set to 'yes' to overwrite existing data
OPTIONS.CREATEFOLDERS.sDirString    = OPTIONS.subjectString;
OPTIONS.CREATEFOLDERS.dataType      = OPTIONS.dataType;

%% Preprocessing options
% options only used for the preprocessing of the data
OPTIONS.PREPROC.resampleFs      = []; % [ number ]: resampling frequency.
OPTIONS.PREPROC.trialfun        = ''; % 'string': filename of trialfun to be used (please add trialfun to your path)
OPTIONS.PREPROC.hpfreq          = []; % [ number ]: high-pass filter frequency cut-off
OPTIONS.PREPROC.lpfreq          = []; % [ number ]: low-pass filter frequency cut-off
OPTIONS.PREPROC.notchfreq       = []; % [ number ]: notch filter frequency
OPTIONS.PREPROC.pathsFcn        = OPTIONS.pathsScript;
OPTIONS.PREPROC.filttype        = ''; % 'string': ('but' or 'firws'). If none given, 'but' is used.
OPTIONS.PREPROC.saveData        = OPTIONS.saveData; % 'string': ('yes' or 'no') to determine whether data will be saved
OPTIONS.PREPROC.outputName      = 'PREPROC'; % 'string': addition to filename when saving, so that the output filename becomes [currSubject outputName .mat]
OPTIONS.PREPROC.rmChannels      = {}; % { cell }: names of channels to be removed before preprocessing
OPTIONS.PREPROC.overwrite       = 1; % [ number ]: set to 1 to overwrite existing data
OPTIONS.PREPROC.reref           = ''; % 'string': 'yes' to rereference data (default: 'no')
OPTIONS.PREPROC.refelec         = ''; % rereference electrode (string / number / cell of strings)
OPTIONS.PREPROC.overwrite       = ''; % set to 'yes' to overwrite existing data
OPTIONS.PREPROC.waveletThresh   = ''; % set to 'yes' to do wavelet thresholding (not recommended)
OPTIONS.PREPROC.channels        = {}; % { cell } or 'string' for channels you want to analyze

%% Calculate artifact values after preprocessing
OPTIONS.ARTFCTPREPROC.inputName       = 'PREPROC'; % 'string': label of the file to be used for artifact detection
OPTIONS.ARTFCTPREPROC.outputName      = 'ARTFCTBEFORE'; % 'string': label to be added to the filename when the saving of artifact structure
OPTIONS.ARTFCTPREPROC.saveData        = OPTIONS.saveData; % 'string': ('yes' or 'no') to determine whether data will be saved
OPTIONS.ARTFCTPREPROC.pathsFcn        = OPTIONS.pathsScript; % 'string': pathScript name
OPTIONS.ARTFCTPREPROC.cutintrials     = ''; % 'string': ('yes' or 'no') to determine whether to cut trials
OPTIONS.ARTFCTPREPROC.triallength     = OPTIONS.artifacttrllength; % [ number ]: triallength used for artifact detection
OPTIONS.ARTFCTPREPROC.overwrite       = ''; % 'string': ('yes' or 'no') to determine whether to overwrite
OPTIONS.ARTFCTPREPROC.analyses        = {}; % { cell }: list of analyses to be performed (can be 'kurtosis', 'variance', 'flatline', 'abs', 'range', 'jump')

%% Remove channels options
% set options for the removal of complete channels. It is recommended to
% only remove channels that are flatlining of are extremely noisy, so much
% so that they will influence the average rereference grossly.
lims                                = struct;
lims.abs                            = []; % [ number ] for threshold of maximum absolute value of the EEG signal in a trial (in uV)
lims.range                          = []; % [ number ] for threshold of maximum range of the EEG signal in a trial (in uV)
lims.variance                       = []; % [ number ] for threshold of maximum variance value of the EEG signal in a trial (std^2)
lims.flatline                       = []; % [ number ] for threshold of maximum inverse variance value of the EEG signal in a trial (1 / std^2)
lims.kurtosis                       = []; % [ number ] for threshold of maximum kurtosis value of the EEG signal in a trial
lims.jump                           = []; % [ number ] set to 1 if you want to remove trials with jumps


OPTIONS.RMCHANNELS.lims            = lims;
OPTIONS.RMCHANNELS.pathsFcn        = OPTIONS.pathsScript;
OPTIONS.RMCHANNELS.inputName       = 'PREPROC';
OPTIONS.RMCHANNELS.outputName      = 'PREPROCRMCHANNELS';
OPTIONS.RMCHANNELS.artefactData    = 'ARTFCTBEFORE';
OPTIONS.RMCHANNELS.saveData        = OPTIONS.saveData;
OPTIONS.RMCHANNELS.maxpercbad      = []; % [ number ] in percentage. This is used as a threshold determining how much of a channel is allowed to be bad before it is designated for removal
OPTIONS.RMCHANNELS.expectedtrials  = []; % [ number ] of expected trials. This is used to calculate the percentage of bad data in a channel. If not set, the expected trials is calculated based on the input data
OPTIONS.RMCHANNELS.maxbadchans     = OPTIONS.maxbadchans;

%% Preprocessing + reref options without removed channels
% options only used for the preprocessing of the data
OPTIONS.REREF                   = OPTIONS.PREPROC;
OPTIONS.REREF.outputName        = 'REREF'; % 'string': addition to filename when saving, so that the output filename becomes [currSubject outputName .mat]
OPTIONS.REREF.reref             = ''; % 'string': 'yes' to rereference data (default: 'no')
OPTIONS.REREF.refelec           = ''; % rereference electrode (string / number / cell of strings)
OPTIONS.REREF.overwrite         = '';
OPTIONS.REREF.removechans       = ''; % 'string': 'yes' to remove channels designated by bv_removeChans data (default: 'no')
OPTIONS.REREF.interpolate       = ''; % 'string': 'yes' to interpolate removed channels (default: 'no')

%% Calculate artifact values after preprocessing
OPTIONS.ARTFCTRMCHANNELS.inputName       = 'PREPROCRMCHANNELS';
OPTIONS.ARTFCTRMCHANNELS.outputName      = 'ARTFCTRMCHANS';
OPTIONS.ARTFCTRMCHANNELS.saveData        = OPTIONS.saveData;
OPTIONS.ARTFCTRMCHANNELS.pathsFcn        = 'setPaths';
OPTIONS.ARTFCTRMCHANNELS.cutintrials     = 'yes';
OPTIONS.ARTFCTRMCHANNELS.triallength     = OPTIONS.artifacttrllength;
OPTIONS.ARTFCTRMCHANNELS.overwrite       = '';
OPTIONS.ARTFCTRMCHANNELS.analyses        = {}; % { cell }: list of analyses to be performed (can be 'kurtosis', 'variance', 'flatline', 'abs', 'range', 'jump')

%% Trial cleaning
% set options for the removal of trials.
lims                            = struct;
lims.abs                        = []; % [ number ] for threshold of maximum absolute value of the EEG signal in a trial (in uV)
lims.range                      = []; % [ number ] for threshold of maximum range of the EEG signal in a trial (in uV)
lims.variance                   = []; % [ number ] for threshold of maximum variance value of the EEG signal in a trial (std^2)
lims.flatline                   = []; % [ number ] for threshold of maximum inverse variance value of the EEG signal in a trial (1 / std^2)
lims.kurtosis                   = []; % [ number ] for threshold of maximum kurtosis value of the EEG signal in a trial
lims.jump                       = []; % [ number ] set to 1 if you want to remove trials with jumps

OPTIONS.CLEANED.lims            = lims;
OPTIONS.CLEANED.pathsFcn        = OPTIONS.pathsScript;
OPTIONS.CLEANED.inputName       = 'PREPROCRMCHANNELS';
OPTIONS.CLEANED.outputName      = 'CLEANED';
OPTIONS.CLEANED.artfctdefStr    = 'ARTFCTRMCHANS';
OPTIONS.CLEANED.saveData        = OPTIONS.saveData;

%% Append
OPTIONS.APPENDED.pathsFcn        = OPTIONS.pathsScript;
OPTIONS.APPENDED.inputName       = 'CLEANED';
OPTIONS.APPENDED.outputName      = 'APPEND';
OPTIONS.APPENDED.saveData        = OPTIONS.saveData;

%% PLI connetivity calculation options
OPTIONS.PLICONNECTIVITY.inputName       = 'APPEND';% 'string': outputName of previous analysis step, to be used as input for this step
OPTIONS.PLICONNECTIVITY.triallength     = OPTIONS.triallength; % frequency output used
OPTIONS.PLICONNECTIVITY.outputName      = ['PLI_', num2str(OPTIONS.triallength), 's']; %'string': addition to filename when saving, so that the output filename becomes [currSubject outputName .mat]
OPTIONS.PLICONNECTIVITY.saveData        = OPTIONS.saveData;
OPTIONS.PLICONNECTIVITY.optionsFcn      = OPTIONS.pathsScript;
OPTIONS.PLICONNECTIVITY.keeptrials      = '';
OPTIONS.PLICONNECTIVITY.preprocOptions  = []; % [ struct ] with preprocessing options
OPTIONS.PLICONNECTIVITY.ntrials         = []; % [ number ] number of trials to be used for PLI calculation

