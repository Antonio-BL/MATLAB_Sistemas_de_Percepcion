function scatter_Caract(X, Y, Y_pred)

realData = array2table([X, Y]);
predData = array2table([X, Y_pred]);

NUM_CARACT = length((realData.Properties.VariableNames));

labels = string(unique(Y));
NUM_LABELS = length(labels);

% variable que contiene el nombre de la última columna de la tabla
Endvar = predData.Properties.VariableNames(end);
Endvar = Endvar{:};

for caract = 1 : NUM_CARACT-2

    xvar = predData.Properties.VariableNames(caract);
    xvar = xvar{:};
    yvar = predData.Properties.VariableNames(caract+1);
    yvar = yvar{:};

    figure;
    % real
    sc1 = scatter(realData, xvar , yvar,ColorVariable=Endvar,  Marker="o", DisplayName="Real");
    legend("show")
    cmap1 = colormap(gcf(), 'jet');
    cb = colorbar;
    cb.Ticks = 1 :  NUM_LABELS;
    cb.TickLabels = 1 :  NUM_LABELS;
    cb.Label.String = 'Clases';
    cb.Label.FontSize = 12;

    hold
    % pred
    sc2 = scatter(predData, xvar, yvar, ColorVariable=Endvar, Marker="*", DisplayName="Predicho");
    legend("show")
    cb = colorbar;
    cb.Ticks = 1 :  NUM_LABELS;
    cb.TickLabels = 1 :  NUM_LABELS;
    cb.Label.String = 'Clases';
    cb.Label.FontSize = 12;


    hold off,
end
end




