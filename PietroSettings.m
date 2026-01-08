% fetch settings object
s = settings;

% font
s.matlab.fonts.codefont.Size.PersonalValue = 11;
s.matlab.fonts.codefont.Name.PersonalValue = 'Liberation Mono';
s.matlab.fonts.editor.title.Color.PersonalValue = [245 119 41 1]; % what is this pref?
s.matlab.fonts.editor.normal.Color.PersonalValue = [255 255 255 1];
s.matlab.fonts.editor.code.Color.PersonalValue = [255 255 255 1];

% command window
s.matlab.commandwindow.NumericFormat.PersonalValue = 'longG';
s.matlab.commandwindow.suggestions.ShowAutomatically.PersonalValue = false;

% color preferences
% background color seems to be missing and needs to be manually set to [51 51 51], [0.15,0.15,0.15]
% editor
s.matlab.colors.UnterminatedStringColor.PersonalValue = [255 135 133];    % [1    0.53 0.52]
s.matlab.colors.ValidationSectionColor.PersonalValue = [102 204 255];     % [0.4  0.8  1]
s.matlab.colors.CommentColor.PersonalValue = [188 255 88];                % [0.74 1    0.34]
s.matlab.colors.KeywordColor.PersonalValue = [255 153 255];               % [1    0.6  1]
s.matlab.colors.StringColor.PersonalValue = [255 195 121];                % [1    0.76 0.47]
s.matlab.colors.SyntaxErrorColor.PersonalValue = s.matlab.colors.UnterminatedStringColor.PersonalValue;
s.matlab.colors.SystemCommandColor.PersonalValue = [224 147 255];
% command window
s.matlab.colors.commandwindow.ErrorColor.PersonalValue = s.matlab.colors.UnterminatedStringColor.PersonalValue;
s.matlab.colors.commandwindow.HyperlinkColor.PersonalValue = s.matlab.colors.ValidationSectionColor.PersonalValue;
s.matlab.colors.commandwindow.WarningColor.PersonalValue = s.matlab.colors.StringColor.PersonalValue;
% programming tools
s.matlab.colors.programmingtools.AutofixHighlightColor.PersonalValue = [120 75 0];
s.matlab.colors.programmingtools.CodeAnalyzerWarningColor.PersonalValue = [255 147 96];
s.matlab.colors.programmingtools.VariableHighlightColor.PersonalValue = [80 80 80];
s.matlab.colors.programmingtools.VariablesWithSharedScopeColor.PersonalValue = s.matlab.colors.SystemCommandColor.PersonalValue;

% editor
s.matlab.editor.autocoding.ControlFlows.PersonalValue = true;
s.matlab.editor.tab.IndentSize.PersonalValue = 2;
s.matlab.editor.tab.TabSize.PersonalValue = 2;
s.matlab.editor.displaysettings.linelimit.LineColumn.PersonalValue = 150;
s.matlab.editor.suggestions.ShowAutomatically.PersonalValue = false;
s.matlab.editor.language.matlab.comments.WrapAutomatically.PersonalValue = false;

% log to console
clear s
disp('Setting custom preferences')
disp('For better visualization, manually open:') % JUST SET DARK MDOE
disp('1. Preferences > MATLAB > Colors and set Background to [51 51 51]')
disp('2. Preferences > MATLAB > Fonts and set')
disp(' - Desktop text font to ''Liberation Mono'' 12') % DON'T EXIST ANYMORE
disp(' - Use antialiasing to on')
disp('3. Preferences > MATLAB > Fonts > Custom and set Command Window and Command History to follow Desktop text')  % DON'T EXIST ANYMORE
disp('4. Preferences > MATLAB > General and set Initial working folder')