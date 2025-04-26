% Convierte las propiedades depuradas de cell a matriz para poder ser
% utilizables. FUNCIÓN RECURSIVA: posible problema de tipo cell -> mat,
% limitado a 5 llamadas
function [areas_mat, perimetros_mat, centroides_mat, bboxes_mat] =...
    impropsAMatriz(areas, perimetros, centroides, bboxes)

global recursiveRecallCounter

try % posibilidad de type error en conversión cell -> mat

    % Conversión a un tipo fácil de trabajar
    areas_mat = cell2mat(areas);
    num_regions = length(areas_mat);
    perimetros_mat = cell2mat(perimetros);

    centroides_mat  = zeros(num_regions, 2);
    bboxes_mat  = zeros(num_regions, 4);
    for region =  num_regions:-1:1
        centroides_mat(region,:) = cell2mat(centroides(region));
        bboxes_mat(region, :) = cell2mat(bboxes(region));
    end

% caso de error -- DEBUGGING 
catch exception
    if strcmp(exception.identifier, 'MATLAB:cell2mat:UnsupportedCellContent')
        recursiveRecallCounter = recursiveRecallCounter + 1
                disp("areas")
                areas   ,disp()
                disp("areas{:}")
                areas{:}, disp()
                disp("areas(:)")
                areas(:), disp()
                disp("clase")
                class(areas)

                areas = [areas(:)];
                bboxes =[bboxes(:)];
                centroides = [centroides(:)];
                perimetros = [perimetros(:)];

        if recursiveRecallCounter < 5
            [areas_mat, perimetros_mat, centroides_mat, bboxes_mat] =...
                impropsAMatriz(areas, perimetros, centroides, bboxes) ;
        else
            exception
            error("Sigue habiendo error de tipo ")
        end
    end

end