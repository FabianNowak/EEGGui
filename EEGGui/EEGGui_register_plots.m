function EEGGui_register_plots(gui)
import plots.*
gui.addplot('Raw',RawPlot(gui,false));
%gui.addplot('Raw 1st Derivative', RawPlot(gui,true));
gui.addplot('Density Spectral Array', DsaPlot(false));
gui.addplot('DSA 1st Derivative', DsaPlot(true));
gui.addplot('Relative Alpha', RelativeAlphaPlot());
gui.addplot('Beta Ratio', BetaRatioPlot());
gui.addplot('Spectral Entropy',SpectralEntropyPlot());
gui.addplot('Permutation Entropy',PermEnPlot(gui));
gui.addplot('Burst Suppression', BurstSuppPlot(gui));
end

