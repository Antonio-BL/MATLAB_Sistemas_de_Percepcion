function representa(Y, Y_pred, NUM_LABELS)
figure
hold on
labels = unique(Y); 
for lbl_Indx = 1 : NUM_LABELS
    label = labels(lbl_Indx); 
    bar(label, nnz(double(Y_pred)==label),0.4 ,"stacked", "DisplayName", "Predicted","EdgeColor","k","FaceColor",'r')
    bar(label+0.4, nnz(double(Y)==label),0.4, "stacked", "DisplayName", "Real","EdgeColor","k","FaceColor",'g')
end
hold off
title("Resultados")
xticks(labels)
xlabel("Clase predicha")
ylabel("Número de predicciones")
legend("Predicho", "Real")
end