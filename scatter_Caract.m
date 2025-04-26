function scatter_Caract(X, Y, Y_pred)

realData = array2table([X, Y]);
predData = array2table([X, Y_pred]);

NUM_CARACT = length((realData.Properties.VariableNames));

labels = string(unique(Y));


% variable que contiene el nombre de la última columna de la tabla
Endvar = predData.Properties.VariableNames(end);
Endvar = Endvar{:}; 

for caract = 1 : NUM_CARACT-1

    xvar = predData.Properties.VariableNames(caract);
    xvar = xvar{:}; 
    yvar = predData.Properties.VariableNames(caract+1);
    yvar = yvar{:}; 

    figure;
    hold on
    % real
    scatter3(realData, xvar , yvar, Endvar, ColorVariable=Endvar)
    % pred
    scatter3(predData, xvar, yvar, Endvar, ColorVariable=Endvar)
    hold off,
    colorbar; 
end
end




