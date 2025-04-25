function firma = calculaFirma(imgBin, centroide)
[FILAS, COLUMNAS] = size(imgBin);
cX = centroide(1);
cY = centroide(2);

dist = [];
for fila = 1 : FILAS
    for col = 1 : COLUMNAS
        if imgBin(fila, col)
            distX =  abs(col-cX);
            distY = abs(fila-cX);
            dist = [dist; sqrt(distX^2 + distY^2)];
        end
    end
end
firma = dist; 

end