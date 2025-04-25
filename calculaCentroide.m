% Cálcula el centroide empleando la técnica dada en clase a partir de una
% imagen binaria. Devuelve el centroide como un vector de coordenadas [x,
% y]
function centroide = calculaCentroide(plantillaBinaria)
    plantilla = plantillaBinaria; 
    
    [ROWS, COLUMNS] = size(plantilla); 

    % Init
    m00 = sum(plantilla, "all"); 
    m01 = 0; 
    m10 = 0; 

    for row = 1 : ROWS
        for col = 1 : COLUMNS
            if plantilla(row, col) == 1
                m01 = m01 + row * plantilla(row, col); 
                m10 = m10 + col * plantilla(row, col); 
            end
        end
    end
   
    xcent = m10 / m00; 
    ycent = m01 / m00; 
    centroide = [xcent, ycent];

end