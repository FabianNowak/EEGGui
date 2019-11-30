%MATLAB Apps require the main function to return the figure handle
%StartEEGGui() opens the App and extracts the underlying figure
function fig = StartEEGGui()
    gui = EEGGui;
    fig = gui.fig;
end