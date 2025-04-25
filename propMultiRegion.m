function [area, perimetro, bboxes_mat, per2_area, centroidePonderado, firma, std_firma] = propMultiRegion(img, imgBin, imgEdge, imgProps)


if num_regions >1
    bboxes = {imgProps.BoundingBox};
    areas = {imgProps.Area};
    centroides = {imgProps.Centroid};
    perimetros = {imgProps.Perimeter};

    % recorrer hacia atrás para evitar problemas de apuntar a un índice
    % que no existe (longitud del cell variable)
    for region = num_regions:-1:1
        bbox_region = cell2mat(bboxes(region));
        x = bbox_region(1);
        y = bbox_region(2);
        w = bbox_region(3);
        h = bbox_region(4);
        seccion_area = [x:(x)+w, y:(y+h)];

        if all(bbox_region(3:4) == size(imgBin))
            bboxes(region) = [];
            areas(region) = [];
            centroides(region) = [];
            perimetros(region) = [];
        end

        % probablemente sea ruido
    end

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

    for region = 1 : num_regions
        if areas_mat(region) < 0.4*max(areas_mat(region))
            bboxes(region) = [];
            areas(region) = [];
            centroides(region) = [];
            perimetros(region) = [];
            imgBin(seccion_area) = zeros(size(seccion_area));
        end
    end

    % Cálculo de las propiedades
    area = sum(areas_mat, "all");
    perimetro = sum(perimetros_mat, "all");
    per2_area = perimetro^2/area;

    XcentroidePonderado = (areas_mat * centroides_mat(:,1))/area;
    YcentroidePonderado = (areas_mat * centroides_mat(:,2))/area;
    centroidePonderado = [XcentroidePonderado, YcentroidePonderado];
    firma = calculaFirma(imgBin,centroidePonderado);
    std_firma = std(firma);

    for region = 1 : num_regions
        x = bboxes_mat(region, 1);
        y = bboxes_mat(region, 2);
        w = bboxes_mat(region, 3);
        h = bboxes_mat(region, 4);
    end
    hold off
else    % solo una region -------------------------------------------------

    perimetro = sum(imgEdge, "all");
    area = sum(imgBin,"all");
    centroidePonderado = calculaCentroide(imgBin);
    per2_area = perimetro^2 / area;
    firma = calculaFirma(imgBin,centroidePonderado);
    std_firma = std(firma);

end
end