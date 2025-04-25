function representa(Y, Y_pred, NUM_LABELS)
figure
hold on
labels = unique(Y);
precision = zeros([NUM_LABELS, 1]);
for lbl_Indx = 1 : NUM_LABELS
    label = labels(lbl_Indx);
    bar(label, nnz(double(Y_pred)==label),0.4 ,"stacked", "DisplayName", "Predicted","EdgeColor","k","FaceColor",'r')
    bar(label+0.4, nnz(double(Y)==label),0.4, "stacked", "DisplayName", "Real","EdgeColor","k","FaceColor",'g')
    y = nnz(double(Y)==label); 
    y_pred = nnz(double(Y_pred)==label); 
    precision(lbl_Indx) = 1 - abs((y-y_pred)/y); 
end
hold off
PRECISION = mean(precision); 
title(strcat("Resultados", " Precision: ", num2str(PRECISION)))
xticks(labels)
xlabel("Clase predicha")
ylabel("Número de predicciones")
legend("Predicho", "Real")
end